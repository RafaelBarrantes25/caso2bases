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
    -- Eliminadas las comillas de la tabla Logs
    INSERT INTO Logs (
        description, eventTypeID, sourceID, severityID, postTime, userID
    )
    VALUES (
        p_description, p_event_type_id, p_source_id, p_severity_id, NOW(), p_user_id
    );
END;
$$;



CREATE OR REPLACE PROCEDURE sp_insert_country(
    p_id INT, p_common VARCHAR, p_official VARCHAR, p_iso CHAR(3), p_tax DECIMAL, p_user_id INT
) LANGUAGE plpgsql AS $$
BEGIN
    -- Eliminadas las comillas de la tabla Countries
    INSERT INTO Countries (countryID, countryCommonName, countryOfficialName, isoCode, taxRate, enabled)
    VALUES (p_id, p_common, p_official, p_iso, p_tax, TRUE);
    
    CALL sp_register_log('País insertado: ' || p_common, 1, 1, 1, p_user_id);
EXCEPTION WHEN OTHERS THEN
    CALL sp_register_log('Error insertando país: ' || SQLERRM, 1, 1, 3, p_user_id);
    RAISE NOTICE 'Error en país %: %', p_common, SQLERRM;
END; $$;


CREATE OR REPLACE PROCEDURE sp_insert_product_full(
    p_id INT, p_name VARCHAR, p_type_id INT, p_cat_id INT, p_meas_id INT, 
    p_prov_id INT, p_hub_id INT, p_country_id INT, p_user_id INT
) LANGUAGE plpgsql AS $$
DECLARE
    v_price DECIMAL := (random() * 100 + 10)::DECIMAL(19,4);
    v_qty INT := (random() * 500 + 50)::INT;
BEGIN
    -- 1. Insertar Producto (Sin comillas)
    INSERT INTO Products (productID, name, productTypeID, categoryID, measurementId, enabled)
    VALUES (p_id, p_name, p_type_id, p_cat_id, p_meas_id, TRUE);

    -- 2. Conectar con Proveedor (Sin comillas)
    INSERT INTO ProductsXProvider (productsXProviderId, productId, providerId, price, enabled)
    VALUES (p_id, p_id, p_prov_id, v_price, TRUE);

    -- 3. Llenar Inventario en Hub (Sin comillas)
    INSERT INTO InventoryXHub (inventoryId, hubId, productID, quantity, enabled)
    VALUES (p_id, p_hub_id, p_id, v_qty, TRUE);

    -- 4. Registrar Demanda por País (Sin comillas)
    INSERT INTO Demands (demandId, countryId, productID, quantity, enabled)
    VALUES (p_id, p_country_id, p_id, (v_qty * 0.8)::INT, TRUE);

    CALL sp_register_log('Producto y relaciones creadas: ' || p_name, 1, 1, 1, p_user_id);
EXCEPTION WHEN OTHERS THEN
    CALL sp_register_log('Error en flujo de producto: ' || SQLERRM, 1, 1, 3, p_user_id);
    -- En procedimientos, el ROLLBACK se maneja usualmente fuera o con transacciones autónomas,
    -- por ahora lo quitamos para asegurar que el log se guarde si el error es de negocio.
END; $$;




DO $$
DECLARE
    i INT;
    v_user_id INT := 1;
    v_country_id INT;
    v_hub_id INT;
    v_nombres TEXT[] := ARRAY[
        'Aceite Esencial de Argán', 'Extracto de Hongo Reishi', 'Jabón de Karité Puro', 
        'Infusión de Loto Azul', 'Bálsamo Dermatológico de Copaiba', 'Sérum Capilar de Batana', 
        'Sales de Baño del Himalaya', 'Aceite de Moringa Prensado', 'Incienso de Sándalo Real', 
        'Tónico Facial de Agua de Rosas'
    ];
    v_calidades TEXT[] := ARRAY['Medicinal', 'Bulk', 'Marruecos', 'Puro', 'Orgánico', 'Extracto'];
    v_nombre_final VARCHAR;
BEGIN
    -- 0. Usuario Maestro
    INSERT INTO Users (userID, name, lastName, enabled) 
    VALUES (v_user_id, 'Admin', 'Etheria', TRUE) 
    ON CONFLICT (userID) DO NOTHING;

    -- Población de catálogos de soporte para Logs
    INSERT INTO EventTypes (eventTypeID, logType) 
    VALUES (1, 'Sistema'), (2, 'Usuario'), (3, 'Error') 
    ON CONFLICT DO NOTHING;

    INSERT INTO Sources (sourceID, sourceName, userID) 
    VALUES (1, 'Stored Procedure', v_user_id) 
    ON CONFLICT DO NOTHING;

    -- CORRECCIÓN: Nombres de 10 caracteres o menos para cumplir con varchar(10)
    INSERT INTO Severities (severityID, severityLevel, severityName) 
    VALUES 
        (1, 1, 'Info'),      -- 'Informativo' era muy largo
        (2, 2, 'Aviso'), 
        (3, 3, 'Critico') 
    ON CONFLICT DO NOTHING;

    -- 1. Catálogos de Producto
    INSERT INTO ProductTypes (productTypeId, typeName) VALUES 
    (1, 'Cosmética y Cuidado'), (2, 'Suplementos y Alimentos') 
    ON CONFLICT DO NOTHING;

    INSERT INTO Categories (categoryID, categoryName) VALUES 
    (1, 'Aromaterapia'), (2, 'Cuidado Capilar'), (3, 'Dermatología Natural') 
    ON CONFLICT DO NOTHING;

    INSERT INTO Measurements (measurementId, measurementName, measurementSimbol) VALUES 
    (1, 'Caja Bulk 20kg', 'B20'), (2, 'Bidón Industrial 50L', 'D50') 
    ON CONFLICT DO NOTHING;

    -- 2. Países
    CALL sp_insert_country(1, 'Nicaragua', 'República de Nicaragua', 'NIC', 0.15, v_user_id);
    CALL sp_insert_country(2, 'Marruecos', 'Reino de Marruecos', 'MAR', 0.20, v_user_id);
    CALL sp_insert_country(3, 'Tailandia', 'Reino de Tailandia', 'THA', 0.07, v_user_id);
    CALL sp_insert_country(4, 'Costa Rica', 'República de Costa Rica', 'CRI', 0.13, v_user_id);
    CALL sp_insert_country(5, 'Egipto', 'República Árabe de Egipto', 'EGY', 0.14, v_user_id);

    -- 3. Hubs (Logística Caribe)
    FOR i IN 1..9 LOOP
        INSERT INTO Hubs (hubId, hubName, enabled) 
        VALUES (i, CASE i 
            WHEN 1 THEN 'Hub Bluefields' 
            WHEN 2 THEN 'Bodega Pto Cabezas' 
            WHEN 3 THEN 'Aduana El Bluff' 
            ELSE 'Centro Caribe ' || i END, TRUE)
        ON CONFLICT (hubId) DO NOTHING;
    END LOOP;

    -- 4. Proveedores
    FOR i IN 1..5 LOOP
        INSERT INTO Providers (providerID, name, enabled) 
        VALUES (i, (ARRAY['Atlas Botanicals', 'Siam Herbs Corp', 'Nile Essence Ltd', 'Amazonia Raw', 'Global Bulk Oils'])[i], TRUE)
        ON CONFLICT (providerID) DO NOTHING;
    END LOOP;

    -- 5. Carga de 100 Productos
    FOR i IN 1..100 LOOP
        v_country_id := (i % 5) + 1;
        v_hub_id := (i % 9) + 1;
        v_nombre_final := v_nombres[(random() * 9 + 1)::int] || ' (' || v_calidades[(random() * 5 + 1)::int] || ') - ' || i;
        
        -- Verificación de longitud para p_name (varchar 80 en tu tabla)
        IF length(v_nombre_final) > 80 THEN
            v_nombre_final := left(v_nombre_final, 77) || '...';
        END IF;

        CALL sp_insert_product_full(
            i, 
            v_nombre_final, 
            (i % 2) + 1, 
            (i % 3) + 1, 
            (i % 2) + 1, 
            (i % 5) + 1, 
            v_hub_id,
            v_country_id,
            v_user_id
        );
    END LOOP;

    RAISE NOTICE 'Carga masiva finalizada exitosamente para Etheria.';
END $$;