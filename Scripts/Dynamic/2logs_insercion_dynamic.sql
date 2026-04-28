USE `dynamic_db`;

DELIMITER $$

/* -----------------------------------------------------
   1. SP INDEPENDIENTE DE BITÁCORA (LOGS)
   ----------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_register_step_log$$
CREATE PROCEDURE sp_register_step_log(
    IN p_description VARCHAR(255),
    IN p_event_type_id INT,
    IN p_severity_id INT,
    IN p_user_id INT
)
BEGIN
    DECLARE v_next_log_id INT;
    
    -- Usar INTO para asignar a la variable local
    SELECT IFNULL(MAX(logID), 0) + 1 INTO v_next_log_id FROM Logs;
    
    INSERT INTO Logs (
        logID, eventTypeID, description, sourceID, severityID, postTime, userID
    )
    VALUES (
        v_next_log_id, p_event_type_id, p_description, 1, p_severity_id, NOW(), p_user_id
    );
END$$

/* -----------------------------------------------------
   2. SP TRANSACCIONAL PARA PAÍSES
   ----------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_insert_country_trans$$
CREATE PROCEDURE sp_insert_country_trans(
    IN p_id INT, 
    IN p_common VARCHAR(25), 
    IN p_official VARCHAR(30), 
    IN p_iso CHAR(3), 
    IN p_tax DECIMAL(5,4), 
    IN p_user_id INT
)
BEGIN
    -- Los HANDLERS van después de las variables y antes del código
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        CALL sp_register_step_log(CONCAT('ERROR: Fallo al insertar país ', p_common), 3, 3, p_user_id);
    END;

    START TRANSACTION;
        INSERT INTO Countries (countryID, countryCommonName, countryOfficialName, isoCode, taxRate, enabled, createdAt)
        VALUES (p_id, p_common, p_official, p_iso, p_tax, TRUE, NOW());
        
        CALL sp_register_step_log(CONCAT('País insertado: ', p_common), 1, 1, p_user_id);
    COMMIT;
END$$

/* -----------------------------------------------------
   3. SP TRANSACCIONAL PARA PRODUCTOS, WEBSITES E INVENTARIO
   ----------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_insert_product_full_trans$$
CREATE PROCEDURE sp_insert_product_full_trans(
    IN p_id INT, 
    IN p_name VARCHAR(80), 
    IN p_type_id INT, 
    IN p_cat_id INT, 
    IN p_meas_id INT, 
    IN p_website_id INT,
    IN p_user_id INT
)
BEGIN
    -- Declaración de variables SIEMPRE al inicio
    DECLARE v_price DECIMAL(19,4);
    DECLARE v_qty INT;

    -- Manejador de errores después de las variables
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        CALL sp_register_step_log(CONCAT('ERROR: Transacción fallida para producto ID ', p_id), 3, 3, p_user_id);
    END;

    -- Asignación de valores después de las declaraciones
    SET v_price = (RAND() * 200 + 50);
    SET v_qty = FLOOR(RAND() * 500 + 50);

    START TRANSACTION;
        INSERT INTO Products (productID, name, productTypeID, categoryID, description, measurementId, enabled, createdAt)
        VALUES (p_id, p_name, p_type_id, p_cat_id, 'Materia prima exótica en bulk.', p_meas_id, TRUE, NOW());

        INSERT INTO ProductsXWebSite (productXWebSiteID, productID, webSiteID, quantity, price, enabled, createdAt)
        VALUES (p_id, p_id, p_website_id, v_qty, v_price, TRUE, NOW());

        INSERT INTO InventoryControls (inventoryID, productID, websiteID, stockQuantity, minStockLevel, enabled, createdAt)
        VALUES (p_id, p_id, p_website_id, v_qty, 20, TRUE, NOW());

        CALL sp_register_step_log(CONCAT('Producto y stock vinculados a Web ID ', p_website_id, ': ', p_name), 1, 1, p_user_id);
    COMMIT;
END$$

/* -----------------------------------------------------
   4. ORQUESTACIÓN DEL LLENADO
   ----------------------------------------------------- */
DROP PROCEDURE IF EXISTS sp_orchestrate_filling$$
CREATE PROCEDURE sp_orchestrate_filling()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_uid INT DEFAULT 1;
    DECLARE v_curr_prod_name VARCHAR(100);

    -- 0. Datos maestros mínimos (INSERT IGNORE para evitar errores de duplicidad)
    INSERT IGNORE INTO Users (userID, name, lastName, enabled) VALUES (v_uid, 'System', 'Admin', TRUE);
    INSERT IGNORE INTO EventTypes (eventTypeID, logType) VALUES (1, 'Success'), (3, 'Error');
    INSERT IGNORE INTO Severities (severityID, severityLevel, severityName) VALUES (1, 1, 'Info'), (3, 3, 'Critico');
    INSERT IGNORE INTO Sources (sourceID, sourceName, userID) VALUES (1, 'Transac-Loader', v_uid);
    INSERT IGNORE INTO ProductTypes (productTypeId, typeName) VALUES (1, 'Extractos'), (2, 'Aceites');
    INSERT IGNORE INTO Categories (categoryID, categoryName) VALUES (1, 'Salud Natural'), (2, 'Cosmética');
    INSERT IGNORE INTO Measurements (measurementId, measurementName, measurementSimbol) VALUES (1, 'Caja 20kg', 'C20');
    INSERT IGNORE INTO Configs (configID, layoutTemplate) VALUES (1, 'Modern-Bulk');
    INSERT IGNORE INTO TargetAudiences (targetAudienceID, gender, incomeLevel) VALUES (1, 'B', 'HIGH');

    -- 1. CARGA DE 5 PAÍSES
    CALL sp_insert_country_trans(1, 'Nicaragua', 'República de Nicaragua', 'NIC', 0.1500, v_uid);
    CALL sp_insert_country_trans(2, 'Costa Rica', 'República de Costa Rica', 'CRI', 0.1300, v_uid);
    CALL sp_insert_country_trans(3, 'Marruecos', 'Reino de Marruecos', 'MAR', 0.1000, v_uid);
    CALL sp_insert_country_trans(4, 'Tailandia', 'Reino de Tailandia', 'THA', 0.0700, v_uid);
    CALL sp_insert_country_trans(5, 'Egipto', 'República Árabe de Egipto', 'EGY', 0.1400, v_uid);

    -- 2. CARGA DE 9 SITIOS WEB
    SET i = 1;
    WHILE i <= 9 DO
        INSERT IGNORE INTO WebSites (webSiteID, webSiteName, URL, countryID, targetAudience, configID, enabled)
        VALUES (i, CONCAT('Etheria Global Web ', i), CONCAT('https://site', i, '.etheria.com'), (i % 5) + 1, 1, 1, TRUE);
        SET i = i + 1;
    END WHILE;

    -- 3. CARGA DE 100 PRODUCTOS
    SET i = 1;
    WHILE i <= 100 DO
        SET v_curr_prod_name = ELT(FLOOR(1 + (RAND() * 4)), 'Aceite Batana', 'Resina Copaiba', 'Extracto Reishi', 'Curcuma Medicinal');
        CALL sp_insert_product_full_trans(
            i, 
            CONCAT(v_curr_prod_name, ' bulk-', i), 
            (i % 2) + 1, 
            (i % 2) + 1, 
            1, 
            (i % 9) + 1, 
            v_uid
        );
        SET i = i + 1;
    END WHILE;
    
    CALL sp_register_step_log('Orquestación de llenado masivo completada con éxito', 1, 1, v_uid);
END$$

DELIMITER ;

-- Ejecución
CALL sp_orchestrate_filling();
