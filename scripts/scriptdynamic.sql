CREATE DATABASE Dynamic;
  currencyId INT,
  tasaCambioHistorica DECIMAL(12,6),
  montoTotal DECIMAL(19,4),
  estadoId INT,
  checksum VARCHAR(64),
  FOREIGN KEY (sitioWebID) REFERENCES SitiosWeb(sitioWebID),
  FOREIGN KEY (clienteID) REFERENCES Clientes(clienteID),
  FOREIGN KEY (currencyId) REFERENCES Currencies(currencyId),
  FOREIGN KEY (estadoId) REFERENCES EstadosOrden(estadoId),
  FOREIGN KEY (countryId) REFERENCES Countries(countryId)
);

CREATE TABLE ProductosXOrden (
  productosXOrdenID INT AUTO_INCREMENT PRIMARY KEY,
  productoLocalID INT,
  cantidad INT,
  precioVentaHistorico DECIMAL(19,4),
  ordenID INT,
  FOREIGN KEY (productoLocalID) REFERENCES ProductosLocales(productoLocalId),
  FOREIGN KEY (ordenID) REFERENCES Ordenes(ordenID)
);

CREATE TABLE CourierServices (
  courierServiceID INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(64),
  ubicacionID INT,
  FOREIGN KEY (ubicacionID) REFERENCES Ubicaciones(ubicacionId)
);

CREATE TABLE EstadosEnvio (
  estadoEnvioId INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(20)
);

CREATE TABLE Paquetes (
  paqueteID INT AUTO_INCREMENT PRIMARY KEY,
  ordenID INT,
  ubicacionActualID INT,
  ubicacionDestinoID INT,
  courierServiceID INT,
  estadoEnvioId INT,
  FOREIGN KEY (ordenID) REFERENCES Ordenes(ordenID),
  FOREIGN KEY (ubicacionActualID) REFERENCES Ubicaciones(ubicacionId),
  FOREIGN KEY (ubicacionDestinoID) REFERENCES Ubicaciones(ubicacionId),
  FOREIGN KEY (courierServiceID) REFERENCES CourierServices(courierServiceID),
  FOREIGN KEY (estadoEnvioId) REFERENCES EstadosEnvio(estadoEnvioId)
);

CREATE TABLE Envios (
  envioId INT AUTO_INCREMENT PRIMARY KEY,
  paqueteID INT,
  fechaSalida TIMESTAMP,
  fechaEntrega TIMESTAMP,
  costoTotal DECIMAL(19,4),
  FOREIGN KEY (paqueteID) REFERENCES Paquetes(paqueteID)
);

CREATE TABLE CostosLogisticos (
  costoLogisticoId INT AUTO_INCREMENT PRIMARY KEY,
  paqueteID INT,
  tipo VARCHAR(20),
  monto DECIMAL(19,4),
  moneda VARCHAR(10),
  FOREIGN KEY (paqueteID) REFERENCES Paquetes(paqueteID)
);

CREATE TABLE ProductosXPaquete (
  productosXPaqueteID INT AUTO_INCREMENT PRIMARY KEY,
  productoLocalID INT,
  cantidad INT,
  paqueteID INT,
  FOREIGN KEY (productoLocalID) REFERENCES ProductosLocales(productoLocalId),
  FOREIGN KEY (paqueteID) REFERENCES Paquetes(paqueteID)
);