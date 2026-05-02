USE `Dynamic`;

DELIMITER $$

/* ====================================================================
   1. SP INDEPENDIENTE DE BITÁCORA (LOGS)
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
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;

    SELECT IFNULL(MAX(logID), 0) + 1 INTO v_next_log_id FROM Logs;
    
    INSERT INTO Logs (
        logID, eventTypeID, description, sourceID, severityID, userID
    )
    VALUES (
        v_next_log_id, p_event_type_id, p_description, 1, p_severity_id, p_user_id
    );
END$$


/* ====================================================================
   2. SP TRANSACCIONAL: CREACIÓN DE SITIOS WEB
   ==================================================================== */
DROP PROCEDURE IF EXISTS sp_create_whitelabel_site$$
CREATE PROCEDURE sp_create_whitelabel_site(
    IN p_site_id INT,
    IN p_site_name VARCHAR(50),
    IN p_country_id INT,
    IN p_logo_url VARCHAR(255),
    IN p_focus VARCHAR(255),
    IN p_user_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        CALL sp_register_step_log(CONCAT('ERROR: Fallo al crear sitio: ', p_site_name), 3, 3, p_user_id);
    END;

    START TRANSACTION;
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
            1, 
            1, 
            TRUE
        );

        INSERT INTO Marketing (marketingID, websiteID, section, content, imageURL)
        VALUES (
            p_site_id, p_site_id, 'Hero', 
            CONCAT('Enfoque especializado en: ', p_focus),
            p_logo_url
        );

        CALL sp_register_step_log(CONCAT('EXITO: Creado sitio: ', p_site_name), 1, 1, p_user_id);
    COMMIT;
END$$


/* ====================================================================
   3. SP TRANSACCIONAL: ASIGNACIÓN DE PRODUCTOS
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
        CALL sp_register_step_log(CONCAT('ERROR: Fallo asignando prod ', p_product_id), 3, 3, p_user_id);
    END;

    SET v_price = (RAND() * 500 + 10);
    SET v_qty = FLOOR(RAND() * 200 + 50);

    START TRANSACTION;
        SELECT IFNULL(MAX(productXWebSiteID), 0) + 1 INTO v_link_id FROM ProductsXWebSite;

        INSERT INTO ProductsXWebSite (
            productXWebSiteID, productID, webSiteID, quantity, currencyID, price, enabled
        )
        VALUES (
            v_link_id, p_product_id, p_site_id, v_qty, p_currency_id, v_price, TRUE
        );

        INSERT INTO InventoryControls (
            inventoryID, productID, websiteID, stockQuantity, minStockLevel, enabled
        )
        VALUES (
            v_link_id, p_product_id, p_site_id, v_qty, 20, TRUE
        );

        CALL sp_register_step_log(CONCAT('EXITO: Prod ', p_product_id, ' en sitio ', p_site_id), 1, 1, p_user_id);
    COMMIT;
END$$


/* ====================================================================
   4. ORQUESTACIÓN
   ==================================================================== */
DROP PROCEDURE IF EXISTS sp_orchestrate_filling$$
CREATE PROCEDURE sp_orchestrate_filling()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE j INT DEFAULT 1; 
    DECLARE v_admin_id INT DEFAULT 1;
    DECLARE v_country_index INT;

    -- A. SETUP BÁSICO
    INSERT IGNORE INTO Users (userID, name, lastName, email, enabled) 
    VALUES (v_admin_id, 'System', 'Admin', 'admin@dynamicbrands.com', TRUE);
    
    INSERT IGNORE INTO EventTypes (eventTypeID, logType, enabled) VALUES (1, 'Success', TRUE), (3, 'Error', TRUE);
    INSERT IGNORE INTO Severities (severityID, severityLevel, severityName, enabled) VALUES (1, 1, 'Info', TRUE), (3, 3, 'Critico', TRUE);
    INSERT IGNORE INTO Sources (sourceID, sourceName, userID) VALUES (1, 'Orchestrator', v_admin_id);
    INSERT IGNORE INTO Configs (configID, layoutTemplate) VALUES (1, 'WhiteLabel-AI-Template');
    INSERT IGNORE INTO TargetAudiences (targetAudienceID, gender, incomeLevel) VALUES (1, 'A', 'HIGH');
    INSERT IGNORE INTO Measurements (measurementId, measurementName, enabled) VALUES (1, 'Unidad', TRUE);
    INSERT IGNORE INTO ProductTypes (productTypeId, typeName, enabled) VALUES (1, 'Salud Natural', TRUE), (2, 'Cosmética', TRUE);
    INSERT IGNORE INTO Categories (categoryID, categoryName, enabled) VALUES (1, 'Extractos', TRUE), (2, 'Aceites Esenciales', TRUE);

    -- B. PAÍSES Y MONEDAS
    INSERT IGNORE INTO Countries (countryID, countryCommonName, isoCode, taxRate, enabled) VALUES 
    (1, 'Colombia', 'COL', 0.19, TRUE),
    (2, 'Perú', 'PER', 0.18, TRUE),
    (3, 'México', 'MEX', 0.16, TRUE),
    (4, 'Chile', 'CHL', 0.19, TRUE),
    (5, 'Costa Rica', 'CRI', 0.13, TRUE);

    INSERT IGNORE INTO Currencies (currencyID, currencySymbol, currencyName, countryID) VALUES 
    (1, '$', 'COP', 1), (2, 'S/', 'PEN', 2), (3, '$', 'MXN', 3), (4, '$', 'CLP', 4), (5, '₡', 'CRC', 5);

    -- C. 100 PRODUCTOS BASE
    SET i = 1;
    WHILE i <= 100 DO
        INSERT IGNORE INTO Products (productID, name, productTypeID, categoryID, measurementId, enabled)
        VALUES (i, CONCAT('Producto Base #', i), (i % 2) + 1, (i % 2) + 1, 1, TRUE);
        SET i = i + 1;
    END WHILE;

    -- D. 9 SITIOS Y ASIGNACIÓN
    SET i = 1;
    WHILE i <= 9 DO
        SET v_country_index = ((i - 1) % 5) + 1;

        CALL sp_create_whitelabel_site(
            i, CONCAT('Marca Blanca AI ', i), v_country_index, 
            CONCAT('https://assets.dynamic.com/logos/', i, '.png'), 
            ELT(FLOOR(1 + (RAND() * 3)), 'Salud Holística', 'Dermatología Premium', 'Nutrición Natural'), 
            v_admin_id
        );

        SET j = 1;
        WHILE j <= 12 DO
            IF ((i - 1) * 12 + j) <= 100 THEN
                CALL sp_assign_product_to_site(((i - 1) * 12 + j), i, v_country_index, v_admin_id);
            END IF;
            SET j = j + 1;
        END WHILE;
        SET i = i + 1;
    END WHILE;

    CALL sp_register_step_log('FIN: Orquestacion completada.', 1, 1, v_admin_id);
END$$

DELIMITER ;USE `Dynamic`;

DELIMITER $$

/* ====================================================================
   1. SP INDEPENDIENTE DE BITÁCORA (LOGS)
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
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;

    SELECT IFNULL(MAX(logID), 0) + 1 INTO v_next_log_id FROM Logs;
    
    INSERT INTO Logs (
        logID, eventTypeID, description, sourceID, severityID, userID
    )
    VALUES (
        v_next_log_id, p_event_type_id, p_description, 1, p_severity_id, p_user_id
    );
END$$


/* ====================================================================
   2. SP TRANSACCIONAL: CREACIÓN DE SITIOS WEB
   ==================================================================== */
DROP PROCEDURE IF EXISTS sp_create_whitelabel_site$$
CREATE PROCEDURE sp_create_whitelabel_site(
    IN p_site_id INT,
    IN p_site_name VARCHAR(50),
    IN p_country_id INT,
    IN p_logo_url VARCHAR(255),
    IN p_focus VARCHAR(255),
    IN p_user_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        CALL sp_register_step_log(CONCAT('ERROR: Fallo al crear sitio: ', p_site_name), 3, 3, p_user_id);
    END;

    START TRANSACTION;
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
            1, 
            1, 
            TRUE
        );

        INSERT INTO Marketing (marketingID, websiteID, section, content, imageURL)
        VALUES (
            p_site_id, p_site_id, 'Hero', 
            CONCAT('Enfoque especializado en: ', p_focus),
            p_logo_url
        );

        CALL sp_register_step_log(CONCAT('EXITO: Creado sitio: ', p_site_name), 1, 1, p_user_id);
    COMMIT;
END$$


/* ====================================================================
   3. SP TRANSACCIONAL: ASIGNACIÓN DE PRODUCTOS
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
        CALL sp_register_step_log(CONCAT('ERROR: Fallo asignando prod ', p_product_id), 3, 3, p_user_id);
    END;

    SET v_price = (RAND() * 500 + 10);
    SET v_qty = FLOOR(RAND() * 200 + 50);

    START TRANSACTION;
        SELECT IFNULL(MAX(productXWebSiteID), 0) + 1 INTO v_link_id FROM ProductsXWebSite;

        INSERT INTO ProductsXWebSite (
            productXWebSiteID, productID, webSiteID, quantity, currencyID, price, enabled
        )
        VALUES (
            v_link_id, p_product_id, p_site_id, v_qty, p_currency_id, v_price, TRUE
        );

        INSERT INTO InventoryControls (
            inventoryID, productID, websiteID, stockQuantity, minStockLevel, enabled
        )
        VALUES (
            v_link_id, p_product_id, p_site_id, v_qty, 20, TRUE
        );

        CALL sp_register_step_log(CONCAT('EXITO: Prod ', p_product_id, ' en sitio ', p_site_id), 1, 1, p_user_id);
    COMMIT;
END$$


/* ====================================================================
   4. ORQUESTACIÓN
   ==================================================================== */
DROP PROCEDURE IF EXISTS sp_orchestrate_filling$$
CREATE PROCEDURE sp_orchestrate_filling()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE j INT DEFAULT 1; 
    DECLARE v_admin_id INT DEFAULT 1;
    DECLARE v_country_index INT;

    -- A. SETUP BÁSICO
    INSERT IGNORE INTO Users (userID, name, lastName, email, enabled) 
    VALUES (v_admin_id, 'System', 'Admin', 'admin@dynamicbrands.com', TRUE);
    
    INSERT IGNORE INTO EventTypes (eventTypeID, logType, enabled) VALUES (1, 'Success', TRUE), (3, 'Error', TRUE);
    INSERT IGNORE INTO Severities (severityID, severityLevel, severityName, enabled) VALUES (1, 1, 'Info', TRUE), (3, 3, 'Critico', TRUE);
    INSERT IGNORE INTO Sources (sourceID, sourceName, userID) VALUES (1, 'Orchestrator', v_admin_id);
    INSERT IGNORE INTO Configs (configID, layoutTemplate) VALUES (1, 'WhiteLabel-AI-Template');
    INSERT IGNORE INTO TargetAudiences (targetAudienceID, gender, incomeLevel) VALUES (1, 'A', 'HIGH');
    INSERT IGNORE INTO Measurements (measurementId, measurementName, enabled) VALUES (1, 'Unidad', TRUE);
    INSERT IGNORE INTO ProductTypes (productTypeId, typeName, enabled) VALUES (1, 'Salud Natural', TRUE), (2, 'Cosmética', TRUE);
    INSERT IGNORE INTO Categories (categoryID, categoryName, enabled) VALUES (1, 'Extractos', TRUE), (2, 'Aceites Esenciales', TRUE);

    -- B. PAÍSES Y MONEDAS
    INSERT IGNORE INTO Countries (countryID, countryCommonName, isoCode, taxRate, enabled) VALUES 
    (1, 'Colombia', 'COL', 0.19, TRUE),
    (2, 'Perú', 'PER', 0.18, TRUE),
    (3, 'México', 'MEX', 0.16, TRUE),
    (4, 'Chile', 'CHL', 0.19, TRUE),
    (5, 'Costa Rica', 'CRI', 0.13, TRUE);

    INSERT IGNORE INTO Currencies (currencyID, currencySymbol, currencyName, countryID) VALUES 
    (1, '$', 'COP', 1), (2, 'S/', 'PEN', 2), (3, '$', 'MXN', 3), (4, '$', 'CLP', 4), (5, '₡', 'CRC', 5);

    -- C. 100 PRODUCTOS BASE
    SET i = 1;
    WHILE i <= 100 DO
        INSERT IGNORE INTO Products (productID, name, productTypeID, categoryID, measurementId, enabled)
        VALUES (i, CONCAT('Producto Base #', i), (i % 2) + 1, (i % 2) + 1, 1, TRUE);
        SET i = i + 1;
    END WHILE;

    -- D. 9 SITIOS Y ASIGNACIÓN
    SET i = 1;
    WHILE i <= 9 DO
        SET v_country_index = ((i - 1) % 5) + 1;

        CALL sp_create_whitelabel_site(
            i, CONCAT('Marca Blanca AI ', i), v_country_index, 
            CONCAT('https://assets.dynamic.com/logos/', i, '.png'), 
            ELT(FLOOR(1 + (RAND() * 3)), 'Salud Holística', 'Dermatología Premium', 'Nutrición Natural'), 
            v_admin_id
        );

        SET j = 1;
        WHILE j <= 12 DO
            IF ((i - 1) * 12 + j) <= 100 THEN
                CALL sp_assign_product_to_site(((i - 1) * 12 + j), i, v_country_index, v_admin_id);
            END IF;
            SET j = j + 1;
        END WHILE;
        SET i = i + 1;
    END WHILE;

    CALL sp_register_step_log('FIN: Orquestacion completada.', 1, 1, v_admin_id);
END$$

DELIMITER ;

-- Ejecución final
CALL sp_orchestrate_filling();

-- Ejecución final
CALL sp_orchestrate_filling();