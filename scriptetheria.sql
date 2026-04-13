-- Crear base de datos (Ejecutar por separado si es necesario)
-- CREATE DATABASE Etheria;

-- 1. Tablas Maestras (Sin dependencias)
CREATE TABLE Ubicaciones (
    ubicacionId SERIAL PRIMARY KEY,
    pais VARCHAR(20) NOT NULL,
    provincia VARCHAR(20),
    ciudad VARCHAR(20),
    direccion VARCHAR(128)
);

CREATE TABLE TiposDeProducto (
    tipoProductoId SERIAL PRIMARY KEY,
    nombreTipo VARCHAR(20) NOT NULL
);

CREATE TABLE Medidas (
    medidaId SERIAL PRIMARY KEY,
    unidad VARCHAR(20) NOT NULL,
    cantidad FLOAT(5)
);

-- 2. Entidades Principales
CREATE TABLE Proveedores (
    proveedorID SERIAL PRIMARY KEY,
    nombre VARCHAR(32) NOT NULL,
    ubicacionID INT REFERENCES Ubicaciones(ubicacionId)
);

CREATE TABLE Productos (
    productoId SERIAL PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    tipoProductoId INT REFERENCES TiposDeProducto(tipoProductoId),
    descripcion VARCHAR(200),
    medidaId INT REFERENCES Medidas(medidaId),
    precioUSD DECIMAL(19, 4),
    cantidad INTEGER DEFAULT 0, -- Si <= 0 se solicita importación
    descontinuado BOOLEAN DEFAULT FALSE
);

-- 3. Flujo de Operación (Importaciones)
CREATE TABLE Importaciones (
    importacionID SERIAL PRIMARY KEY,
    proveedorID INT REFERENCES Proveedores(proveedorID),
    descripcion VARCHAR(256),
    fechaCreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    precioUSD DECIMAL(19, 4),
    estado VARCHAR(9) CHECK (estado IN ('Entregada', 'activa', 'cancelada'))
);

CREATE TABLE ProductosXImportacion (
    productosXImportacionID SERIAL PRIMARY KEY,
    productoID INT REFERENCES Productos(productoId),
    cantidad INTEGER NOT NULL,
    importacionID INT REFERENCES Importaciones(importacionID)
);

/*
-- 4. Exportaciones (Se mantiene según requerimiento)
CREATE TABLE Exportaciones (
    exportacionID SERIAL PRIMARY KEY,
    productoID INT REFERENCES Productos(productoId),
    cantidad INTEGER,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    proveedorID INT REFERENCES Proveedores(proveedorID)
);
*/
