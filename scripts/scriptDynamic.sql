<<<<<<< HEAD
-- ==========================================
-- 1. Creación de la Base de Datos
-- ==========================================
CREATE DATABASE IF NOT EXISTS Dynamic;
USE Dynamic;

-- ==========================================
-- 2. Tablas de Soporte (Catálogos)
-- ==========================================

CREATE TABLE Ubicaciones (
    ubicacionId INT AUTO_INCREMENT PRIMARY KEY,
    pais VARCHAR(20) NOT NULL,
    provincia VARCHAR(20),
    ciudad VARCHAR(20),
    direccion VARCHAR(128)
) ENGINE=InnoDB;

CREATE TABLE PreciosLocales (
    precioLocalId INT AUTO_INCREMENT PRIMARY KEY,
    moneda VARCHAR(20) NOT NULL,
    simbolo CHAR(5), -- Cambiado a 5 por si hay símbolos como 'U$S'
    tasaCambio DECIMAL(10,5) NOT NULL,
    activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- ==========================================
-- 3. Productos Remotos (Lógica Federated)
-- ==========================================

-- NOTA: Para que FEDERATED funcione, el motor debe estar activo en MySQL.
-- Si no tienes configurado el servidor remoto, puedes usar InnoDB temporalmente.
CREATE TABLE ProductosRemotos (
    productoRemotoId INT AUTO_INCREMENT PRIMARY KEY,
    productoID INT NOT NULL, -- FK Virtual hacia PostgreSQL de Etheria
    nombre VARCHAR(40),
    precioLocalID INT,
    enExistencia BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_prod_precio FOREIGN KEY (precioLocalID) REFERENCES PreciosLocales(precioLocalId)
) ENGINE=InnoDB; 

-- ==========================================
-- 4. Infraestructura de Sitios Web (IA)
-- ==========================================

CREATE TABLE SitiosWeb (
    sitioWebID INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(32) NOT NULL,
    URL VARCHAR(100) UNIQUE,
=======
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
>>>>>>> e3409da52722179cedad994a60b3f1756d5cafc1
    logo_url TEXT,
    enfoque VARCHAR(256),
    ubicacionID INT,
    abierto BOOLEAN DEFAULT TRUE,
<<<<<<< HEAD
    CONSTRAINT fk_sitio_ubica FOREIGN KEY (ubicacionID) REFERENCES Ubicaciones(ubicacionId)
=======
    FOREIGN KEY (ubicacionID) REFERENCES Ubicaciones(ubicacionId)
>>>>>>> e3409da52722179cedad994a60b3f1756d5cafc1
) ENGINE=InnoDB;

CREATE TABLE ProductosXSitioWeb (
    productosXSitioWebID INT AUTO_INCREMENT PRIMARY KEY,
    productoRemotoID INT,
    SitioWebID INT,
<<<<<<< HEAD
    CONSTRAINT fk_pxs_prod FOREIGN KEY (productoRemotoID) REFERENCES ProductosRemotos(productoRemotoId),
    CONSTRAINT fk_pxs_sitio FOREIGN KEY (SitioWebID) REFERENCES SitiosWeb(sitioWebID)
) ENGINE=InnoDB;

-- ==========================================
-- 5. Gestión de Clientes y Ventas
-- ==========================================

CREATE TABLE Clientes (
    clienteID INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(32) NOT NULL,
    email VARCHAR(32) UNIQUE,
    ubicacionID INT,
    CONSTRAINT fk_cliente_ubica FOREIGN KEY (ubicacionID) REFERENCES Ubicaciones(ubicacionId)
=======
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
>>>>>>> e3409da52722179cedad994a60b3f1756d5cafc1
) ENGINE=InnoDB;

CREATE TABLE Ordenes (
    ordenID INT AUTO_INCREMENT PRIMARY KEY,
    sitioWebID INT,
    descripcion VARCHAR(256),
    clienteID INT,
    fechaCreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
<<<<<<< HEAD
    precioLocalId INT, -- PK en tu nota, pero lógica de negocio dicta FK
    estado VARCHAR(9) NOT NULL,
    CONSTRAINT chk_estado_orden CHECK (estado IN ('Entregada', 'activa', 'cancelada')),
    CONSTRAINT fk_orden_sitio FOREIGN KEY (sitioWebID) REFERENCES SitiosWeb(sitioWebID),
    CONSTRAINT fk_orden_cliente FOREIGN KEY (clienteID) REFERENCES Clientes(clienteID),
    CONSTRAINT fk_orden_precio FOREIGN KEY (precioLocalId) REFERENCES PreciosLocales(precioLocalId)
=======
    precioLocalId INT,
    estado VARCHAR(9), -- Entregada, activa, cancelada
    FOREIGN KEY (sitioWebID) REFERENCES SitiosWeb(sitioWebID),
    FOREIGN KEY (clienteID) REFERENCES Clientes(clienteID),
    FOREIGN KEY (precioLocalId) REFERENCES PreciosLocales(precioLocalId)
>>>>>>> e3409da52722179cedad994a60b3f1756d5cafc1
) ENGINE=InnoDB;

CREATE TABLE ProductosXOrden (
    productosXOrdenID INT AUTO_INCREMENT PRIMARY KEY,
    productoRemotoID INT,
<<<<<<< HEAD
    cantidad INT NOT NULL,
    ordenID INT,
    CONSTRAINT fk_pxo_prod FOREIGN KEY (productoRemotoID) REFERENCES ProductosRemotos(productoRemotoId),
    CONSTRAINT fk_pxo_orden FOREIGN KEY (ordenID) REFERENCES Ordenes(ordenID)
) ENGINE=InnoDB;

-- ==========================================
-- 6. Logística y Envío (Couriers)
-- ==========================================

CREATE TABLE CourierServices (
    courierServiceID INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(32) NOT NULL,
    ubicacionID INT,
    CONSTRAINT fk_courier_ubica FOREIGN KEY (ubicacionID) REFERENCES Ubicaciones(ubicacionId)
=======
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
>>>>>>> e3409da52722179cedad994a60b3f1756d5cafc1
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
<<<<<<< HEAD
    CONSTRAINT fk_paq_sitio FOREIGN KEY (sitioWebEncargadoID) REFERENCES SitiosWeb(sitioWebID),
    CONSTRAINT fk_paq_ubica_act FOREIGN KEY (ubicacionActualID) REFERENCES Ubicaciones(ubicacionId),
    CONSTRAINT fk_paq_ubica_dest FOREIGN KEY (ubicacionDestinoID) REFERENCES Ubicaciones(ubicacionId),
    CONSTRAINT fk_paq_courier FOREIGN KEY (courierServiceID) REFERENCES CourierServices(courierServiceID),
    CONSTRAINT fk_paq_cliente FOREIGN KEY (clienteID) REFERENCES Clientes(clienteID)
=======
    FOREIGN KEY (sitioWebEncargadoID) REFERENCES SitiosWeb(sitioWebID),
    FOREIGN KEY (ubicacionActualID) REFERENCES Ubicaciones(ubicacionId),
    FOREIGN KEY (ubicacionDestinoID) REFERENCES Ubicaciones(ubicacionId),
    FOREIGN KEY (courierServiceID) REFERENCES CourierServices(courierServiceID),
    FOREIGN KEY (clienteID) REFERENCES Clientes(clienteID)
>>>>>>> e3409da52722179cedad994a60b3f1756d5cafc1
) ENGINE=InnoDB;

CREATE TABLE ProductosXPaquete (
    productosXPaqueteID INT AUTO_INCREMENT PRIMARY KEY,
    productoRemotoID INT,
<<<<<<< HEAD
    cantidad INT NOT NULL,
    paqueteID INT,
    CONSTRAINT fk_pxp_prod FOREIGN KEY (productoRemotoID) REFERENCES ProductosRemotos(productoRemotoId),
    CONSTRAINT fk_pxp_paq FOREIGN KEY (paqueteID) REFERENCES Paquetes(paqueteID)
=======
    cantidad INTEGER,
    paqueteID INT,
    FOREIGN KEY (productoRemotoID) REFERENCES ProductosRemotos(productoRemotoId),
    FOREIGN KEY (paqueteID) REFERENCES Paquetes(paqueteID)
>>>>>>> e3409da52722179cedad994a60b3f1756d5cafc1
) ENGINE=InnoDB;