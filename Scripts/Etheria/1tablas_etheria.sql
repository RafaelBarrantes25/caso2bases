---
-- Project Etheria: PostgreSQL Schema Export
---

-- 1. Tablas Independientes (Nivel 0)
CREATE TABLE Users (
  userID SERIAL PRIMARY KEY,
  name varchar(20),
  lastName varchar(20),
  email varchar(254) UNIQUE,
  enabled boolean DEFAULT true
);

CREATE TABLE Countries (
  countryID SERIAL PRIMARY KEY,
  countryCommonName varchar(25),
  countryOfficialName varchar(30),
  isoCode char(3),
  taxRate decimal(5,4),
  enabled boolean DEFAULT true
);

CREATE TABLE ProductTypes (
  productTypeId SERIAL PRIMARY KEY,
  typeName varchar(50),
  createdAt timestamp DEFAULT CURRENT_TIMESTAMP,
  updatedAt timestamp,
  createdBy int,
  updatedBy int,
  enabled boolean DEFAULT true
);

CREATE TABLE Measurements (
  measurementId SERIAL PRIMARY KEY,
  measurementName varchar(20),
  measurementSimbol varchar(3),
  quantity decimal(10,2),
  createdAt timestamp DEFAULT CURRENT_TIMESTAMP,
  updatedAt timestamp,
  createdBy int,
  updatedBy int,
  enabled boolean DEFAULT true
);

CREATE TABLE Categories (
  categoryID SERIAL PRIMARY KEY,
  categoryName varchar(30),
  description varchar(100),
  createdAt timestamp DEFAULT CURRENT_TIMESTAMP,
  updatedAt timestamp,
  createdBy int,
  updatedBy int,
  enabled boolean DEFAULT true
);

CREATE TABLE ImportationStates (
  importationStateId SERIAL PRIMARY KEY,
  name varchar(20)
);

CREATE TABLE EventTypes (
  eventTypeID SERIAL PRIMARY KEY,
  logType varchar(30),
  createdAt timestamp DEFAULT CURRENT_TIMESTAMP,
  updatedAt timestamp,
  createdBy int,
  updatedBy int,
  enabled boolean DEFAULT true,
  checksum bytea
);

CREATE TABLE Severities (
  severityID SERIAL PRIMARY KEY,
  severityLevel smallint,
  severityName varchar(10),
  createdAt timestamp DEFAULT CURRENT_TIMESTAMP,
  updatedAt timestamp,
  createdBy int,
  updatedBy int,
  enabled boolean DEFAULT true,
  checksum bytea
);

CREATE TABLE DataObjects (
  dataObjectID SERIAL PRIMARY KEY,
  dataObjectName varchar(63),
  createdAt timestamp DEFAULT CURRENT_TIMESTAMP,
  updatedAt timestamp,
  createdBy int,
  updatedBy int,
  enabled boolean DEFAULT true,
  checksum bytea
);

-- 2. Tablas con Dependencias Simples (Nivel 1)

CREATE TABLE States (
  stateID SERIAL PRIMARY KEY,
  countryID int REFERENCES Countries(countryID),
  stateName varchar(20),
  isoCode varchar(10),
  enabled boolean DEFAULT true
);

CREATE TABLE Sources (
  sourceID SERIAL PRIMARY KEY,
  sourceName varchar(30),
  userID int REFERENCES Users(userID)
);

CREATE TABLE Currencies (
  currencyID SERIAL PRIMARY KEY,
  currencySymbol char(1),
  currencyName varchar(10),
  countryID int REFERENCES Countries(countryID),
  userID int REFERENCES Users(userID),
  post timestamp DEFAULT CURRENT_TIMESTAMP,
  enabled boolean DEFAULT true,
  amount decimal(18,2)
);

CREATE TABLE Products (
  productID SERIAL PRIMARY KEY,
  name varchar(80),
  productTypeID int REFERENCES ProductTypes(productTypeId),
  categoryID int REFERENCES Categories(categoryID),
  description varchar(300),
  measurementId int REFERENCES Measurements(measurementId),
  createdAt timestamp DEFAULT CURRENT_TIMESTAMP,
  updatedAt timestamp,
  updatedBy int,
  enabled boolean DEFAULT true,
  checksum bytea
);

-- 3. Tablas con Dependencias Geográficas y Financieras

CREATE TABLE Cities (
  cityID SERIAL PRIMARY KEY,
  stateID int REFERENCES States(stateID),
  cityName varchar(30),
  enabled boolean DEFAULT true
);

CREATE TABLE Addresses (
  addressID SERIAL PRIMARY KEY,
  cityID int REFERENCES Cities(cityID),
  address1 varchar(30),
  address2 varchar(30),
  zipCode varchar(20),
  geoPosition point,
  enabled boolean DEFAULT true
);

CREATE TABLE ExchangeRates (
  exchangeRateID SERIAL PRIMARY KEY,
  currencyID1 int REFERENCES Currencies(currencyID),
  currencyID2 int REFERENCES Currencies(currencyID),
  exchangeRate decimal(20,4),
  userID int REFERENCES Users(userID),
  post timestamp DEFAULT CURRENT_TIMESTAMP,
  checksum bytea,
  enabled boolean DEFAULT true
);

CREATE TABLE ExchangeHistories (
  exchangeHistoryID SERIAL PRIMARY KEY,
  startDate time,
  endDate time,
  exchangeRateID int REFERENCES ExchangeRates(exchangeRateID),
  currencyID1 int REFERENCES Currencies(currencyID),
  currencyID2 int REFERENCES Currencies(currencyID),
  exchangeRate decimal(20,4),
  userID int REFERENCES Users(userID),
  post timestamp DEFAULT CURRENT_TIMESTAMP,
  checksum bytea
);

-- 4. Logística y Proveedores

CREATE TABLE Providers (
  providerID SERIAL PRIMARY KEY,
  name varchar(64),
  contactEmail varchar(254),
  contactPhone varchar(20),
  addressID int REFERENCES Addresses(addressID),
  createdAt timestamp DEFAULT CURRENT_TIMESTAMP,
  updatedAt timestamp,
  updatedBy int,
  enabled boolean DEFAULT true,
  checksum bytea
);

CREATE TABLE Hubs (
  hubId SERIAL PRIMARY KEY,
  hubName varchar(30),
  addressID int REFERENCES Addresses(addressID),
  createdAt timestamp DEFAULT CURRENT_TIMESTAMP,
  updatedAt timestamp,
  createdBy int,
  updatedBy int,
  enabled boolean DEFAULT true,
  checksum bytea
);

CREATE TABLE ProductsXProvider (
  productsXProviderId SERIAL PRIMARY KEY,
  productId int REFERENCES Products(productID),
  providerId int REFERENCES Providers(providerID),
  currencyId int REFERENCES Currencies(currencyID),
  price decimal(19,4),
  createdAt timestamp DEFAULT CURRENT_TIMESTAMP,
  updatedAt timestamp,
  createdBy int,
  updatedBy int,
  enabled boolean DEFAULT true,
  checksum bytea
);

-- 5. Inventario y Logs

CREATE TABLE InventoryXHub (
  inventoryId SERIAL PRIMARY KEY,
  hubId int REFERENCES Hubs(hubId),
  productID int REFERENCES Products(productID),
  quantity int,
  createdAt timestamp DEFAULT CURRENT_TIMESTAMP,
  updatedAt timestamp,
  createdBy int,
  updatedBy int,
  enabled boolean DEFAULT true,
  checksum bytea
);

CREATE TABLE MovementXInventory (
  movementId SERIAL PRIMARY KEY,
  productID int REFERENCES Products(productID),
  type varchar(10),
  quantity int,
  createdAt timestamp DEFAULT CURRENT_TIMESTAMP,
  updatedAt timestamp,
  createdBy int,
  updatedBy int,
  enabled boolean DEFAULT true,
  checksum bytea
);

CREATE TABLE Logs (
  logID SERIAL PRIMARY KEY,
  eventTypeID int REFERENCES EventTypes(eventTypeID),
  description varchar(255),
  sourceID int REFERENCES Sources(sourceID),
  severityID int REFERENCES Severities(severityID),
  postTime timestamp DEFAULT CURRENT_TIMESTAMP,
  userID int REFERENCES Users(userID),
  checksum bytea,
  dataObjectID1 int REFERENCES DataObjects(dataObjectID),
  dataObjectID2 int REFERENCES DataObjects(dataObjectID)
);

-- 6. Demandas e Importaciones

CREATE TABLE Demands (
  demandId SERIAL PRIMARY KEY,
  countryId int REFERENCES Countries(countryID),
  productID int REFERENCES Products(productID),
  quantity int,
  createdAt timestamp DEFAULT CURRENT_TIMESTAMP,
  updatedAt timestamp,
  createdBy int,
  updatedBy int,
  enabled boolean DEFAULT true,
  checksum bytea
);

CREATE TABLE Importation (
  importationID SERIAL PRIMARY KEY,
  providerID int REFERENCES Providers(providerID),
  demandId int REFERENCES Demands(demandId),
  description varchar(256),
  logId int REFERENCES Logs(logID),
  currencyID int REFERENCES Currencies(currencyID),
  exchangeRate int REFERENCES ExchangeRates(exchangeRateID),
  subtotalAmount decimal(19,4),
  taxRate decimal(5,4),
  shippingFee decimal(19,4),
  service decimal(19,4),
  totalAmount decimal(19,4),
  importationStateID int REFERENCES ImportationStates(importationStateId),
  createdAt timestamp DEFAULT CURRENT_TIMESTAMP,
  updatedAt timestamp,
  createdBy int,
  updatedBy int,
  enabled boolean DEFAULT true,
  checksum bytea
);

CREATE TABLE ProductsXImportation (
  productsXImportationID SERIAL PRIMARY KEY,
  productID int REFERENCES Products(productID),
  quantity int,
  currencyID int REFERENCES Currencies(currencyID),
  price decimal(19,4),
  importationID int REFERENCES Importation(importationID)
);