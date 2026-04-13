-- Crear base de datos
CREATE DATABASE IF NOT EXISTS Dynamic;
USE Dynamic;

-- 1. Tablas de Configuración Regional
CREATE TABLE Ubicaciones (
    ubicacionId INT AUTO_INCREMENT PRIMARY KEY,
    pais VARCHAR(20) NOT NULL,
    provincia VARCHAR(20),
    ciudad VARCHAR(20),
    direccion VARCHAR(128)
) ENGINE=InnoDB;

CREATE TABLE PreciosLocales (
    precioLocalId INT AUTO_INCREMENT PRIMARY KEY,
    moneda VARCHAR(20),
    simbolo CHAR(1),
    tasaCambio DECIMAL(10,5),
    activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- 2. Integración con Etheria (Capa de abstracción)
CREATE TABLE ProductosRemotos (
    productoRemotoId INT AUTO_INCREMENT PRIMARY KEY,
    productoID INT NOT NULL, -- FK Virtual a PostgreSQL
    nombre VARCHAR(40),
    precioLocalID INT,
    enExistencia BOOLEAN,
    FOREIGN KEY (precioLocalID) REFERENCES PreciosLocales(precioLocalId)
) ENGINE=InnoDB; 
-- Nota: Si fuera FEDERATED real, se agregaría ENGINE=FEDERATED CONNECTION='...'

-- 3. Gestión de Sitios Dinámicos (IA)
CREATE TABLE SitiosWeb (
    sitioWebID INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(32) NOT NULL,
    URL VARCHAR(100),
    logo_url TEXT,
    enfoque VARCHAR(256),
    ubicacionID INT,
    abierto BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (ubicacionID) REFERENCES Ubicaciones(ubicacionId)
) ENGINE=InnoDB;

CREATE TABLE ProductosXSitioWeb (
    productosXSitioWebID INT AUTO_INCREMENT PRIMARY KEY,
    productoRemotoID INT,
    SitioWebID INT,
    FOREIGN KEY (productoRemotoID) REFERENCES ProductosRemotos(productoRemotoId),
    FOREIGN KEY (SitioWebID) REFERENCES SitiosWeb(sitioWebID)
) ENGINE=InnoDB;

-- 4. Clientes y Ventas
CREATE TABLE Clientes (
    clienteID INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(32),
    email VARCHAR(32),
    ubicacionID INT,
    FOREIGN KEY (ubicacionID) REFERENCES Ubicaciones(ubicacionId)
) ENGINE=InnoDB;

CREATE TABLE Ordenes (
    ordenID INT AUTO_INCREMENT PRIMARY KEY,
    sitioWebID INT,
    descripcion VARCHAR(256),
    clienteID INT,
    fechaCreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    precioLocalId INT,
    estado VARCHAR(9), -- Entregada, activa, cancelada
    FOREIGN KEY (sitioWebID) REFERENCES SitiosWeb(sitioWebID),
    FOREIGN KEY (clienteID) REFERENCES Clientes(clienteID),
    FOREIGN KEY (precioLocalId) REFERENCES PreciosLocales(precioLocalId)
) ENGINE=InnoDB;

CREATE TABLE ProductosXOrden (
    productosXOrdenID INT AUTO_INCREMENT PRIMARY KEY,
    productoRemotoID INT,
    cantidad INTEGER,
    ordenID INT,
    FOREIGN KEY (productoRemotoID) REFERENCES ProductosRemotos(productoRemotoId),
    FOREIGN KEY (ordenID) REFERENCES Ordenes(ordenID)
) ENGINE=InnoDB;

-- 5. Logística y Distribución
CREATE TABLE CourierServices (
    courierServiceID INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(32),
    ubicacionID INT,
    FOREIGN KEY (ubicacionID) REFERENCES Ubicaciones(ubicacionId)
) ENGINE=InnoDB;

CREATE TABLE Paquetes (
    paqueteID INT AUTO_INCREMENT PRIMARY KEY,
    sitioWebEncargadoID INT,
    ubicacionActualID INT,
    ubicacionDestinoID INT,
    requisitosLegales VARCHAR(256),
    permisosDeSalud VARCHAR(256),
    courierServiceID INT,
    clienteID INT,
    FOREIGN KEY (sitioWebEncargadoID) REFERENCES SitiosWeb(sitioWebID),
    FOREIGN KEY (ubicacionActualID) REFERENCES Ubicaciones(ubicacionId),
    FOREIGN KEY (ubicacionDestinoID) REFERENCES Ubicaciones(ubicacionId),
    FOREIGN KEY (courierServiceID) REFERENCES CourierServices(courierServiceID),
    FOREIGN KEY (clienteID) REFERENCES Clientes(clienteID)
) ENGINE=InnoDB;

CREATE TABLE ProductosXPaquete (
    productosXPaqueteID INT AUTO_INCREMENT PRIMARY KEY,
    productoRemotoID INT,
    cantidad INTEGER,
    paqueteID INT,
    FOREIGN KEY (productoRemotoID) REFERENCES ProductosRemotos(productoRemotoId),
    FOREIGN KEY (paqueteID) REFERENCES Paquetes(paqueteID)
) ENGINE=InnoDB;