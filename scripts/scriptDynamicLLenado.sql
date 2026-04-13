USE Dynamic;

-- 1. Tabla de Logs
CREATE TABLE IF NOT EXISTS LogTransacciones (
    logId INT AUTO_INCREMENT PRIMARY KEY,
    procedimiento VARCHAR(100),
    mensaje TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. SP de Registro
DELIMITER //
CREATE PROCEDURE sp_registrar_log(IN p_proc VARCHAR(100), IN p_msg TEXT)
BEGIN
    INSERT INTO LogTransacciones (procedimiento, mensaje) VALUES (p_proc, p_msg);
END //

-- 3. SP Transaccional para insertar Sitios Web (IA)
CREATE PROCEDURE sp_crear_sitio_ia(
    IN p_nombre VARCHAR(32), IN p_url VARCHAR(100), 
    IN p_enfoque VARCHAR(256), IN p_ubicacion_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @p1 = MESSAGE_TEXT;
        CALL sp_registrar_log('sp_crear_sitio_ia', CONCAT('ERROR: ', @p1));
        ROLLBACK;
    END;

    START TRANSACTION;
        INSERT INTO SitiosWeb (nombre, URL, enfoque, ubicacionID, abierto)
        VALUES (p_nombre, p_url, p_enfoque, p_ubicacion_id, TRUE);
        
        CALL sp_registrar_log('sp_crear_sitio_ia', CONCAT('Sitio IA desplegado: ', p_nombre));
    COMMIT;
END //

-- 4. Orquestador de Llenado
CREATE PROCEDURE sp_orquestar_llenado_dynamic()
BEGIN
    -- Cargar 5 Países
    INSERT INTO Ubicaciones (pais, provincia, ciudad) VALUES 
    ('Colombia', 'Bogotá', 'Bogotá'), ('Perú', 'Lima', 'Lima'), 
    ('Chile', 'Santiago', 'Santiago'), ('México', 'CDMX', 'CDMX'), ('Nicaragua', 'Rivas', 'San Juan');

    -- Cargar 9 Sitios Web Dinámicos vía SP
    CALL sp_crear_sitio_ia('BioGlow Colombia', 'bioglow.co', 'Enfoque Dermatológico Premium', 1);
    CALL sp_crear_sitio_ia('Esencia Inca', 'esenciainca.pe', 'Aromaterapia Ancestral', 2);
    -- ... repetir hasta 9
END //
DELIMITER ;

CALL sp_orquestar_llenado_dynamic();
