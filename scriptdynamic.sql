-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS Dynamic;
USE Dynamic;

-- 1. Tabla Pais (Requerida por Precio, SitiosWeb, Clientes, CourierServices y Paquetes)
CREATE TABLE Pais (
    paisId INT AUTO_INCREMENT PRIMARY KEY,
    paisOrigen VARCHAR(20),
    paisDestino VARCHAR(20)
);

-- 2. Tabla Precio (Requerida por Productos)
CREATE TABLE Precio (
    precioId INT AUTO_INCREMENT PRIMARY KEY,
    paisId INT,
    moneda VARCHAR(20),
    tasaCambio DECIMAL(10,5),
    CONSTRAINT fk_precio_pais FOREIGN KEY (paisId) REFERENCES Pais(paisId)
);

-- 3. Tabla SitiosWeb (Requerida por Productos)
CREATE TABLE SitiosWeb (
    sitioWebID INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(32),
    URL VARCHAR(100),
    logo_url TEXT,
    enfoque VARCHAR(256),
    paisID INT,
    abierto BOOLEAN,
    CONSTRAINT fk_sitios_pais FOREIGN KEY (paisID) REFERENCES Pais(paisId)
);

-- 4. Tabla Productos (Requerida por Ordenes y Paquetes)
CREATE TABLE Productos (
    productoId INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(40),
    descripcion VARCHAR(200),
    precioID INT,
    sitioWebID INT,
    enExistencia BOOLEAN,
    CONSTRAINT fk_prod_precio FOREIGN KEY (precioID) REFERENCES Precio(precioId),
    CONSTRAINT fk_prod_sitio FOREIGN KEY (sitioWebID) REFERENCES SitiosWeb(sitioWebID)
);

-- 5. Tabla Marcas (Requerida por Ordenes y Paquetes)
CREATE TABLE Marcas (
    marcaID INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(32)
);

-- 6. Tabla Clientes (Requerida por Ordenes y Paquetes)
CREATE TABLE Clientes (
    clienteID INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(32),
    paisID INT,
    CONSTRAINT fk_cliente_pais FOREIGN KEY (paisID) REFERENCES Pais(paisId)
);

-- 7. Tabla CourierServices (Requerida por Paquetes)
CREATE TABLE CourierServices (
    courierServiceID INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(32),
    paisID INT,
    CONSTRAINT fk_courier_pais FOREIGN KEY (paisID) REFERENCES Pais(paisId)
);

-- 8. Tabla Ordenes
CREATE TABLE Ordenes (
    ordenID INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(256),
    productoID INT,
    cantidad INTEGER,
    marcaID INT,
    clienteID INT,
    realizada TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_orden_prod FOREIGN KEY (productoID) REFERENCES Productos(productoId),
    CONSTRAINT fk_orden_marca FOREIGN KEY (marcaID) REFERENCES Marcas(marcaID),
    CONSTRAINT fk_orden_cliente FOREIGN KEY (clienteID) REFERENCES Clientes(clienteID)
);

-- 9. Tabla Paquetes
CREATE TABLE Paquetes (
    paqueteID INT AUTO_INCREMENT PRIMARY KEY,
    marcaID INT,
    productoID INT,
    paisID INT,
    requisitosLegales VARCHAR(256),
    permisosDeSalud VARCHAR(256),
    courierServiceID INT,
    clienteID INT,
    CONSTRAINT fk_paq_marca FOREIGN KEY (marcaID) REFERENCES Marcas(marcaID),
    CONSTRAINT fk_paq_prod FOREIGN KEY (productoID) REFERENCES Productos(productoId),
    CONSTRAINT fk_paq_pais FOREIGN KEY (paisID) REFERENCES Pais(paisId),
    CONSTRAINT fk_paq_courier FOREIGN KEY (courierServiceID) REFERENCES CourierServices(courierServiceID),
    CONSTRAINT fk_paq_cliente FOREIGN KEY (clienteID) REFERENCES Clientes(clienteID)
);
