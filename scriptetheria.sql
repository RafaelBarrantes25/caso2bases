-- Creación de la base de datos
-- CREATE DATABASE Etheria;
-- \c etheria;

-- 1. Tabla TiposDeProducto (Requerida por Productos)
CREATE TABLE TiposDeProducto (
    tipoProductoId SERIAL PRIMARY KEY,
    nombreTipo VARCHAR(20) NOT NULL
);

-- 2. Tabla Medidas (Requerida por Productos)
CREATE TABLE Medidas (
    medidaId SERIAL PRIMARY KEY,
    unidad VARCHAR(20) NOT NULL,
    cantidad FLOAT(5)
);

-- 3. Tabla Paises (Requerida por Proveedores e Import/Export)
CREATE TABLE Paises (
    paisId SERIAL PRIMARY KEY,
    paisOrigen VARCHAR(20),
    paisDestino VARCHAR(20)
);

-- 4. Tabla Precios (Requerida por Productos e Import/Export)
-- Nota: En tu md pusiste precioId FK en Precios, lo definí como PK para que funcione.
CREATE TABLE Precios (
    precioId SERIAL PRIMARY KEY,
    moneda VARCHAR(20) DEFAULT 'USD',
    valor FLOAT(10)
);

-- 5. Tabla Proveedores (Requerida por Productos e Import/Export)
CREATE TABLE Proveedores (
    proveedorID SERIAL PRIMARY KEY,
    nombre VARCHAR(32) NOT NULL,
    paisID INTEGER REFERENCES Paises(paisId)
);

-- 6. Tabla Productos
CREATE TABLE Productos (
    productoId SERIAL PRIMARY KEY,
    medidaId INTEGER REFERENCES Medidas(medidaId),
    precioId INTEGER REFERENCES Precios(precioId),
    -- El paisId se omite según la nota de Ian
    proveedorID INTEGER REFERENCES Proveedores(proveedorID),
    tipoProductoId INTEGER REFERENCES TiposDeProducto(tipoProductoId),
    nombre VARCHAR(40) NOT NULL,
    descripcion VARCHAR(200),
    activo BOOLEAN DEFAULT TRUE
);

-- 7. Tabla Importaciones
CREATE TABLE Importaciones (
    importacionID SERIAL PRIMARY KEY,
    productoID INTEGER REFERENCES Productos(productoId),
    cantidad INTEGER,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    precioID INTEGER REFERENCES Precios(precioId),
    proveedorID INTEGER REFERENCES Proveedores(proveedorID)
);

-- 8. Tabla Exportaciones
CREATE TABLE Exportaciones (
    exportacionID SERIAL PRIMARY KEY,
    productoID INTEGER REFERENCES Productos(productoId),
    cantidad INTEGER,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    precioID INTEGER REFERENCES Precios(precioId),
    proveedorID INTEGER REFERENCES Proveedores(proveedorID)
);
