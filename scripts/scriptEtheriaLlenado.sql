-- 1. Tabla de Logs Centralizada
CREATE TABLE IF NOT EXISTS LogTransacciones (
    logId SERIAL PRIMARY KEY,
    procedimiento VARCHAR(100),
    mensaje TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. SP de Registro (Independiente)
CREATE OR REPLACE PROCEDURE sp_registrar_log(p_procedimiento TEXT, p_mensaje TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO LogTransacciones (procedimiento, mensaje) VALUES (p_procedimiento, p_mensaje);
END;
$$;

-- 3. SP Transaccional para insertar Productos
CREATE OR REPLACE PROCEDURE sp_insertar_producto_bulk(
    p_nombre VARCHAR, p_tipo_id INT, p_desc VARCHAR, 
    p_medida_id INT, p_precio_usd DECIMAL, p_stock INT
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Productos (nombre, tipoProductoId, descripcion, medidaId, precioUSD, stock_actual)
    VALUES (p_nombre, p_tipo_id, p_desc, p_medida_id, p_precio_usd, p_stock);
    
    CALL sp_registrar_log('sp_insertar_producto_bulk', 'Producto insertado: ' || p_nombre);
EXCEPTION WHEN OTHERS THEN
    CALL sp_registrar_log('sp_insertar_producto_bulk', 'ERROR: ' || SQLERRM);
    RAISE;
END;
$$;

-- 4. Orquestador de Llenado (Muestra de los 100 productos)
DO $$
BEGIN
    -- Inserción de Catálogos base primero
    INSERT INTO TiposDeProducto (nombreTipo) VALUES ('Aceites'), ('Dermatología'), ('Capilar');
    INSERT INTO Medidas (unidad, cantidad_unidades) VALUES ('Caja Bulk', 50);
    
    -- Llamada a SPs para productos (Ejemplo de iteración para 100)
    FOR i IN 1..100 LOOP
        CALL sp_insertar_producto_bulk(
            'Producto Exótico ' || i, 
            (MOD(i, 3) + 1), 
            'Descripción medicinal del producto ' || i, 
            1, 
            (RANDOM() * 500 + 50)::DECIMAL(19,4), 
            100
        );
    END LOOP;
END $$;
