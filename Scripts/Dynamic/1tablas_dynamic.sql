-- Configuración inicial
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `dynamic_db` DEFAULT CHARACTER SET utf8mb4;
USE `dynamic_db`;

-- -----------------------------------------------------
-- Independientes / Maestras básicas
-- -----------------------------------------------------

CREATE TABLE Users (
  userID INT PRIMARY KEY,
  name VARCHAR(20),
  lastName VARCHAR(20),
  email VARCHAR(254),
  enabled BOOLEAN
);

CREATE TABLE Countries (
  countryID INT PRIMARY KEY,
  countryCommonName VARCHAR(25),
  countryOfficialName VARCHAR(30),
  isoCode CHAR(3),
  taxRate DECIMAL(5,4),
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN
);

CREATE TABLE EventTypes (
  eventTypeID INT PRIMARY KEY,
  logType VARCHAR(30),
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN,
  checksum BINARY(16)
);

CREATE TABLE Severities (
  severityID INT PRIMARY KEY,
  severityLevel SMALLINT,
  severityName VARCHAR(10),
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN,
  checksum BINARY(16)
);

CREATE TABLE DataObjects (
  dataObjectID INT PRIMARY KEY,
  dataObjectName VARCHAR(63),
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN,
  checksum BINARY(16)
);

CREATE TABLE ProductTypes (
  productTypeId INT PRIMARY KEY,
  typeName VARCHAR(50),
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN
);

CREATE TABLE Measurements (
  measurementId INT PRIMARY KEY,
  measurementName VARCHAR(20),
  measurementSimbol VARCHAR(3),
  quantity DECIMAL(10,2),
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN
);

CREATE TABLE Categories (
  categoryID INT PRIMARY KEY,
  categoryName VARCHAR(30),
  description VARCHAR(100),
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN
);

CREATE TABLE TargetAudiences (
  targetAudienceID INT PRIMARY KEY,
  ageMin INT,
  ageMax INT,
  gender CHAR(1),
  incomeLevel VARCHAR(6)
);

CREATE TABLE Configs (
  configID INT PRIMARY KEY,
  colorCode1 VARCHAR(7),
  colorCode2 VARCHAR(7),
  fontFamily VARCHAR(63),
  layoutTemplate VARCHAR(30)
);

CREATE TABLE Status (
  statusID INT PRIMARY KEY,
  statusName VARCHAR(15),
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN
);

CREATE TABLE PaymentMethods (
  paymentMethodID INT PRIMARY KEY,
  paymentMethod VARCHAR(10),
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN
);

-- -----------------------------------------------------
-- Geografía y Direcciones
-- -----------------------------------------------------

CREATE TABLE States (
  stateID INT PRIMARY KEY,
  countryID INT,
  stateName VARCHAR(20),
  isoCode VARCHAR(10),
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN,
  FOREIGN KEY (countryID) REFERENCES Countries(countryID)
);

CREATE TABLE Cities (
  cityID INT PRIMARY KEY,
  stateID INT,
  cityName VARCHAR(30),
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN,
  FOREIGN KEY (stateID) REFERENCES States(stateID)
);

CREATE TABLE Addresses (
  addressID INT PRIMARY KEY,
  cityID INT,
  address1 VARCHAR(30),
  address2 VARCHAR(30),
  zipCode VARCHAR(20),
  geoPosition POINT,
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN,
  FOREIGN KEY (cityID) REFERENCES Cities(cityID)
);

-- -----------------------------------------------------
-- Logs y Auditoría
-- -----------------------------------------------------

CREATE TABLE Sources (
  sourceID INT PRIMARY KEY,
  sourceName VARCHAR(30),
  userID INT
);

CREATE TABLE Logs (
  logID INT PRIMARY KEY,
  eventTypeID INT,
  description VARCHAR(255),
  sourceID INT,
  severityID INT,
  postTime TIMESTAMP,
  userID INT,
  checksum BINARY(16),
  dataObjectID1 INT,
  dataObjectID2 INT,
  FOREIGN KEY (eventTypeID) REFERENCES EventTypes(eventTypeID),
  FOREIGN KEY (sourceID) REFERENCES Sources(sourceID),
  FOREIGN KEY (severityID) REFERENCES Severities(severityID),
  FOREIGN KEY (userID) REFERENCES Users(userID)
);

-- -----------------------------------------------------
-- Finanzas (Monedas)
-- -----------------------------------------------------

CREATE TABLE Currencies (
  currencyID INT PRIMARY KEY,
  currencySymbol CHAR(1),
  currencyName VARCHAR(10),
  countryID INT,
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN,
  checksum BINARY(16),
  FOREIGN KEY (countryID) REFERENCES Countries(countryID)
);

CREATE TABLE ExchangeRates (
  exchangeRateID INT PRIMARY KEY,
  currencyID1 INT,
  currencyID2 INT,
  exchangeRate DECIMAL(20,4),
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN,
  checksum BINARY(16),
  FOREIGN KEY (currencyID1) REFERENCES Currencies(currencyID),
  FOREIGN KEY (currencyID2) REFERENCES Currencies(currencyID)
);

CREATE TABLE ExchangeHistories (
  exchangeHistoryID INT PRIMARY KEY,
  startDate TIME,
  endDate TIME,
  exchangeRateID INT,
  currencyID1 INT,
  currencyID2 INT,
  exchangeRate DECIMAL(20,4),
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN,
  checksum BINARY(16),
  FOREIGN KEY (exchangeRateID) REFERENCES ExchangeRates(exchangeRateID)
);

-- -----------------------------------------------------
-- Catálogo de Productos y Proveedores
-- -----------------------------------------------------

CREATE TABLE Products (
  productID INT PRIMARY KEY,
  name VARCHAR(80),
  productTypeID INT,
  categoryID INT,
  description VARCHAR(300),
  measurementId INT,
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  updatedBy INT,
  enabled BOOLEAN,
  checksum BINARY(16),
  FOREIGN KEY (productTypeID) REFERENCES ProductTypes(productTypeId),
  FOREIGN KEY (categoryID) REFERENCES Categories(categoryID),
  FOREIGN KEY (measurementId) REFERENCES Measurements(measurementId)
);

CREATE TABLE Providers (
  providerID INT PRIMARY KEY,
  name VARCHAR(64),
  contactEmail VARCHAR(254),
  contactPhone VARCHAR(20),
  addressID INT,
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  updatedBy INT,
  enabled BOOLEAN,
  checksum BINARY(16),
  FOREIGN KEY (addressID) REFERENCES Addresses(addressID)
);

CREATE TABLE ProductsXProvider (
  productsXProviderId INT PRIMARY KEY,
  productId INT,
  providerId INT,
  currencyId INT,
  price DECIMAL(19,4),
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN,
  checksum BINARY(16),
  FOREIGN KEY (productId) REFERENCES Products(productID),
  FOREIGN KEY (providerId) REFERENCES Providers(providerID)
);

-- -----------------------------------------------------
-- WebSites y Marketing
-- -----------------------------------------------------

CREATE TABLE WebSites (
  webSiteID INT PRIMARY KEY,
  webSiteName VARCHAR(32),
  URL VARCHAR(255),
  logoURL VARCHAR(255),
  focus VARCHAR(255),
  countryID INT,
  targetAudience INT,
  configID INT,
  addressID INT,
  enabled BOOLEAN,
  FOREIGN KEY (countryID) REFERENCES Countries(countryID),
  FOREIGN KEY (targetAudience) REFERENCES TargetAudiences(targetAudienceID),
  FOREIGN KEY (configID) REFERENCES Configs(configID),
  FOREIGN KEY (addressID) REFERENCES Addresses(addressID)
);

CREATE TABLE ProductsXWebSite (
  productXWebSiteID INT PRIMARY KEY,
  productID INT,
  webSiteID INT,
  quantity INT,
  currencyID INT,
  price DECIMAL(19,4),
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN,
  checksum BINARY(16),
  FOREIGN KEY (productID) REFERENCES Products(productID),
  FOREIGN KEY (webSiteID) REFERENCES WebSites(webSiteID)
);

CREATE TABLE Marketing (
  marketingID INT PRIMARY KEY,
  websiteID INT,
  section VARCHAR(50),
  content VARCHAR(255),
  imageURL VARCHAR(255),
  FOREIGN KEY (websiteID) REFERENCES WebSites(webSiteID)
);

-- -----------------------------------------------------
-- Clientes y Órdenes
-- -----------------------------------------------------

CREATE TABLE Clients (
  clientID INT PRIMARY KEY,
  name VARCHAR(32),
  email VARCHAR(32),
  phone VARCHAR(25),
  password VARCHAR(30),
  addressId INT,
  age SMALLINT,
  gender CHAR(1),
  purchaseFrecuency SMALLINT,
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  enabled BOOLEAN,
  checksum BINARY(16),
  FOREIGN KEY (addressId) REFERENCES Addresses(addressID)
);

CREATE TABLE Orders (
  orderID INT PRIMARY KEY,
  orderNumber VARCHAR(32) UNIQUE,
  websiteID INT,
  clientID INT,
  statusID INT,
  countryId INT,
  currencyID INT,
  exchangeRate INT,
  subtotalAmount DECIMAL(19,4),
  taxRate DECIMAL(5,4),
  shippingFee DECIMAL(19,4),
  service DECIMAL(19,4),
  discountAmount DECIMAL(19,4),
  totalAmount DECIMAL(19,4),
  logID INT,
  createdAt TIMESTAMP,
  FOREIGN KEY (websiteID) REFERENCES WebSites(webSiteID),
  FOREIGN KEY (clientID) REFERENCES Clients(clientID),
  FOREIGN KEY (statusID) REFERENCES Status(statusID),
  FOREIGN KEY (currencyID) REFERENCES Currencies(currencyID)
);

CREATE TABLE ProductsXOrder (
  productXOrderID INT PRIMARY KEY,
  orderID INT,
  productID INT,
  quantity INT,
  currencyID INT,
  price DECIMAL(19,4),
  logID INT,
  checksum VARCHAR(64),
  FOREIGN KEY (orderID) REFERENCES Orders(orderID),
  FOREIGN KEY (productID) REFERENCES Products(productID)
);

CREATE TABLE Payments (
  paymentID INT PRIMARY KEY,
  orderID INT,
  paymentMethodID INT,
  transactionReference VARCHAR(100),
  paymentStatus VARCHAR(20),
  amountPaid DECIMAL(19,4),
  FOREIGN KEY (orderID) REFERENCES Orders(orderID),
  FOREIGN KEY (paymentMethodID) REFERENCES PaymentMethods(paymentMethodID)
);

-- -----------------------------------------------------
-- Inventario y Logística
-- -----------------------------------------------------

CREATE TABLE InventoryControls (
  inventoryID INT PRIMARY KEY,
  productID INT,
  websiteID INT,
  stockQuantity INT,
  minStockLevel INT,
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  updatedBy INT,
  enabled BOOLEAN,
  checksum BINARY(16),
  FOREIGN KEY (productID) REFERENCES Products(productID),
  FOREIGN KEY (websiteID) REFERENCES WebSites(webSiteID)
);

CREATE TABLE CourierServices (
  courierServiceID INT PRIMARY KEY,
  name VARCHAR(64),
  addressID INT,
  FOREIGN KEY (addressID) REFERENCES Addresses(addressID)
);

CREATE TABLE Packages (
  packageID INT PRIMARY KEY,
  orderID INT,
  managingWebsiteID INT,
  currentAddressID INT,
  destinationAddressID INT,
  courierServiceID INT,
  status INT,
  legalRequirements VARCHAR(256),
  healthPermits VARCHAR(256),
  createdAt TIMESTAMP,
  updatedAt TIMESTAMP,
  endedAt TIMESTAMP,
  updatedBy INT,
  enabled BOOLEAN,
  checksum BINARY(16),
  FOREIGN KEY (orderID) REFERENCES Orders(orderID),
  FOREIGN KEY (courierServiceID) REFERENCES CourierServices(courierServiceID)
);

CREATE TABLE ProductsXPackage (
  productXPackageID INT PRIMARY KEY,
  packageID INT,
  productID INT,
  quantity INT,
  FOREIGN KEY (packageID) REFERENCES Packages(packageID),
  FOREIGN KEY (productID) REFERENCES Products(productID)
);

CREATE TABLE LogisticsCosts (
  logisticsCostID INT PRIMARY KEY,
  packageID INT,
  costType VARCHAR(30),
  amount DECIMAL(19,4),
  currencyID INT,
  FOREIGN KEY (packageID) REFERENCES Packages(packageID),
  FOREIGN KEY (currencyID) REFERENCES Currencies(currencyID)
);

SET SQL_MODE='';
SET FOREIGN_KEY_CHECKS=1;
SET UNIQUE_CHECKS=1;
