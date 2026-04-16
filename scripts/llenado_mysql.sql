DELIMITER //

CREATE PROCEDURE sp_llenado_inicial_dynamic()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        CALL sp_log_dynamic('Error Crítico', 'Fallo en la carga inicial de Dynamic Brands');
    END;

    START TRANSACTION;
        -- 1. Cargar Países (Debe coincidir con IDs de Etheria para el reporte)
        INSERT IGNORE INTO Countries (countryId, nombre) VALUES 
        (1, 'Costa Rica'), (2, 'Colombia'), (3, 'Perú'), (4, 'México'), (5, 'Panamá');

        -- 2. Cargar 9 Sitios Web Dinámicos (Requerimiento)
        INSERT IGNORE INTO SitiosWeb (nombre, url, enfoque) VALUES 
        ('BioNatura CR', 'cr.bionatura.com', 'Salud Orgánica'),
        ('Esencia Co', 'co.esencia.com', 'Aromaterapia'),
        ('Dermalux PE', 'pe.dermalux.com', 'Cuidado Capilar'),
        ('PureLife MX', 'mx.purelife.com', 'Jabones Artesanales'),
        ('Vitality PA', 'pa.vitality.com', 'Suplementos Bulk'),
        ('EcoStyle CR', 'cr.ecostyle.com', 'Cosmética Natural'),
        ('Zenith MX', 'mx.zenith.com', 'Aceites Medicinales'),
        ('NaturaFlow CO', 'co.naturaflow.com', 'Bebidas Curativas'),
        ('HealRoot PE', 'pe.healroot.com', 'Raíces Exóticas');

        CALL sp_log_dynamic('Carga Inicial', 'Países y 9 sitios web cargados correctamente');
    COMMIT;
END //

DELIMITER ;
