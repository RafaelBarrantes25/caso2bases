-- ORQUESTADOR DE CARGA MASIVA ETHERIA
CREATE OR REPLACE PROCEDURE sp_orquestador_llenado_etheria()
LANGUAGE plpgsql AS $$
DECLARE
    i INT;
    v_nombres_base TEXT[] := ARRAY['Aceite', 'Extracto', 'Bálsamo', 'Infusión', 'Esencia', 'Jabón', 'Tónico', 'Crema'];
    v_ingredientes TEXT[] := ARRAY['de Lavanda', 'de Neem', 'de Moringa', 'de Cúrcuma', 'de Sándalo', 'de Aloe Vera', 'de Jengibre', 'de Eucalipto'];
    v_adjetivos TEXT[] := ARRAY['Ancestral', 'Premium', 'Orgánico', 'Purificante', 'Relajante', 'Vitalizante', 'Exótico'];
    v_nombre_final TEXT;
BEGIN
    -- 1. Cargar Países (Requerimiento: 5 países)
    INSERT INTO Countries (countryId, nombre) VALUES 
    (1, 'Costa Rica'), (2, 'Colombia'), (3, 'Perú'), (4, 'México'), (5, 'Panamá')
    ON CONFLICT DO NOTHING;
    
    CALL sp_registrar_log('Orquestador', '5 Países verificados/cargados', 'EXITO');

    -- 2. Cargar 100 Productos (Requerimiento)
    FOR i IN 1..100 LOOP
        -- Generar nombre aleatorio
        v_nombre_final := v_nombres_base[1 + floor(random() * array_length(v_nombres_base, 1))] || ' ' || 
                          v_ingredientes[1 + floor(random() * array_length(v_ingredientes, 1))] || ' ' || 
                          v_adjetivos[1 + floor(random() * array_length(v_adjetivos, 1))];

        INSERT INTO Productos (globalProductId, nombre, tipoProductoId, precioBaseUSD, descontinuado)
        VALUES (
            gen_random_uuid()::text, 
            v_nombre_final || ' (Batch ' || i || ')', 
            (i % 5) + 1, 
            (random() * 85 + 15)::DECIMAL(19,4) -- Precios entre 15 y 100 USD
        );
    END LOOP;

    CALL sp_registrar_log('Orquestador', 'Carga de 100 productos aleatorios completada', 'EXITO');
END;
$$;
