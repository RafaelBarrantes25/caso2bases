-- ==========================================
-- 1. Configuración de la Base de Datos
-- ==========================================
-- DROP DATABASE IF EXISTS Etheria;
-- CREATE DATABASE Etheria;
-- \c etheria;

-- ==========================================
-- 2. Tablas Maestras (Catálogos)
-- ==========================================

-- Catálogo de ubicaciones geográficas para proveedores y logística
CREATE TABLE Ubicaciones (
    ubicacionId SERIAL PRIMARY KEY,
    pais VARCHAR(20) NOT NULL,
    provincia VARCHAR(20),
    ciudad VARCHAR(20),
    direccion VARCHAR(128)
);

-- Categorías: Bebidas, Cosmética, Aromaterapia, etc.
CREATE TABLE TiposDeProducto (
    tipoProductoId SERIAL PRIMARY KEY,
    nombreTipo VARCHAR(20) NOT NULL UNIQUE
);

-- Unidades de medida para el "bulk" (Cajas, Litros, Kg)
CREATE TABLE Medidas (
    medidaId SERIAL PRIMARY KEY,
    unidad VARCHAR(20) NOT NULL, -- Ejemplo: 'Caja', 'Litro'
    cantidad_unidades FLOAT -- Cantidad de unidades que contiene la medida
);

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

