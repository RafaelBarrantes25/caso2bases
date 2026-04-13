<<<<<<< HEAD
-- ==========================================
-- 1. Configuración de la Base de Datos
-- ==========================================
-- DROP DATABASE IF EXISTS Etheria;
=======
-- Crear base de datos (Ejecutar por separado si es necesario)
>>>>>>> e3409da52722179cedad994a60b3f1756d5cafc1
-- CREATE DATABASE Etheria;

<<<<<<< HEAD
-- ==========================================
-- 2. Tablas Maestras (Catálogos)
-- ==========================================

-- Catálogo de ubicaciones geográficas para proveedores y logística
=======
-- 1. Tablas Maestras (Sin dependencias)
>>>>>>> e3409da52722179cedad994a60b3f1756d5cafc1
CREATE TABLE Ubicaciones (
    ubicacionId SERIAL PRIMARY KEY,
    pais VARCHAR(20) NOT NULL,
    provincia VARCHAR(20),
    ciudad VARCHAR(20),
    direccion VARCHAR(128)
);

<<<<<<< HEAD
-- Categorías: Bebidas, Cosmética, Aromaterapia, etc.
=======
>>>>>>> e3409da52722179cedad994a60b3f1756d5cafc1
CREATE TABLE TiposDeProducto (
    tipoProductoId SERIAL PRIMARY KEY,
    nombreTipo VARCHAR(20) NOT NULL UNIQUE
);

<<<<<<< HEAD
-- Unidades de medida para el "bulk" (Cajas, Litros, Kg)
=======
>>>>>>> e3409da52722179cedad994a60b3f1756d5cafc1
CREATE TABLE Medidas (
    medidaId SERIAL PRIMARY KEY,
    unidad VARCHAR(20) NOT NULL, -- Ejemplo: 'Caja', 'Litro'
    cantidad_unidades FLOAT -- Cantidad de unidades que contiene la medida
);

<<<<<<< HEAD
-- Registro de proveedores internacionales
CREATE TABLE Proveedores (
    proveedorID SERIAL PRIMARY KEY,
    nombre VARCHAR(32) NOT NULL,
    ubicacionID INTEGER REFERENCES Ubicaciones(ubicacionId) ON DELETE SET NULL
);

-- ==========================================
-- 3. Tabla de Productos (Maestro)
-- ==========================================

CREATE TABLE Productos (
    productoId SERIAL PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    tipoProductoId INTEGER REFERENCES TiposDeProducto(tipoProductoId),
    descripcion VARCHAR(200),
    medidaId INTEGER REFERENCES Medidas(medidaId),
    precioUSD DECIMAL(19, 4) NOT NULL, -- Mayor precisión para productos de alta gama
    stock_actual INTEGER DEFAULT 0,    -- Representa la cantidad en bodega
    descontinuado BOOLEAN DEFAULT FALSE,
    CONSTRAINT stock_minimo CHECK (stock_actual >= 0)
);

-- ==========================================
-- 4. Flujo de Operación (Importaciones)
-- ==========================================

-- Cabecera de la Importación
CREATE TABLE Importaciones (
    importacionID SERIAL PRIMARY KEY,
    proveedorID INTEGER REFERENCES Proveedores(proveedorID) NOT NULL,
    descripcion VARCHAR(256),
    fechaCreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    totalPrecioUSD DECIMAL(19, 4),
    estado VARCHAR(9) CHECK (estado IN ('Entregada', 'activa', 'cancelada')) DEFAULT 'activa'
);

-- Detalle de productos por importación (Relación Muchos a Muchos)
CREATE TABLE ProductosXImportacion (
    productosXImportacionID SERIAL PRIMARY KEY,
    importacionID INTEGER REFERENCES Importaciones(importacionID) ON DELETE CASCADE,
    productoID INTEGER REFERENCES Productos(productoId),
    cantidad INTEGER NOT NULL CHECK (cantidad > 0)
);

=======
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
>>>>>>> e3409da52722179cedad994a60b3f1756d5cafc1
