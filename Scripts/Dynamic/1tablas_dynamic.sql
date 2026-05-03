-- DYNAMIC BRANDS:
CREATE SCHEMA IF NOT EXISTS `Dynamic` DEFAULT CHARACTER SET utf8mb4;
USE `Dynamic`;

-- -----------------------------------------------------
-- 1. MODELO DE GEOLOCALIZACIÓN Y DIRECCIONAMIENTO
-- -----------------------------------------------------
CREATE TABLE Countries (
  countryID INT PRIMARY KEY,
  countryCommonName VARCHAR(50),
  countryOfficialName VARCHAR(100),
  isoCode CHAR(3) UNIQUE,
  taxRate DECIMAL(5,4),
  enabled BOOLEAN DEFAULT TRUE
);

CREATE TABLE States (
  stateID INT PRIMARY KEY,
  countryID INT REFERENCES Countries(countryID),
  stateName VARCHAR(50)
);

CREATE TABLE Cities (
  cityID INT PRIMARY KEY,
  stateID INT REFERENCES States(stateID),
  cityName VARCHAR(50)
);

CREATE TABLE Addresses (
  addressID INT PRIMARY KEY,
  cityID INT REFERENCES Cities(cityID),
  address1 VARCHAR(100),
  address2 VARCHAR(100),
  zipCode VARCHAR(20),
  geoPosition POINT
);

-- -----------------------------------------------------
-- 2. MODELO DE REGISTRO (AUDITORÍA)
-- -----------------------------------------------------
CREATE TABLE EventTypes (
  eventTypeID INT PRIMARY KEY,
  logType VARCHAR(50)
);

CREATE TABLE Severities (
  severityID INT PRIMARY KEY,
  severityLevel SMALLINT,
  severityName VARCHAR(20)
);

CREATE TABLE DataObjects (
  dataObjectID INT PRIMARY KEY,
  dataObjectName VARCHAR(63)
);

CREATE TABLE Sources (
  sourceID INT PRIMARY KEY,
  sourceName VARCHAR(50)
);

CREATE TABLE Logs (
  logID INT PRIMARY KEY,
  eventTypeID INT REFERENCES EventTypes(eventTypeID),
  sourceID INT REFERENCES Sources(sourceID),
  severityID INT REFERENCES Severities(severityID),
  dataObjectID INT REFERENCES DataObjects(dataObjectID),
  description VARCHAR(255),
  postTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------
-- 3. MODELO DE DIVISAS
-- -----------------------------------------------------
CREATE TABLE Currencies (
  currencyID INT PRIMARY KEY,
  currencySymbol VARCHAR(5),
  currencyName VARCHAR(10),
  countryID INT REFERENCES Countries(countryID)
);

CREATE TABLE ExchangeRates (
  exchangeRateID INT PRIMARY KEY,
  currencyID1 INT REFERENCES Currencies(currencyID),
  currencyID2 INT REFERENCES Currencies(currencyID),
  exchangeRate DECIMAL(20,4)
);

CREATE TABLE ExchangeRateHistory (
  historyID INT PRIMARY KEY,
  exchangeRateID INT REFERENCES ExchangeRates(exchangeRateID),
  oldRate DECIMAL(20,4),
  newRate DECIMAL(20,4),
  changedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------
-- 4. MODELO DE MERCANCÍA
-- -----------------------------------------------------
CREATE TABLE Categories (
  categoryID INT PRIMARY KEY,
  categoryName VARCHAR(50),
  enabled BOOLEAN DEFAULT TRUE
);

CREATE TABLE Measurements (
  measurementId INT PRIMARY KEY,
  measurementName VARCHAR(30),
  measurementSimbol VARCHAR(5)
);

CREATE TABLE Providers (
  providerID INT PRIMARY KEY,
  name VARCHAR(64),
  addressID INT REFERENCES Addresses(addressID)
);

CREATE TABLE Products (
  productID INT PRIMARY KEY,
  name VARCHAR(100),
  categoryID INT REFERENCES Categories(categoryID),
  measurementId INT REFERENCES Measurements(measurementId),
  description TEXT,
  enabled BOOLEAN DEFAULT TRUE
);

CREATE TABLE ProductsXProvider (
  productID INT REFERENCES Products(productID),
  providerID INT REFERENCES Providers(providerID),
  cost DECIMAL(19,4),
  PRIMARY KEY (productID, providerID)
);

-- -----------------------------------------------------
-- 5. MODELO DE SITIOS WEB
-- -----------------------------------------------------
CREATE TABLE Configs (
  configID INT PRIMARY KEY,
  layoutTemplate VARCHAR(50)
);

CREATE TABLE TargetAudiences (
  targetAudienceID INT PRIMARY KEY,
  gender CHAR(1),
  incomeLevel VARCHAR(10)
);

CREATE TABLE WebSites (
  webSiteID INT PRIMARY KEY,
  webSiteName VARCHAR(50),
  URL VARCHAR(255),
  countryID INT REFERENCES Countries(countryID),
  targetAudienceID INT REFERENCES TargetAudiences(targetAudienceID),
  configID INT REFERENCES Configs(configID)
);

CREATE TABLE ProductsXWebSite (
  productXWebSiteID INT PRIMARY KEY,
  productID INT REFERENCES Products(productID),
  webSiteID INT REFERENCES WebSites(webSiteID),
  price DECIMAL(19,4)
);

CREATE TABLE Marketing (
  marketingID INT PRIMARY KEY,
  websiteID INT REFERENCES WebSites(webSiteID),
  section VARCHAR(50),
  content TEXT
);

-- -----------------------------------------------------
-- 6. MODELADO DE PERSONAS
-- -----------------------------------------------------
CREATE TABLE Users (
  userID INT PRIMARY KEY,
  name VARCHAR(50),
  lastName VARCHAR(50),
  email VARCHAR(254) UNIQUE
);

CREATE TABLE Clients (
  clientID INT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100) UNIQUE,
  addressId INT REFERENCES Addresses(addressID)
);

-- -----------------------------------------------------
-- 7. MODELADO DE PEDIDOS Y ENTREGAS
-- -----------------------------------------------------
CREATE TABLE Status (
  statusID INT PRIMARY KEY,
  statusName VARCHAR(20)
);

CREATE TABLE PaymentMethods (
  paymentMethodID INT PRIMARY KEY,
  paymentMethod VARCHAR(30)
);

CREATE TABLE Orders (
  orderID INT PRIMARY KEY,
  orderNumber VARCHAR(50) UNIQUE,
  websiteID INT REFERENCES WebSites(webSiteID),
  clientID INT REFERENCES Clients(clientID),
  statusID INT REFERENCES Status(statusID),
  totalAmount DECIMAL(19,4)
);

CREATE TABLE ProductsXOrder (
  orderID INT REFERENCES Orders(orderID),
  productID INT REFERENCES Products(productID),
  quantity INT,
  unitPrice DECIMAL(19,4),
  PRIMARY KEY (orderID, productID)
);

CREATE TABLE Payments (
  paymentID INT PRIMARY KEY,
  orderID INT REFERENCES Orders(orderID),
  paymentMethodID INT REFERENCES PaymentMethods(paymentMethodID),
  amount DECIMAL(19,4),
  paidAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE CourierService (
  courierID INT PRIMARY KEY,
  companyName VARCHAR(50),
  contactPhone VARCHAR(25)
);

CREATE TABLE Package (
  packageID INT PRIMARY KEY,
  orderID INT REFERENCES Orders(orderID),
  courierID INT REFERENCES CourierService(courierID),
  trackingNumber VARCHAR(100),
  weight DECIMAL(10,2)
);

CREATE TABLE LogisticCosts (
  costID INT PRIMARY KEY,
  packageID INT REFERENCES Package(packageID),
  shippingFee DECIMAL(19,4),
  insuranceFee DECIMAL(19,4)
);

CREATE TABLE InventoryControls (
  inventoryID INT PRIMARY KEY,
  productID INT REFERENCES Products(productID),
  stockQuantity INT,
  minStockLevel INT
);