-- ====================================================================
-- 1. PROCEDIMIENTOS ALMACENADOS (LOGS E INSERCIÓN)
-- ====================================================================

-- Registro de Logs
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

-- Inserción de Países (Sin columna 'enabled' para evitar Error 42703)
CREATE OR REPLACE PROCEDURE sp_insert_country(
    p_id INT, p_common VARCHAR, p_official VARCHAR, p_iso CHAR(3), p_tax DECIMAL, p_user_id INT
) LANGUAGE plpgsql AS $$
BEGIN
    IF p_iso NOT IN ('NIC', 'CRI', 'PAN', 'HND', 'SLV', 'GTM', 'MEX', 'COL', 'PER', 'ARG', 'CHL', 'BRA') THEN
        RAISE EXCEPTION 'País % no permitido.', p_iso;
    END IF;

    INSERT INTO Countries (countryID, countryCommonName, countryOfficialName, isoCode, taxRate)
    VALUES (p_id, p_common, p_official, p_iso, p_tax)
    ON CONFLICT (countryID) DO NOTHING; 
    
    CALL sp_register_log('País verificado: ' || p_common, 1, 1, 1, p_user_id);
END; $$;

-- Inserción Completa de Producto (Sin 'enabled' en tablas relacionales)
CREATE OR REPLACE PROCEDURE sp_insert_product_full(
    p_id INT, p_name VARCHAR, p_cat_id INT, p_meas_id INT, 
    p_prov_id INT, p_hub_id INT, p_country_id INT, p_user_id INT
) LANGUAGE plpgsql AS $$
DECLARE
    v_price DECIMAL := (random() * 100 + 10)::DECIMAL(19,4);
    v_qty INT := (random() * 500 + 50)::INT;
BEGIN
    -- Tabla base: Products
    INSERT INTO Products (productID, name, categoryID, measurementId)
    VALUES (p_id, p_name, p_cat_id, p_meas_id) ON CONFLICT (productID) DO NOTHING;

    -- Tabla relacional: ProductsXProvider (Error 42703 corregido)
    INSERT INTO ProductsXProvider (productsXProviderId, productId, providerId, price)
    VALUES (p_id, p_id, p_prov_id, v_price) ON CONFLICT (productsXProviderId) DO NOTHING;

    -- Tabla relacional: InventoryXHub
    INSERT INTO InventoryXHub (inventoryId, hubId, productID, quantity)
    VALUES (p_id, p_hub_id, p_id, v_qty) ON CONFLICT (inventoryId) DO NOTHING;

    -- Tabla relacional: Demands
    INSERT INTO Demands (demandId, countryId, productID, quantity)
    VALUES (p_id, p_country_id, p_id, (v_qty * 0.8)::INT) ON CONFLICT (demandId) DO NOTHING;
END; $$;

-- ====================================================================
-- 2. BLOQUE DE EJECUCIÓN (ORQUESTACIÓN)
-- ====================================================================

DO $$
DECLARE
    i INT;
    v_user_id INT := 1;
    v_country_id INT;
    v_hub_id INT;
    v_nombres TEXT[] := ARRAY[
        'Aceite de Chía Orgánico', 'Extracto de Camu Camu', 'Manteca de Cacao Pura', 
        'Infusión de Yerba Mate', 'Bálsamo de Rosa Mosqueta', 'Sérum de Aloe Vera', 
        'Sal Marina de Maras', 'Aceite de Aguacate', 'Incienso de Palo Santo', 
        'Tónico de Guayaba'
    ];
    v_calidades TEXT[] := ARRAY['Premium', 'Exportación', 'Andino', 'Puro', 'Orgánico', 'Selva'];
    v_nombre_final VARCHAR;
BEGIN
    -- Configuración Inicial (Sin 'enabled')
    INSERT INTO Users (userID, name, lastName) 
    VALUES (v_user_id, 'Admin', 'Etheria') ON CONFLICT (userID) DO NOTHING;

    INSERT INTO EventTypes (eventTypeID, logType) 
    VALUES (1, 'Sistema'), (2, 'Usuario'), (3, 'Error') ON CONFLICT DO NOTHING;

    INSERT INTO Sources (sourceID, sourceName, userID) 
    VALUES (1, 'Stored Procedure', v_user_id) ON CONFLICT DO NOTHING;

    INSERT INTO Severities (severityID, severityLevel, severityName) 
    VALUES (1, 1, 'Info'), (2, 2, 'Aviso'), (3, 3, 'Critico') ON CONFLICT DO NOTHING;

    -- Catálogos de Producto
    INSERT INTO Categories (categoryID, categoryName) VALUES 
    (1, 'Superalimentos'), (2, 'Cuidado Natural'), (3, 'Etnobotánica') ON CONFLICT DO NOTHING;

    INSERT INTO Measurements (measurementId, measurementName, measurementSimbol) VALUES 
    (1, 'Litro', 'L'), (2, 'Kilogramo', 'Kg') ON CONFLICT DO NOTHING;

    -- Estructura Geográfica y Proveedores
    CALL sp_insert_country(1, 'Nicaragua', 'Nicaragua', 'NIC', 0.15, v_user_id);
    CALL sp_insert_country(2, 'Costa Rica', 'Costa Rica', 'CRI', 0.13, v_user_id);
    CALL sp_insert_country(3, 'Panamá', 'Panamá', 'PAN', 0.07, v_user_id);
    CALL sp_insert_country(4, 'Colombia', 'Colombia', 'COL', 0.19, v_user_id);
    CALL sp_insert_country(5, 'Guatemala', 'Guatemala', 'GTM', 0.12, v_user_id);

    FOR i IN 1..5 LOOP
        INSERT INTO States (stateID, countryID, stateName) VALUES (i, i, 'Estado ' || i) ON CONFLICT DO NOTHING;
        INSERT INTO Cities (cityID, stateID, cityName) VALUES (i, i, 'Ciudad ' || i) ON CONFLICT DO NOTHING;
        INSERT INTO Addresses (addressID, cityID, address1) VALUES (i, i, 'Dirección Central ' || i) ON CONFLICT DO NOTHING;
        
        INSERT INTO Hubs (hubId, hubName) VALUES (i, 'Hub Logístico ' || i) ON CONFLICT DO NOTHING;
        
        INSERT INTO Providers (providerID, name, addressID) 
        VALUES (i, (ARRAY['Amazonas S.A.', 'Andes Export', 'Caribe Oils', 'Pampa Goods', 'Azteca Nutrients'])[i], i)
        ON CONFLICT (providerID) DO NOTHING;
    END LOOP;

    -- Carga masiva de 100 Productos
    FOR i IN 1..100 LOOP
        v_country_id := (i % 5) + 1;
        v_hub_id := (i % 5) + 1;
        v_nombre_final := v_nombres[(random() * 9 + 1)::int] || ' (' || v_calidades[(random() * 5 + 1)::int] || ') - ' || i;
        
        IF length(v_nombre_final) > 80 THEN
            v_nombre_final := left(v_nombre_final, 77) || '...';
        END IF;

        CALL sp_insert_product_full(i, v_nombre_final, (i % 3) + 1, (i % 2) + 1, (i % 5) + 1, v_hub_id, v_country_id, v_user_id);
    END LOOP;

    RAISE NOTICE 'Carga masiva finalizada exitosamente en Etheria.';
END $$;
