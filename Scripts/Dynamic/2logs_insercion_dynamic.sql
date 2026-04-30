USE `dynamic_db`;

-- Usamos DELIMITER para que DBeaver procese los bloques correctamente
DELIMITER $$

/* ====================================================================
   1. SP INDEPENDIENTE DE BITÁCORA (LOGS)
   ====================================================================
   Requerimiento: "Implemente un SP independiente que registre cada paso
   ejecutado en las tablas de destino, este SP es llamado por los otros
   SP de inserción de datos"
   ==================================================================== */
DROP PROCEDURE IF EXISTS sp_register_step_log$$
CREATE PROCEDURE sp_register_step_log(
    IN p_description VARCHAR(255),
    IN p_event_type_id INT,
    IN p_severity_id INT,
    IN p_user_id INT
)
BEGIN
    DECLARE v_next_log_id INT;
    
    -- Manejo de excepción interna para asegurar que el log no detenga el proceso principal
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;

    SELECT IFNULL(MAX(logID), 0) + 1 INTO v_next_log_id FROM Logs;
    
    INSERT INTO Logs (
        logID, eventTypeID, description, sourceID, severityID, postTime, userID
    )
    VALUES (
        v_next_log_id, p_event_type_id, p_description, 1, p_severity_id, NOW(), p_user_id
    );
END$$


/* ====================================================================
   2. SP TRANSACCIONAL: CREACIÓN DE SITIOS WEB (MARCA BLANCA)
   ====================================================================
   Requerimiento: "A partir de parámetros (logo, enfoque, país), la IA 
   despliega tiendas virtuales con marcas blancas."
   ==================================================================== */
DROP PROCEDURE IF EXISTS sp_create_whitelabel_site$$
CREATE PROCEDURE sp_create_whitelabel_site(
    IN p_site_id INT,
    IN p_site_name VARCHAR(32),
    IN p_country_id INT,
    IN p_logo_url VARCHAR(255),
    IN p_focus VARCHAR(255),
    IN p_user_id INT
)
BEGIN
    -- Declaración de Handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        CALL sp_register_step_log(CONCAT('ERROR: Fallo al crear sitio: ', p_site_name), 3, 3, p_user_id);
    END;

    START TRANSACTION;
        -- Requerimiento: Parámetros logo, enfoque, país.
        INSERT INTO WebSites (
            webSiteID, webSiteName, URL, logoURL, focus, countryID, 
            targetAudience, configID, enabled
        )
        VALUES (
            p_site_id, 
            p_site_name, 
            CONCAT('https://www.', REPLACE(LOWER(p_site_name), ' ', ''), '.com'),
            p_logo_url,
            p_focus,
            p_country_id,
            1, -- Asumiendo target audience default
            1, -- Asumiendo config default
            TRUE
        );

        -- Insertamos el marketing que la IA genera distinto para el mismo producto base
        INSERT INTO Marketing (marketingID, websiteID, section, content, imageURL)
        VALUES (
            p_site_id, p_site_id, 'Hero', 
            CONCAT('Enfoque especializado en: ', p_focus),
            p_logo_url
        );

        CALL sp_register_step_log(CONCAT('ÉXITO: Creado sitio dinámico: ', p_site_name), 1, 1, p_user_id);
    COMMIT;
END$$


/* ====================================================================
   3. SP TRANSACCIONAL: ASIGNACIÓN DE PRODUCTOS A LATAM
   ====================================================================
   Requerimiento: "La venta final se realiza en la moneda local del 
   país donde reside el comprador."
   ==================================================================== */
DROP PROCEDURE IF EXISTS sp_assign_product_to_site$$
CREATE PROCEDURE sp_assign_product_to_site(
    IN p_product_id INT,
    IN p_site_id INT,
    IN p_currency_id INT,
    IN p_user_id INT
)
BEGIN
    DECLARE v_price DECIMAL(19,4);
    DECLARE v_qty INT;
    DECLARE v_link_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        CALL sp_register_step_log(CONCAT('ERROR: Fallo asignando prod ', p_product_id, ' al sitio ', p_site_id), 3, 3, p_user_id);
    END;

    -- Generar precio y stock aleatorio para la simulación
    SET v_price = (RAND() * 500 + 10);
    SET v_qty = FLOOR(RAND() * 200 + 50);

    START TRANSACTION;
        SELECT IFNULL(MAX(productXWebSiteID), 0) + 1 INTO v_link_id FROM ProductsXWebSite;

        -- Se asigna el producto al sitio con la moneda correspondiente al país Latam
        INSERT INTO ProductsXWebSite (
            productXWebSiteID, productID, webSiteID, quantity, currencyID, price, enabled, createdAt
        )
        VALUES (
            v_link_id, p_product_id, p_site_id, v_qty, p_currency_id, v_price, TRUE, NOW()
        );

        -- El control de inventario local para ese sitio específico
        INSERT INTO InventoryControls (
            inventoryID, productID, websiteID, stockQuantity, minStockLevel, enabled, createdAt
        )
        VALUES (
            v_link_id, p_product_id, p_site_id, v_qty, 20, TRUE, NOW()
        );

        CALL sp_register_step_log(CONCAT('ÉXITO: Prod ', p_product_id, ' asignado a sitio ', p_site_id, ' (Moneda: ', p_currency_id, ')'), 1, 1, p_user_id);
    COMMIT;
END$$


/* ====================================================================
   4. ORQUESTACIÓN DEL LLENADO MASIVO
   ==================================================================== */
DROP PROCEDURE IF EXISTS sp_orchestrate_filling$$
CREATE PROCEDURE sp_orchestrate_filling()
BEGIN
    -- ¡Regla de MySQL: Todas las declaraciones van primero!
    DECLARE i INT DEFAULT 1;
    DECLARE j INT DEFAULT 1; -- <--- Movido al inicio
    DECLARE v_admin_id INT DEFAULT 1;
    DECLARE v_country_index INT;

    -- ================================================================
    -- A. SETUP BÁSICO: Usuarios y Catálogos Mínimos
    -- ================================================================
    INSERT IGNORE INTO Users (userID, name, lastName, email, enabled) 
    VALUES (v_admin_id, 'System', 'Admin', 'admin@dynamicbrands.com', TRUE);
    
    INSERT IGNORE INTO EventTypes (eventTypeID, logType) VALUES (1, 'Success'), (3, 'Error');
    INSERT IGNORE INTO Severities (severityID, severityLevel, severityName) VALUES (1, 1, 'Info'), (3, 3, 'Critico');
    INSERT IGNORE INTO Sources (sourceID, sourceName, userID) VALUES (1, 'Orchestrator', v_admin_id);
    INSERT IGNORE INTO Configs (configID, layoutTemplate) VALUES (1, 'WhiteLabel-AI-Template');
    INSERT IGNORE INTO TargetAudiences (targetAudienceID, gender, incomeLevel) VALUES (1, 'A', 'HIGH');
    INSERT IGNORE INTO Measurements (measurementId, measurementName) VALUES (1, 'Unidad');
    INSERT IGNORE INTO ProductTypes (productTypeId, typeName) VALUES (1, 'Salud Natural'), (2, 'Cosmética');
    INSERT IGNORE INTO Categories (categoryID, categoryName) VALUES (1, 'Extractos'), (2, 'Aceites Esenciales');

    -- ================================================================
    -- B. CARGA DE 5 PAÍSES DE LATAM Y SUS MONEDAS
    -- ================================================================
    INSERT IGNORE INTO Countries (countryID, countryCommonName, isoCode, taxRate) VALUES 
    (1, 'Colombia', 'COL', 0.19),
    (2, 'Perú', 'PER', 0.18),
    (3, 'México', 'MEX', 0.16),
    (4, 'Chile', 'CHL', 0.19),
    (5, 'Costa Rica', 'CRI', 0.13);

    INSERT IGNORE INTO Currencies (currencyID, currencySymbol, currencyName, countryID) VALUES 
    (1, '$', 'COP', 1), 
    (2, 'S/', 'PEN', 2), 
    (3, '$', 'MXN', 3), 
    (4, '$', 'CLP', 4), 
    (5, '₡', 'CRC', 5);

    -- ================================================================
    -- C. CARGA DE 100 PRODUCTOS BASE
    -- ================================================================
    SET i = 1;
    WHILE i <= 100 DO
        INSERT IGNORE INTO Products (productID, name, productTypeID, categoryID, measurementId, enabled)
        VALUES (
            i, 
            CONCAT('Producto Base de Alta Gama #', i), 
            (i % 2) + 1, 
            (i % 2) + 1, 
            1, 
            TRUE
        );
        SET i = i + 1;
    END WHILE;

    -- ================================================================
    -- D. CARGA DE 9 SITIOS WEB DINÁMICOS Y ASIGNACIÓN DE PRODUCTOS
    -- ================================================================
    SET i = 1;
    WHILE i <= 9 DO
        SET v_country_index = ((i - 1) % 5) + 1;

        -- 1. Crear el sitio dinámico simulando la decisión de la IA
        CALL sp_create_whitelabel_site(
            i, 
            CONCAT('Marca Blanca AI ', i), 
            v_country_index, 
            CONCAT('https://assets.dynamic.com/logos/v', i, '.png'), 
            ELT(FLOOR(1 + (RAND() * 3)), 'Salud Holística', 'Dermatología Premium', 'Nutrición Natural'), 
            v_admin_id
        );

        -- 2. Distribuir productos entre los 9 sitios
        SET j = 1; -- <--- Reseteamos la variable aquí en lugar de declararla
        WHILE j <= 12 DO
            IF ((i - 1) * 12 + j) <= 100 THEN
                CALL sp_assign_product_to_site(
                    ((i - 1) * 12 + j), 
                    i,                  
                    v_country_index,    
                    v_admin_id
                );
            END IF;
            SET j = j + 1;
        END WHILE;

        SET i = i + 1;
    END WHILE;

    CALL sp_register_step_log('FIN: Orquestación completada. 5 países, 9 webs, 100 prods.', 1, 1, v_admin_id);
END$$

DELIMITER ;

-- Ejecución
CALL sp_orchestrate_filling();