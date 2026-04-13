-- ==========================================
-- ETHERIA: SISTEMA DE LOGGING Y CARGA
-- ==========================================

-- 1. Tabla de Logs
CREATE TABLE IF NOT EXISTS LogAuditoria (
    logId SERIAL PRIMARY KEY,
    sp_nombre VARCHAR(100),
    mensaje TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. SP Independiente de Registro
CREATE OR REPLACE PROCEDURE sp_registrar_evento(p_sp VARCHAR, p_msj TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO LogAuditoria (sp_nombre, mensaje) VALUES (p_sp, p_msj);
END;
$$;

-- 3. SP Transaccional para Productos
CREATE OR REPLACE PROCEDURE sp_insertar_producto_etheria(
    p_nombre VARCHAR, 
    p_tipo_id INT, 
    p_desc VARCHAR, 
    p_medida_id INT, 
    p_precio DECIMAL, 
    p_stock INT
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Productos (nombre, tipoProductoId, descripcion, medidaId, precioUSD, stock_actual, descontinuado)
    VALUES (p_nombre, p_tipo_id, p_desc, p_medida_id, p_precio, p_stock, FALSE);
    
    CALL sp_registrar_evento('sp_insertar_producto_etheria', 'Éxito: ' || p_nombre);
EXCEPTION WHEN OTHERS THEN
    CALL sp_registrar_evento('sp_insertar_producto_etheria', 'ERROR en ' || p_nombre || ': ' || SQLERRM);
    RAISE;
END;
$$;

-- 4. Orquestador de Llenado (100 Productos Médicos/Exóticos)
DO $$
DECLARE
    i INT;
    v_tipo INT;
    v_nombres TEXT[] := ARRAY['Aceite de Moringa', 'Bálsamo de Copal', 'Extracto de Neem', 'Té de Tepezcohuite', 'Sérum de Sangre de Grado', 'Jabón de Barro Negro', 'Aceite de Argán', 'Elixir de Cúrcuma', 'Agua de Rosas Búlgara', 'Miel de Abeja Melipona'];
BEGIN
    -- Inserción de Catálogos base
    INSERT INTO TiposDeProducto (nombreTipo) VALUES ('Aromaterapia'), ('Dermatológico'), ('Suplementos');
    INSERT INTO Medidas (unidad, cantidad_unidades) VALUES ('Caja Bulk', 50);

    CALL sp_registrar_evento('ORQUESTADOR', 'Iniciando carga de 100 productos...');

    FOR i IN 1..100 LOOP
        v_tipo := (i % 3) + 1;
        CALL sp_insertar_producto_etheria(
            v_nombres[(i % 10) + 1] || ' Batch-' || i,
            v_tipo,
            'Producto medicinal exótico grado premium, importado en bulk.',
            1,
            (25.50 + (i * 1.5))::DECIMAL(19,4),
            200
        );
    END LOOP;

    CALL sp_registrar_evento('ORQUESTADOR', 'Carga finalizada con éxito.');
END $$;
