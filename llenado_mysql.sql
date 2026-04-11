-- Llenado masivo en MySQL (Dynamic)
DELIMITER //
CREATE PROCEDURE sp_LlenadoMasivoDynamic()
BEGIN
    DECLARE i INT DEFAULT 1;
    
    -- Insertar 5 Países base
    INSERT INTO Pais (paisOrigen, paisDestino) VALUES 
    ('India', 'Costa Rica'), ('Marruecos', 'México'), 
    ('Egipto', 'Chile'), ('India', 'Colombia'), ('Marruecos', 'Panamá');

    -- Insertar 9 Sitios Web Dinámicos
    WHILE i <= 9 DO
        INSERT INTO SitiosWeb (nombre, URL, enfoque, paísID, abierto)
        VALUES (CONCAT('Tienda_', i), CONCAT('https://tienda', i, '.com'), 'Marketing IA Premium', (i % 5) + 1, 1);
        SET i = i + 1;
    END WHILE;

    -- Insertar 100 Productos
    SET i = 1;
    WHILE i <= 100 DO
        INSERT INTO Productos (nombre, descripcion, precioID, sitioWebID, enExistencia)
        VALUES (CONCAT('Aceite Esencial ', i), 'Propiedades curativas premium', 1, (i % 9) + 1, 1);
        SET i = i + 1;
    END WHILE;
    
    CALL sp_RegistrarPaso('sp_LlenadoMasivoDynamic', 'Carga de 100 productos y 9 sitios completada');
END //
DELIMITER ;

CALL sp_LlenadoMasivoDynamic();
