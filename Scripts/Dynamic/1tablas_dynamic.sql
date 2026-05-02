-- Configuración inicial compatible con MySQL 8.x (Docker)
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=1;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Nombre del esquema alineado con MYSQL_DATABASE del .yml
CREATE SCHEMA IF NOT EXISTS `Dynamic` DEFAULT CHARACTER SET utf8mb4;
USE `Dynamic`;

-- -----------------------------------------------------
-- 1. Tablas Maestras (Sin Dependencias)
-- -----------------------------------------------------

CREATE TABLE Users (
  userID INT PRIMARY KEY,
  name VARCHAR(50),
  lastName VARCHAR(50),
  email VARCHAR(254) UNIQUE,
  enabled BOOLEAN DEFAULT TRUE
);

CREATE TABLE Countries (
  countryID INT PRIMARY KEY,
  countryCommonName VARCHAR(50),
  countryOfficialName VARCHAR(100),
  isoCode CHAR(3) UNIQUE,
  taxRate DECIMAL(5,4),
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  createdBy INT,
  updatedBy INT,
  enabled BOOLEAN DEFAULT TRUE
);

CREATE TABLE EventTypes (
  eventTypeID INT PRIMARY KEY,
  logType VARCHAR(50),
  enabled BOOLEAN DEFAULT TRUE
);

CREATE TABLE Severities (
  severityID INT PRIMARY KEY,
  severityLevel SMALLINT,
  severityName VARCHAR(20),
  enabled BOOLEAN DEFAULT TRUE
);

CREATE TABLE Measurements (
  measurementId INT PRIMARY KEY,
  measurementName VARCHAR(30),
  measurementSimbol VARCHAR(5),
  enabled BOOLEAN DEFAULT TRUE
);

CREATE TABLE Categories (
  categoryID INT PRIMARY KEY,
  categoryName VARCHAR(50),
  description TEXT,
  enabled BOOLEAN DEFAULT TRUE
);

CREATE TABLE TargetAudiences (
  targetAudienceID INT PRIMARY KEY,
  gender CHAR(1), -- 'M', 'F', 'A' (All)
  incomeLevel VARCHAR(10) -- 'LOW', 'MEDIUM', 'HIGH'
);

CREATE TABLE Configs (
  configID INT PRIMARY KEY,
  layoutTemplate VARCHAR(50)
);

CREATE TABLE Status (
  statusID INT PRIMARY KEY,
  statusName VARCHAR(20),
  enabled BOOLEAN DEFAULT TRUE
);

CREATE TABLE PaymentMethods (
  paymentMethodID INT PRIMARY KEY,
  paymentMethod VARCHAR(30),
  enabled BOOLEAN DEFAULT TRUE
);

-- -----------------------------------------------------
-- 2. Tablas Geográficas y Direcciones
-- -----------------------------------------------------

CREATE TABLE States (
  stateID INT PRIMARY KEY,
  countryID INT,
  stateName VARCHAR(50),
  FOREIGN KEY (countryID) REFERENCES Countries(countryID)
);

CREATE TABLE Cities (
  cityID INT PRIMARY KEY,
  stateID INT,
  cityName VARCHAR(50),
  FOREIGN KEY (stateID) REFERENCES States(stateID)
);

CREATE TABLE Addresses (
  addressID INT PRIMARY KEY,
  cityID INT,
  address1 VARCHAR(100),
  address2 VARCHAR(100),
  zipCode VARCHAR(20),
  geoPosition POINT,
  FOREIGN KEY (cityID) REFERENCES Cities(cityID)
);

-- -----------------------------------------------------
-- 3. Infraestructura y Logs
-- -----------------------------------------------------

CREATE TABLE Sources (
  sourceID INT PRIMARY KEY,
  sourceName VARCHAR(50),
  userID INT,
  FOREIGN KEY (userID) REFERENCES Users(userID)
);

CREATE TABLE Logs (
  logID INT PRIMARY KEY,
  eventTypeID INT,
  description VARCHAR(255),
  sourceID INT,
  severityID INT,
  postTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  userID INT,
  FOREIGN KEY (eventTypeID) REFERENCES EventTypes(eventTypeID),
  FOREIGN KEY (sourceID) REFERENCES Sources(sourceID),
  FOREIGN KEY (severityID) REFERENCES Severities(severityID),
  FOREIGN KEY (userID) REFERENCES Users(userID)
);

-- -----------------------------------------------------
-- 4. Finanzas y Monedas
-- -----------------------------------------------------

CREATE TABLE Currencies (
  currencyID INT PRIMARY KEY,
  currencySymbol VARCHAR(5),
  currencyName VARCHAR(10),
  countryID INT,
  FOREIGN KEY (countryID) REFERENCES Countries(countryID)
);

-- -----------------------------------------------------
-- 5. Catálogo de Productos y Sitios Web (Core)
-- -----------------------------------------------------

CREATE TABLE Products (
  productID INT PRIMARY KEY,
  name VARCHAR(100),
  categoryID INT,
  measurementId INT,
  description TEXT,
  enabled BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (categoryID) REFERENCES Categories(categoryID),
  FOREIGN KEY (measurementId) REFERENCES Measurements(measurementId)
);

CREATE TABLE WebSites (
  webSiteID INT PRIMARY KEY,
  webSiteName VARCHAR(50),
  URL VARCHAR(255),
  logoURL VARCHAR(255),
  focus VARCHAR(255),
  countryID INT,
  targetAudience INT,
  configID INT,
  enabled BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (countryID) REFERENCES Countries(countryID),
  FOREIGN KEY (targetAudience) REFERENCES TargetAudiences(targetAudienceID),
  FOREIGN KEY (configID) REFERENCES Configs(configID)
);

CREATE TABLE ProductsXWebSite (
  productXWebSiteID INT PRIMARY KEY,
  productID INT,
  webSiteID INT,
  quantity INT,
  currencyID INT,
  price DECIMAL(19,4),
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  enabled BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (productID) REFERENCES Products(productID),
  FOREIGN KEY (webSiteID) REFERENCES WebSites(webSiteID),
  FOREIGN KEY (currencyID) REFERENCES Currencies(currencyID)
);

CREATE TABLE Marketing (
  marketingID INT PRIMARY KEY,
  websiteID INT,
  section VARCHAR(50),
  content TEXT,
  imageURL VARCHAR(255),
  FOREIGN KEY (websiteID) REFERENCES WebSites(webSiteID)
);

-- -----------------------------------------------------
-- 6. Clientes y Operaciones
-- -----------------------------------------------------

CREATE TABLE Clients (
  clientID INT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100) UNIQUE,
  phone VARCHAR(25),
  password VARCHAR(255), -- Mayor longitud para hashes
  addressId INT,
  enabled BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (addressId) REFERENCES Addresses(addressID)
);

CREATE TABLE Orders (
  orderID INT PRIMARY KEY,
  orderNumber VARCHAR(50) UNIQUE,
  websiteID INT,
  clientID INT,
  statusID INT,
  currencyID INT,
  totalAmount DECIMAL(19,4),
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (websiteID) REFERENCES WebSites(webSiteID),
  FOREIGN KEY (clientID) REFERENCES Clients(clientID),
  FOREIGN KEY (statusID) REFERENCES Status(statusID),
  FOREIGN KEY (currencyID) REFERENCES Currencies(currencyID)
);

CREATE TABLE InventoryControls (
  inventoryID INT PRIMARY KEY,
  productID INT,
  websiteID INT,
  stockQuantity INT,
  minStockLevel INT,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  enabled BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (productID) REFERENCES Products(productID),
  FOREIGN KEY (websiteID) REFERENCES WebSites(webSiteID)
);

-- Restaurar configuración
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;