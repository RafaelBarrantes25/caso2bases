-- ETHERIA GLOBAL:
-- -----------------------------------------------------
-- 1. MODELO DE GEOLOCALIZACIÓN Y DIRECCIONAMIENTO
-- -----------------------------------------------------
CREATE TABLE Countries (
  countryID SERIAL PRIMARY KEY,
  countryCommonName VARCHAR(25),
  countryOfficialName VARCHAR(30),
  isoCode CHAR(3),
  taxRate DECIMAL(5,4),
  enabled BOOLEAN DEFAULT TRUE
);

CREATE TABLE States (
  stateID SERIAL PRIMARY KEY,
  countryID INT REFERENCES Countries(countryID),
  stateName VARCHAR(20),
  isoCode VARCHAR(10)
);

CREATE TABLE Cities (
  cityID SERIAL PRIMARY KEY,
  stateID INT REFERENCES States(stateID),
  cityName VARCHAR(30)
);

CREATE TABLE Addresses (
  addressID SERIAL PRIMARY KEY,
  cityID INT REFERENCES Cities(cityID),
  address1 VARCHAR(30),
  address2 VARCHAR(30),
  zipCode VARCHAR(20),
  geoPosition POINT
);

-- -----------------------------------------------------
-- 2. MODELO DE REGISTRO (AUDITORÍA Y TRAZABILIDAD)
-- -----------------------------------------------------
CREATE TABLE EventTypes (
  eventTypeID SERIAL PRIMARY KEY,
  logType VARCHAR(30),
  checksum BYTEA
);

CREATE TABLE Severities (
  severityID SERIAL PRIMARY KEY,
  severityLevel SMALLINT,
  severityName VARCHAR(10),
  checksum BYTEA
);

CREATE TABLE DataObjects (
  dataObjectID SERIAL PRIMARY KEY,
  dataObjectName VARCHAR(63),
  checksum BYTEA
);

CREATE TABLE Sources (
  sourceID SERIAL PRIMARY KEY,
  sourceName VARCHAR(30),
  userID INT -- Referencia diferida al modelo de personas
);

CREATE TABLE Logs (
  logID SERIAL PRIMARY KEY,
  eventTypeID INT REFERENCES EventTypes(eventTypeID),
  sourceID INT REFERENCES Sources(sourceID),
  severityID INT REFERENCES Severities(severityID),
  userID INT,
  description VARCHAR(255),
  dataObjectID1 INT REFERENCES DataObjects(dataObjectID),
  dataObjectID2 INT REFERENCES DataObjects(dataObjectID),
  postTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  checksum BYTEA
);

-- -----------------------------------------------------
-- 3. MODELO DE DIVISAS
-- -----------------------------------------------------
CREATE TABLE Currencies (
  currencyID SERIAL PRIMARY KEY,
  currencySymbol CHAR(1),
  currencyName VARCHAR(10),
  countryID INT REFERENCES Countries(countryID),
  enabled BOOLEAN DEFAULT TRUE,
  checksum BYTEA
);

CREATE TABLE ExchangeRates (
  exchangeRateID SERIAL PRIMARY KEY,
  currencyID1 INT REFERENCES Currencies(currencyID),
  currencyID2 INT REFERENCES Currencies(currencyID),
  exchangeRate DECIMAL(20,4),
  post TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  checksum BYTEA
);

CREATE TABLE ExchangeRateHistory (
  exchangeHistoryID SERIAL PRIMARY KEY,
  exchangeRateID INT REFERENCES ExchangeRates(exchangeRateID),
  currencyID1 INT REFERENCES Currencies(currencyID),
  currencyID2 INT REFERENCES Currencies(currencyID),
  exchangeRate DECIMAL(20,4),
  startDate TIMESTAMP,
  endDate TIMESTAMP,
  checksum BYTEA
);

-- -----------------------------------------------------
-- 4. MODELO DE MERCANCÍA
-- -----------------------------------------------------
CREATE TABLE Categories (
  categoryID SERIAL PRIMARY KEY,
  categoryName VARCHAR(30),
  description VARCHAR(100),
  enabled BOOLEAN DEFAULT TRUE
);

CREATE TABLE Measurements (
  measurementId SERIAL PRIMARY KEY,
  measurementName VARCHAR(20),
  measurementSimbol VARCHAR(3),
  quantity DECIMAL(10,2)
);

CREATE TABLE Products (
  productID SERIAL PRIMARY KEY,
  name VARCHAR(80),
  categoryID INT REFERENCES Categories(categoryID),
  measurementId INT REFERENCES Measurements(measurementId),
  description VARCHAR(300),
  enabled BOOLEAN DEFAULT TRUE,
  checksum BYTEA
);

CREATE TABLE Providers (
  providerID SERIAL PRIMARY KEY,
  name VARCHAR(64),
  contactEmail VARCHAR(254),
  contactPhone VARCHAR(20),
  addressID INT REFERENCES Addresses(addressID),
  enabled BOOLEAN DEFAULT TRUE,
  checksum BYTEA
);

CREATE TABLE ProductsXProvider (
  productsXProviderId SERIAL PRIMARY KEY,
  productId INT REFERENCES Products(productID),
  providerId INT REFERENCES Providers(providerID),
  currencyId INT REFERENCES Currencies(currencyID),
  price DECIMAL(19,4),
  checksum BYTEA
);

-- -----------------------------------------------------
-- 5. MODELO DE INVENTARIO E IMPORTACIONES
-- -----------------------------------------------------
CREATE TABLE Hubs (
  hubId SERIAL PRIMARY KEY,
  hubName VARCHAR(30),
  addressID INT REFERENCES Addresses(addressID),
  enabled BOOLEAN DEFAULT TRUE
);

CREATE TABLE InventoryXHub (
  inventoryId SERIAL PRIMARY KEY,
  hubId INT REFERENCES Hubs(hubId),
  productID INT REFERENCES Products(productID),
  quantity INT,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  checksum BYTEA
);

CREATE TABLE MovementXInventory (
  movementId SERIAL PRIMARY KEY,
  productID INT REFERENCES Products(productID),
  type VARCHAR(10), -- 'IN' o 'OUT'
  quantity INT,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ImportationState (
  importationStateId SERIAL PRIMARY KEY,
  name VARCHAR(20)
);

CREATE TABLE Demands (
  demandId SERIAL PRIMARY KEY,
  countryId INT REFERENCES Countries(countryID),
  productID INT REFERENCES Products(productID),
  quantity INT,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Importation (
  importationID SERIAL PRIMARY KEY,
  providerID INT REFERENCES Providers(providerID),
  demandId INT REFERENCES Demands(demandId),
  currencyID INT REFERENCES Currencies(currencyID),
  exchangeRate INT REFERENCES ExchangeRates(exchangeRateID),
  subtotalAmount DECIMAL(19,4),
  totalAmount DECIMAL(19,4),
  importationStateID INT REFERENCES ImportationState(importationStateId),
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  checksum BYTEA
);

CREATE TABLE ProductXImportation (
  productXImportationID SERIAL PRIMARY KEY,
  productID INT REFERENCES Products(productID),
  importationID INT REFERENCES Importation(importationID),
  quantity INT,
  price DECIMAL(19,4)
);

-- -----------------------------------------------------
-- 6. MODELADO DE PERSONAS
-- -----------------------------------------------------
CREATE TABLE Users (
  userID SERIAL PRIMARY KEY,
  name VARCHAR(20),
  lastName VARCHAR(20),
  email VARCHAR(254) UNIQUE,
  enabled BOOLEAN DEFAULT TRUE
);

-- Relación circular necesaria para Sources
ALTER TABLE Sources ADD CONSTRAINT fk_sources_users FOREIGN KEY (userID) REFERENCES Users(userID);