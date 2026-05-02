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

-- Procedimiento de Países con Validación Latam
CREATE OR REPLACE PROCEDURE sp_insert_country(
    p_id INT, p_common VARCHAR, p_official VARCHAR, p_iso CHAR(3), p_tax DECIMAL, p_user_id INT
) LANGUAGE plpgsql AS $$
BEGIN
    -- Validación simple de ISO para asegurar que son los del bloque LATAM solicitado
    IF p_iso NOT IN ('NIC', 'CRI', 'PAN', 'HND', 'SLV', 'GTM', 'MEX', 'COL', 'PER', 'ARG', 'CHL', 'BRA') THEN
        RAISE EXCEPTION 'El país con ISO % no pertenece a la región permitida (Latinoamérica).', p_iso;
    END IF;

    INSERT INTO Countries (countryID, countryCommonName, countryOfficialName, isoCode, taxRate, enabled)
    VALUES (p_id, p_common, p_official, p_iso, p_tax, TRUE);
    
    CALL sp_register_log('País Latam insertado: ' || p_common, 1, 1, 1, p_user_id);
EXCEPTION 
    WHEN SQLSTATE 'P0001' THEN -- Error personalizado de validación
        CALL sp_register_log('Validación fallida: ' || SQLERRM, 1, 1, 2, p_user_id);
        RAISE NOTICE '%', SQLERRM;
    WHEN OTHERS THEN
        CALL sp_register_log('Error insertando país: ' || SQLERRM, 1, 1, 3, p_user_id);
        RAISE NOTICE 'Error en país %: %', p_common, SQLERRM;
END; $$;

-- Procedimiento de Producto Full (Ajustado a las columnas reales del DDL)
CREATE OR REPLACE PROCEDURE sp_insert_product_full(
    p_id INT, p_name VARCHAR, p_cat_id INT, p_meas_id INT, 
    p_prov_id INT, p_hub_id INT, p_country_id INT, p_user_id INT
) LANGUAGE plpgsql AS $$
DECLARE
    v_price DECIMAL := (random() * 100 + 10)::DECIMAL(19,4);
    v_qty INT := (random() * 500 + 50)::INT;
BEGIN
    -- 1. Insertar Producto (Se eliminó productTypeID ya que no existe en tu CREATE TABLE Products)
    INSERT INTO Products (productID, name, categoryID, measurementId, enabled)
    VALUES (p_id, p_name, p_cat_id, p_meas_id, TRUE);

    -- 2. Conectar con Proveedor (Agregado currencyId por defecto NULL o 1 si existiera)
    INSERT INTO ProductsXProvider (productsXProviderId, productId, providerId, price, enabled)
    VALUES (p_id, p_id, p_prov_id, v_price, TRUE);

    -- 3. Llenar Inventario en Hub
    INSERT INTO InventoryXHub (inventoryId, hubId, productID, quantity, enabled)
    VALUES (p_id, p_hub_id, p_id, v_qty, TRUE);

    -- 4. Registrar Demanda por País
    INSERT INTO Demands (demandId, countryId, productID, quantity, enabled)
    VALUES (p_id, p_country_id, p_id, (v_qty * 0.8)::INT, TRUE);

    CALL sp_register_log('Producto y relaciones creadas: ' || p_name, 1, 1, 1, p_user_id);
EXCEPTION WHEN OTHERS THEN
    CALL sp_register_log('Error en flujo de producto: ' || SQLERRM, 1, 1, 3, p_user_id);
    RAISE NOTICE 'Error en producto %: %', p_name, SQLERRM;
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
    CALL sp_insert_country(1, 'Nicaragua', 'República de Nicaragua', 'NIC', 0.15, v_user_id);
    CALL sp_insert_country(2, 'Costa Rica', 'República de Costa Rica', 'CRI', 0.13, v_user_id);
    CALL sp_insert_country(3, 'Panamá', 'República de Panamá', 'PAN', 0.07, v_user_id);
    CALL sp_insert_country(4, 'Colombia', 'República de Colombia', 'COL', 0.19, v_user_id);
    CALL sp_insert_country(5, 'Guatemala', 'República de Guatemala', 'GTM', 0.12, v_user_id);

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