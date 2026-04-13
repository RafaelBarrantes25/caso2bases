USE Dynamic;

-- 1. Tabla de Logs
CREATE TABLE IF NOT EXISTS LogAuditoria (
    logId INT AUTO_INCREMENT PRIMARY KEY,
    sp_nombre VARCHAR(100),
    mensaje TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. SP Independiente de Registro
DELIMITER //
CREATE PROCEDURE sp_registrar_evento(IN p_sp VARCHAR(100), IN p_msj TEXT)
BEGIN
    INSERT INTO LogAuditoria (sp_nombre, mensaje) VALUES (p_sp, p_msj);
END //

-- 3. SP Transaccional para Sitios Web
CREATE PROCEDURE sp_insertar_sitio_dynamic(
    IN p_nombre VARCHAR(32), 
    IN p_url VARCHAR(100), 
    IN p_enfoque VARCHAR(256), 
    IN p_ubicacion_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @p1 = MESSAGE_TEXT;
        CALL sp_registrar_evento('sp_insertar_sitio_dynamic', CONCAT('Error en ', p_nombre, ': ', @p1));
        ROLLBACK;
    END;

    START TRANSACTION;
        INSERT INTO SitiosWeb (nombre, URL, logo_url, enfoque, ubicacionID, abierto)
        VALUES (p_nombre, p_url, 'http://cdn.dynamic.ai/logo.png', p_enfoque, p_ubicacion_id, TRUE);
        
        CALL sp_registrar_evento('sp_insertar_sitio_dynamic', CONCAT('Desplegado: ', p_nombre));
    COMMIT;
END //

-- 4. Orquestador de Datos
CREATE PROCEDURE sp_ejecutar_seed_data()
BEGIN
    -- 5 Países de LATAM
    INSERT INTO Ubicaciones (pais, provincia, ciudad, direccion) VALUES 
    ('México', 'CDMX', 'CDMX', 'Centro Logístico N1'),
    ('Colombia', 'Antioquia', 'Medellín', 'Hub Digital'),
    ('Perú', 'Lima', 'Lima', 'Almacén Fiscal'),
    ('Chile', 'Santiago', 'Santiago', 'Distribuidora Sur'),
    ('Costa Rica', 'San José', 'San José', 'Zona Franca');

    -- 9 Sitios Web Dinámicos (Marcas Blancas)
    CALL sp_insertar_sitio_dynamic('NaturaGlow MX', 'naturaglow.mx', 'Enfoque en pieles jóvenes', 1);
    CALL sp_insertar_sitio_dynamic('ZenEssence CO', 'zenessence.co', 'Aromaterapia para el estrés', 2);
    CALL sp_insertar_sitio_dynamic('IncaHealing PE', 'incahealing.pe', 'Medicina ancestral para el cabello', 3);
    CALL sp_insertar_sitio_dynamic('AndinaDerm CL', 'andinaderm.cl', 'Cosmética clínica de alta gama', 4);
    CALL sp_insertar_sitio_dynamic('PurePura CR', 'purepura.cr', 'Aceites esenciales orgánicos', 5);
    CALL sp_insertar_sitio_dynamic('VitalLatam MX', 'vitalmx.com', 'Suplementos alimenticios premium', 1);
    CALL sp_insertar_sitio_dynamic('EcoBeauty CO', 'ecobeauty.co', 'Jabones artesanales de lujo', 2);
    CALL sp_insertar_sitio_dynamic('BioLux PE', 'biolux.pe', 'Cuidado capilar avanzado', 3);
    CALL sp_insertar_sitio_dynamic('AuraVeda CL', 'auraveda.cl', 'Sanación integral y aceites', 4);

    CALL sp_registrar_evento('ORQUESTADOR', 'Semilla de datos cargada correctamente');
END //
DELIMITER ;

-- Ejecución
CALL sp_ejecutar_seed_data();
