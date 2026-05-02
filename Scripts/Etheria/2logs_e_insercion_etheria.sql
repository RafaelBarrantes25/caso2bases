-- Procedimiento de Logs (Sin cambios significativos, compatible con DDL)
CREATE OR REPLACE PROCEDURE sp_register_log(
    p_description VARCHAR,
    p_event_type_id INT,
    p_source_id INT,
    p_severity_id INT,
    p_user_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Logs (description, eventTypeID, sourceID, severityID, postTime, userID)
    VALUES (p_description, p_event_type_id, p_source_id, p_severity_id, NOW(), p_user_id);
END;
$$;

-- 1. Modificación de sp_insert_country para manejar duplicados
CREATE OR REPLACE PROCEDURE sp_insert_country(
    p_id INT, p_common VARCHAR, p_official VARCHAR, p_iso CHAR(3), p_tax DECIMAL, p_user_id INT
) LANGUAGE plpgsql AS $$
BEGIN
    IF p_iso NOT IN ('NIC', 'CRI', 'PAN', 'HND', 'SLV', 'GTM', 'MEX', 'COL', 'PER', 'ARG', 'CHL', 'BRA') THEN
        RAISE EXCEPTION 'País % no permitido.', p_iso;
    END IF;

    -- Usamos INSERT ... ON CONFLICT para evitar el error de "duplicate key"
    INSERT INTO Countries (countryID, countryCommonName, countryOfficialName, isoCode, taxRate, enabled)
    VALUES (p_id, p_common, p_official, p_iso, p_tax, TRUE)
    ON CONFLICT (countryID) DO NOTHING; 
    
    CALL sp_register_log('País verificado: ' || p_common, 1, 1, 1, p_user_id);
END; $$;

-- 2. Modificación de sp_insert_product_full para manejar duplicados
CREATE OR REPLACE PROCEDURE sp_insert_product_full(
    p_id INT, p_name VARCHAR, p_cat_id INT, p_meas_id INT, 
    p_prov_id INT, p_hub_id INT, p_country_id INT, p_user_id INT
) LANGUAGE plpgsql AS $$
DECLARE
    v_price DECIMAL := (random() * 100 + 10)::DECIMAL(19,4);
    v_qty INT := (random() * 500 + 50)::INT;
BEGIN
    -- Manejo de duplicados en cada tabla relacionada
    INSERT INTO Products (productID, name, categoryID, measurementId, enabled)
    VALUES (p_id, p_name, p_cat_id, p_meas_id, TRUE) ON CONFLICT (productID) DO NOTHING;

    INSERT INTO ProductsXProvider (productsXProviderId, productId, providerId, price, enabled)
    VALUES (p_id, p_id, p_prov_id, v_price, TRUE) ON CONFLICT (productsXProviderId) DO NOTHING;

    INSERT INTO InventoryXHub (inventoryId, hubId, productID, quantity, enabled)
    VALUES (p_id, p_hub_id, p_id, v_qty, TRUE) ON CONFLICT (inventoryId) DO NOTHING;

    INSERT INTO Demands (demandId, countryId, productID, quantity, enabled)
    VALUES (p_id, p_country_id, p_id, (v_qty * 0.8)::INT, TRUE) ON CONFLICT (demandId) DO NOTHING;
END; $$;

DO $$
DECLARE
    i INT;
    v_user_id INT := 1;
    v_country_id INT;
    v_hub_id INT;
    v_nombres TEXT[] := ARRAY[
        'Aceite de Chía Orgánico', 'Extracto de Camu Camu', 'Manteca de Cacao Pura', 
        'Infusión de Yerba Mate', 'Bálsamo de Aceite de Rosa Mosqueta', 'Sérum de Aloe Vera', 
        'Sal Marina de Maras', 'Aceite de Aguacate Prensado', 'Incienso de Palo Santo', 
        'Tónico de Guayaba'
    ];
    v_calidades TEXT[] := ARRAY['Premium', 'Exportación', 'Andino', 'Puro', 'Orgánico', 'Selva'];
    v_nombre_final VARCHAR;
BEGIN
    -- 0. Usuario Maestro
    INSERT INTO Users (userID, name, lastName, enabled) 
    VALUES (v_user_id, 'Admin', 'Etheria', TRUE) 
    ON CONFLICT (userID) DO NOTHING;

    -- Catálogos de Logs
    INSERT INTO EventTypes (eventTypeID, logType) 
    VALUES (1, 'Sistema'), (2, 'Usuario'), (3, 'Error') ON CONFLICT DO NOTHING;

    INSERT INTO Sources (sourceID, sourceName, userID) 
    VALUES (1, 'Stored Procedure', v_user_id) ON CONFLICT DO NOTHING;

    INSERT INTO Severities (severityID, severityLevel, severityName) 
    VALUES (1, 1, 'Info'), (2, 2, 'Aviso'), (3, 3, 'Critico') ON CONFLICT DO NOTHING;

    -- 1. Catálogos de Producto
    INSERT INTO Categories (categoryID, categoryName) VALUES 
    (1, 'Superalimentos'), (2, 'Cuidado Natural'), (3, 'Etnobotánica') 
    ON CONFLICT DO NOTHING;

    INSERT INTO Measurements (measurementId, measurementName, measurementSimbol) VALUES 
    (1, 'Litro', 'L'), (2, 'Kilogramo', 'Kg') ON CONFLICT DO NOTHING;

    -- 2. Países (Solo Latinoamérica)
    CALL sp_insert_country(1, 'Nicaragua', 'Nicaragua', 'NIC', 0.15, v_user_id);
    CALL sp_insert_country(2, 'Costa Rica', 'Costa Rica', 'CRI', 0.13, v_user_id);
    CALL sp_insert_country(3, 'Panama', 'Panama', 'PAN', 0.07, v_user_id);
    CALL sp_insert_country(4, 'Colombia', 'Colombia', 'COL', 0.19, v_user_id);
    CALL sp_insert_country(5, 'Guatemala', 'Guatemala', 'GTM', 0.12, v_user_id);

    -- 3. Hubs
    FOR i IN 1..5 LOOP
        INSERT INTO Hubs (hubId, hubName, enabled) 
        VALUES (i, 'Hub Logístico Latam ' || i, TRUE) ON CONFLICT DO NOTHING;
    END LOOP;

    -- 4. Proveedores
    FOR i IN 1..5 LOOP
        INSERT INTO Providers (providerID, name, enabled) 
        VALUES (i, (ARRAY['Amazonas S.A.', 'Andes Export', 'Caribe Oils', 'Pampa Goods', 'Azteca Nutrients'])[i], TRUE)
        ON CONFLICT (providerID) DO NOTHING;
    END LOOP;

    -- 5. Carga de 100 Productos
    FOR i IN 1..100 LOOP
        v_country_id := (i % 5) + 1;
        v_hub_id := (i % 5) + 1;
        v_nombre_final := v_nombres[(random() * 9 + 1)::int] || ' (' || v_calidades[(random() * 5 + 1)::int] || ') - ' || i;
        
        IF length(v_nombre_final) > 80 THEN
            v_nombre_final := left(v_nombre_final, 77) || '...';
        END IF;

        CALL sp_insert_product_full(
            i, 
            v_nombre_final, 
            (i % 3) + 1, -- categoryID
            (i % 2) + 1, -- measurementId
            (i % 5) + 1, -- providerID
            v_hub_id,
            v_country_id,
            v_user_id
        );
    END LOOP;

    RAISE NOTICE 'Carga masiva LATAM finalizada exitosamente.';
END $$;








DO $$
DECLARE
    i INT;
    v_user_id INT := 1;
    v_country_id INT;
    v_hub_id INT;
    v_address_id INT;
    v_nombres TEXT[] := ARRAY[
        'Aceite de Chía Orgánico', 'Extracto de Camu Camu', 'Manteca de Cacao Pura', 
        'Infusión de Yerba Mate', 'Bálsamo de Aceite de Rosa Mosqueta', 'Sérum de Aloe Vera', 
        'Sal Marina de Maras', 'Aceite de Aguacate Prensado', 'Incienso de Palo Santo', 
        'Tónico de Guayaba'
    ];
    v_calidades TEXT[] := ARRAY['Premium', 'Exportación', 'Andino', 'Puro', 'Orgánico', 'Selva'];
    v_nombre_final VARCHAR;
BEGIN
    -- 0. Configuración de Usuario y Logs
    INSERT INTO Users (userID, name, lastName, enabled) 
    VALUES (v_user_id, 'Admin', 'Etheria', TRUE) ON CONFLICT (userID) DO NOTHING;

    INSERT INTO EventTypes (eventTypeID, logType) 
    VALUES (1, 'Sistema'), (2, 'Usuario'), (3, 'Error') ON CONFLICT DO NOTHING;

    INSERT INTO Sources (sourceID, sourceName, userID) 
    VALUES (1, 'Stored Procedure', v_user_id) ON CONFLICT DO NOTHING;

    INSERT INTO Severities (severityID, severityLevel, severityName) 
    VALUES (1, 1, 'Info'), (2, 2, 'Aviso'), (3, 3, 'Critico') ON CONFLICT DO NOTHING;

    -- 1. Catálogos de Producto
    INSERT INTO Categories (categoryID, categoryName) VALUES 
    (1, 'Superalimentos'), (2, 'Cuidado Natural'), (3, 'Etnobotánica') ON CONFLICT DO NOTHING;

    INSERT INTO Measurements (measurementId, measurementName, measurementSimbol) VALUES 
    (1, 'Litro', 'L'), (2, 'Kilogramo', 'Kg') ON CONFLICT DO NOTHING;

    -- 2. Estructura Geográfica (CORRECCIÓN CRÍTICA)
    -- Insertamos países
    CALL sp_insert_country(1, 'Nicaragua', 'Nicaragua', 'NIC', 0.15, v_user_id);
    CALL sp_insert_country(2, 'Costa Rica', 'Costa Rica', 'CRI', 0.13, v_user_id);
    CALL sp_insert_country(3, 'Panama', 'Panama', 'PAN', 0.07, v_user_id);
    CALL sp_insert_country(4, 'Colombia', 'Colombia', 'COL', 0.19, v_user_id);
    CALL sp_insert_country(5, 'Guatemala', 'Guatemala', 'GTM', 0.12, v_user_id);

    -- Generamos estados, ciudades y direcciones para cada país
    FOR i IN 1..5 LOOP
        -- Estado
        INSERT INTO States (stateID, countryID, stateName, enabled)
        VALUES (i, i, 'Estado Principal ' || i, TRUE) ON CONFLICT DO NOTHING;
        
        -- Ciudad
        INSERT INTO Cities (cityID, stateID, cityName, enabled)
        VALUES (i, i, 'Ciudad Central ' || i, TRUE) ON CONFLICT DO NOTHING;
        
        -- Dirección
        INSERT INTO Addresses (addressID, cityID, address1, enabled)
        VALUES (i, i, 'Calle Principal, Edificio ' || i, TRUE) ON CONFLICT DO NOTHING;
    END LOOP;

    -- 3. Hubs
    FOR i IN 1..5 LOOP
        INSERT INTO Hubs (hubId, hubName, enabled) 
        VALUES (i, 'Hub Logístico Latam ' || i, TRUE) ON CONFLICT DO NOTHING;
    END LOOP;

    -- 4. Proveedores VINCULADOS (CORRECCIÓN CRÍTICA)
    FOR i IN 1..5 LOOP
        INSERT INTO Providers (providerID, name, addressID, enabled) 
        VALUES (
            i, 
            (ARRAY['Amazonas S.A.', 'Andes Export', 'Caribe Oils', 'Pampa Goods', 'Azteca Nutrients'])[i], 
            i, -- Vinculamos a la dirección creada arriba
            TRUE
        ) ON CONFLICT (providerID) DO UPDATE SET addressID = EXCLUDED.addressID;
    END LOOP;

    -- 5. Carga de 100 Productos usando el procedimiento existente[cite: 2]
    FOR i IN 1..100 LOOP
        v_country_id := (i % 5) + 1;
        v_hub_id := (i % 5) + 1;
        v_nombre_final := v_nombres[(random() * 9 + 1)::int] || ' (' || v_calidades[(random() * 5 + 1)::int] || ') - ' || i;
        
        IF length(v_nombre_final) > 80 THEN
            v_nombre_final := left(v_nombre_final, 77) || '...';
        END IF;

        CALL sp_insert_product_full(
            i, 
            v_nombre_final, 
            (i % 3) + 1, -- categoryID
            (i % 2) + 1, -- measurementId
            (i % 5) + 1, -- providerID
            v_hub_id,
            v_country_id,
            v_user_id
        );
    END LOOP;

    RAISE NOTICE 'Carga masiva LATAM con geografía completa finalizada.';
END $$;