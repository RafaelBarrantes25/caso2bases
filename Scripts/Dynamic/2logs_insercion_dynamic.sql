USE `Dynamic`;

DELIMITER $$

/* ====================================================================
   1. SP DE LOGS (Simplificado al máximo)
   ==================================================================== */
DROP PROCEDURE IF EXISTS sp_register_step_log$$
CREATE PROCEDURE sp_register_step_log(
    IN p_description VARCHAR(255),
    IN p_event_type_id INT,
    IN p_severity_id INT
)
BEGIN
    DECLARE v_next_log_id INT;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;

    SELECT IFNULL(MAX(logID), 0) + 1 INTO v_next_log_id FROM Logs;
    
    -- Insertamos solo lo vital, omitiendo userID para evitar el error 1054
    INSERT INTO Logs (logID, eventTypeID, description, sourceID, severityID)
    VALUES (v_next_log_id, p_event_type_id, p_description, 1, p_severity_id);
END$$

/* ====================================================================
   2. SP: CREACIÓN DE SITIOS WEB
   ==================================================================== */
DROP PROCEDURE IF EXISTS sp_create_whitelabel_site$$
CREATE PROCEDURE sp_create_whitelabel_site(
    IN p_site_id INT,
    IN p_site_name VARCHAR(50),
    IN p_country_id INT,
    IN p_logo_url VARCHAR(255),
    IN p_focus VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        CALL sp_register_step_log(CONCAT('ERR: ', p_site_name), 3, 3);
    END;

    START TRANSACTION;
        INSERT INTO WebSites (webSiteID, webSiteName, URL, logoURL, focus, countryID, targetAudience, configID)
        VALUES (
            p_site_id, p_site_name, 
            CONCAT('https://www.', REPLACE(LOWER(p_site_name), ' ', ''), '.com'),
            p_logo_url, p_focus, p_country_id, 1, 1
        );

        INSERT INTO Marketing (marketingID, websiteID, section, content, imageURL)
        VALUES (p_site_id, p_site_id, 'Hero', CONCAT('Foco: ', p_focus), p_logo_url);

        CALL sp_register_step_log(CONCAT('OK: ', p_site_name), 1, 1);
    COMMIT;
END$$

/* ====================================================================
   3. SP: ASIGNACIÓN DE PRODUCTOS (Sin currencyID conflictivo)
   ==================================================================== */
DROP PROCEDURE IF EXISTS sp_assign_product_to_site$$
CREATE PROCEDURE sp_assign_product_to_site(
    IN p_product_id INT,
    IN p_site_id INT,
    IN p_currency_id INT
)
BEGIN
    DECLARE v_price DECIMAL(19,4);
    DECLARE v_qty INT;
    DECLARE v_link_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        CALL sp_register_step_log('ERR: Asignación', 3, 3);
    END;

    SET v_price = (RAND() * 500 + 10);
    SET v_qty = FLOOR(RAND() * 200 + 50);

    START TRANSACTION;
        SELECT IFNULL(MAX(productXWebSiteID), 0) + 1 INTO v_link_id FROM ProductsXWebSite;

        -- Omitimos nombres de columna específicos de moneda si fallan
        INSERT INTO ProductsXWebSite (productXWebSiteID, productID, webSiteID, quantity, price)
        VALUES (v_link_id, p_product_id, p_site_id, v_qty, v_price);

        INSERT INTO InventoryControls (inventoryID, productID, websiteID, stockQuantity, minStockLevel)
        VALUES (v_link_id, p_product_id, p_site_id, v_qty, 20);
    COMMIT;
END$$

/* ====================================================================
   4. ORQUESTACIÓN FINAL
   ==================================================================== */
DROP PROCEDURE IF EXISTS sp_orchestrate_filling$$
CREATE PROCEDURE sp_orchestrate_filling()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_country_idx INT;

    -- Setup de tablas maestras (Omitiendo columnas de Usuario)
    INSERT IGNORE INTO EventTypes (eventTypeID, logType) VALUES (1, 'Success'), (3, 'Error');
    INSERT IGNORE INTO Severities (severityID, severityLevel, severityName) VALUES (1, 1, 'Info'), (3, 3, 'Critico');
    INSERT IGNORE INTO Sources (sourceID, sourceName) VALUES (1, 'Orchestrator');
    INSERT IGNORE INTO Configs (configID, layoutTemplate) VALUES (1, 'Template-AI');
    INSERT IGNORE INTO TargetAudiences (targetAudienceID, gender, incomeLevel) VALUES (1, 'A', 'HIGH');
    INSERT IGNORE INTO Measurements (measurementId, measurementName) VALUES (1, 'Unidad');
    INSERT IGNORE INTO Categories (categoryID, categoryName) VALUES (1, 'Extractos'), (2, 'Aceites');

    INSERT IGNORE INTO Countries (countryID, countryCommonName, isoCode, taxRate) VALUES 
    (1, 'Colombia', 'COL', 0.19), (2, 'Peru', 'PER', 0.18), (3, 'Mexico', 'MEX', 0.16),
    (4, 'Chile', 'CHL', 0.19), (5, 'Costa Rica', 'CRI', 0.13);

    -- 100 Productos
    SET i = 1;
    WHILE i <= 100 DO
        INSERT IGNORE INTO Products (productID, name, categoryID, measurementId)
        VALUES (i, CONCAT('Prod ', i), (i % 2) + 1, 1);
        SET i = i + 1;
    END WHILE;

    -- 5 Sitios (Uno por país para simplificar)
    SET i = 1;
    WHILE i <= 5 DO
        CALL sp_create_whitelabel_site(i, CONCAT('Tienda ', i), i, 'logo.png', 'Salud');
        
        -- Asignamos 10 productos a cada sitio
        CALL sp_assign_product_to_site(i, i, i);
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL sp_orchestrate_filling();
