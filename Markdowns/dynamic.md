Database engine: MySQL
Database name: Dynamic

Context: Tenemos un holding comercial que opera bajo un modelo de negocio híbrido de importación y ventas digitales de alta gama.
Esta base de datos es de una empresa de base tecnológica donde han desarrollado una IA capaz de generar sitios de e-commerce dinámicos.
A partir de parámetros (logo, enfoque, país), la IA despliega tiendas virtuales con marcas blancas.
Pueden abrir y cerrar "N" sitios en diferentes países de Latam con un solo clic, cada uno con un enfoque de marketing y mensajes distintos para el mismo producto base.

#Tables:
## Users:
- userID PK
- name varchar(20)
- lastName varchar(20)
- email varchar(254)
- enabled boolean

## Countries:
- countryID PK
- countryCommonName varchar(25)			-- Ej: 'Costa Rica', 'Estados Unidos', 'Japón'
- countryOfficialName varchar(30)			-- Ej: 'República de Costa Rica', 'Estados Unidos de América', 'Japón'
- isoCode char(3)			-- Ej: 'CRC', 'USA', 'JAP'
- taxRate decimal(5,4)
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN

## States:
- stateID PK
- countryID FK
- stateName varchar(20)			-- Ej: 'Alajuela', 'Buenos Aires', 'Ciudad de Guatemala'
- isoCode varchar(10)			-- Ej: 'CR-A', 'AR-C', 'GT-GU'
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN

## Cities:
- cityID PK
- stateID FK
- cityName varchar(30)			-- Ej: 'San Ramón', 'Medellín (Centro)', 'Santiago (Centro)'
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN

## Addresses:
- addressID PK
- cityID FK
- address1 varchar(30)
- address2 varchar(30)
- zipCode varchar(20)			-- Ej: '20201', '050001', '8320000'
- geoPosition point
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN

## Logs:
- logID PK
- eventTypeID FK
- description varchar(255)
- sourceID FK
- severityID FK
- postTime Timestamp
- userID FK
- checksum binary(32)
- dataObjectID1 FK
- dataObjectID2 FK

## EventTypes:
- EventTypeID PK
- LogType varchar(30)
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum binary(32)

## Sources:
- sourceID PK
- sourceName varchar(30)
- userID FK

## Severities:
- severityID PK
- severityLevel smallint				-- Ej: 0, 2, 5
- severityName varchar(10)			-- Ej: Emergency, Critical, Notice
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum binary(32)

## DataObjects:
- dataObjectID PK
- dataObjectName varchar(63)
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum binary(32)

## Currencies:
- currencyID PK
- currencySymbol char(1)
- currencyName varchar(10)
- countryID FK
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum binary(32)

## ExchangeRates:
- exchangeRateID PK
- currencyID1 FK			-- Divisa base
- currencyID2	FK			-- Divisa destino
- exchangeRate decimal(20,4)			-- Factor multiplicativo
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum binary(32)

## ExchangeHistories:
- exchangeHistoryID PK
- startDate TIME
- endDate TIME
- exchangeRateID FK			-- tasa De Cambio Actual
- currencyID1 FK			-- Divisa base
- currencyID2	FK			-- Divisa destino
- exchangerate decimal(20,4)			-- Factor multiplicativo
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum binary(32)

## Products:
- productID PK
- name varchar(80)
- productTypeID FK
- categoryID FK
- description varchar(300)
- measurementId FK
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- updatedBy FK
- enabled BOOLEAN
- checksum binary(32)

## Providers:
- providerID PK
- name varchar(64)
- contactEmail varchar(254)
- contactPhone varchar(20)
- addressID FK
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- updatedBy INT
- enabled BOOLEAN
- checksum binary(32)

## ProductsXProvider
- productsXProviderId PK
- productId FK
- providerId FK
- currencyId FK
- price decimal(19, 4)
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum binary(32)

## ProductTypes:
- productTypeId PK
- typeName varchar(50)
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN

## Measurements:
- measurementId PK
- measurementName varchar(20)
- measurementSimbol varchar(3)        -- Ej: ml, g, Kg
- quantity decimal(10,2)  -- Ej: 500, 1000, 1
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN

## Categories:
- categoryID PK
- categoryName varchar(30)
- description varchar(100)
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN

## WebSites:
- webSiteID PK
- webSiteName varchar(32)
- URL varchar(255)
- logoURL varchar(255)
- focus varchar(255)
- countryID FK
- targetAudience FK
- configID FK
- addressID FK
- enabled boolean 

## ProductsXWebSite:
- productXWebSiteID PK
- productID FK
- webSiteID FK
- quantity int
- currencyID FK
- price decimal(19,4)
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum binary(32)

## Configs:
- configID PK
- colorCode1 varchar(7)			-- Ej: #FF5733
- colorCode2 varchar(7)
- fontFamily varchar(63)			-- Ej: Arial, Liberation Sans
- layoutTemplate varchar(30)			-- Ej: Minimal, Bond

## Marketing:
- marketingID PK
- websiteID FK
- section varchar(50)			-- Ej: About us, button, adds, title
- content varchar(255)
- imageURL varchar(255)

## TargetAudiences:
- targetAudienceID PK
- ageMin int
- ageMax int
- gender char			-- Ej: H (Hombre), M (Mujer), U (Unisex)
- incomeLevel varchar(6)			-- Ej: Low, Medium, High

## Clients:
- clientID PK
- name varchar(32)
- email varchar(32)
- phone varchar(25)
- password varchar(30)
- addressId FK
- age smallint
- gender char			-- Ej: 'H' Hombre, 'M' Mujer, 'U' unisex
- purchaseFrecuency smallint
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- enabled BOOLEAN
- checksum binary(32)

## Orders:
- orderID PK
- orderNumber varchar(32) UNIQUE
- websiteID FK
- clientID FK
- statusID FK
- countryId FK
- currencyID FK
- exchangeRate FK
- exchangeHistoryID FK
- subtotalAmount decimal(19,4)
- taxRate decimal(5,4)
- shippingFee decimal(19,4)
- service decimal(19,4)
- discountAmount decimal(19,4)
- totalAmount decimal(19,4)
- logID FK
- createdAt TIMESTAMP

## Status:
- statusID PK
- statusName varchar(15)
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN

## ProductsXOrder:
- productXOrderID PK
- orderID FK
- productID FK
- quantity integer
- currencyID FK
- price decimal(19,4)
- logID FK
- checksum varchar(64)

## Payments:
- paymentID PK
- orderID FK
- paymentMethodID FK
- transactionReference varchar(100)
- paymentStatus varchar(20)
- amountPaid decimal(19,4)

## PaymentMethods:
- paymentMethodID PK
- paymentMethod varchar(10)
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN

## InventoryControls:
- inventoryID PK
- productID FK
- websiteID FK
- stockQuantity int
- minStockLevel int
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- updatedBy FK
- enabled BOOLEAN
- checksum binary(32)

## CourierServices:
- courierServiceID PK
- name varchar(64)
- addressID FK

## Packages:
- packageID PK
- orderID FK
- managingWebsiteID FK
- currentAddressID FK
- destinationAddressID FK
- courierServiceID FK
- status FK
- legalRequirements varchar(256)
- healthPermits varchar(256)
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- endedAt TIMESTAMP
- updatedBy FK
- enabled BOOLEAN
- checksum binary(32)

## productsXPackage:
- productXPackageID PK
- packageID FK
- productID FK
- quantity integer

## LogisticsCosts:
- logisticsCostID PK
- packageID FK
- costType varchar(30)			--Ej: Customs, Freight, Insurance
- amount decimal(19,4)
- currencyID FK
