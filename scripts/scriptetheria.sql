CREATE DATABASE Etheria;
);

CREATE TABLE GlobalProducts (
  globalProductId CHAR(36) PRIMARY KEY,
  tipoProductoId INT REFERENCES TiposDeProducto(tipoProductoId)
);

CREATE TABLE Proveedores (
  proveedorID SERIAL PRIMARY KEY,
  nombre VARCHAR(64),
  emailContacto VARCHAR(254),
  telefonoContacto VARCHAR(20),
  ubicacionID INT REFERENCES Ubicaciones(ubicacionId)
);

CREATE TABLE Productos (
  productoId SERIAL PRIMARY KEY,
  globalProductId CHAR(36) REFERENCES GlobalProducts(globalProductId),
  nombre VARCHAR(80),
  tipoProductoId INT REFERENCES TiposDeProducto(tipoProductoId),
  descripcion VARCHAR(300),
  medidaId INT REFERENCES Medidas(medidaId),
  precioBaseUSD DECIMAL(19,4),
  descontinuado BOOLEAN,
  checksum VARCHAR(64)
);

CREATE TABLE Hubs (
  hubId SERIAL PRIMARY KEY,
  ubicacionID INT REFERENCES Ubicaciones(ubicacionId)
);

CREATE TABLE InventarioHub (
  inventarioId SERIAL PRIMARY KEY,
  hubId INT REFERENCES Hubs(hubId),
  productoID INT REFERENCES Productos(productoId),
  cantidad INT
);

CREATE TABLE MovimientosInventario (
  movimientoId SERIAL PRIMARY KEY,
  productoID INT REFERENCES Productos(productoId),
  tipo VARCHAR(10),
  cantidad INT,
  fecha TIMESTAMP
);

CREATE TABLE EstadosImportacion (
  estadoImportacionId SERIAL PRIMARY KEY,
  nombre VARCHAR(20)
);

CREATE TABLE DemandaImportacion (
  demandaId SERIAL PRIMARY KEY,
  globalProductId CHAR(36) REFERENCES GlobalProducts(globalProductId),
  countryId INT REFERENCES Countries(countryId),
  cantidadDemandada INT,
  fecha TIMESTAMP
);

CREATE TABLE Importaciones (
  importacionID SERIAL PRIMARY KEY,
  proveedorID INT REFERENCES Proveedores(proveedorID),
  demandaId INT REFERENCES DemandaImportacion(demandaId),
  descripcion VARCHAR(256),
  fechaCreacion TIMESTAMP,
  subtotalUSD DECIMAL(19,4),
  impuestosUSD DECIMAL(19,4),
  fleteUSD DECIMAL(19,4),
  totalUSD DECIMAL(19,4),
  estadoImportacionId INT REFERENCES EstadosImportacion(estadoImportacionId),
  creadoPor VARCHAR(64)
);

CREATE TABLE ProductosXImportacion (
  productosXImportacionID SERIAL PRIMARY KEY,
  productoID INT REFERENCES Productos(productoId),
  cantidad INT,
  costoUnitarioUSD DECIMAL(19,4),
  importacionID INT REFERENCES Importaciones(importacionID)
);