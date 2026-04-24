# Database engine: PostgreSQL18

Database name: Etheria

Context: Tenemos un holding comercial que opera bajo un modelo de negocio híbrido de importación y ventas digitales de alta gama.
Esta base de datos es de una empresa que se encarga de la cadena de suministro. Importan productos naturales y curativos exóticos de todo el mundo (bebidas, alimentos, cosmética dermatológica, capilar, aromaterapia, jabones y aceites esenciales).
Todos los productos son de gama alta y poseen propiedades medicinales/saludables.
Se importan en "bulk" (cajas sin marca ni etiquetado) en dólares (USD).
Todo llega a un centro logístico en la costa Caribe de Nicaragua.

# Tables:
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
- enabled boolean

## States:
- stateID PK
- countryID FK
- stateName varchar(20)			-- Ej: 'Alajuela', 'Buenos Aires', 'Ciudad de Guatemala'
- isoCode varchar(10)			-- Ej: 'CR-A', 'AR-C', 'GT-GU'
- enabled boolean

## Cities:
- cityID PK
- stateID FK
- cityName varchar(30)			-- Ej: 'San Ramón', 'Medellín (Centro)', 'Santiago (Centro)'
- enabled boolean

## Addresses:
- addressID PK
- cityID FK
- address1 varchar(30)
- address2 varchar(30)
- zipCode varchar(20)			-- Ej: '20201', '050001', '8320000'
- geoPosition point
- enabled boolean

## Currencies:
- currencyID PK
- currencySymbol char(1)
- currencyName varchar(10)
- countryID FK
- userID FK
- post timestamp
- enabled boolean
- amount decimal(18,2)

## ExchangeRates:
- exchangeRateID PK
- currencyID1 FK			-- Divisa base
- currencyID2	FK			-- Divisa destino
- exchangeRate decimal(20,4)			-- Factor multiplicativo
- userID FK
- post timestamp
- checksum bytea
- enabled boolean

## ExchangeHistories:
- exchangeHistoryID PK
- startDate TIME
- endDate TIME
- exchangeRateID FK			-- tasa De Cambio Actual
- currencyID1 FK			-- Divisa base
- currencyID2	FK			-- Divisa destino
- exchangerate decimal(20,4)			-- Factor multiplicativo
- userID FK
- post timestamp
- checksum bytea

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
- checksum BYTEA

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
- checksum BYTEA

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
- checksum BYTEA

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

## Logs:
- logID PK
- eventTypeID FK
- description varchar(255)
- sourceID FK
- severityID FK
- postTime Timestamp
- userID FK
- checksum BYTEA
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
- checksum BYTEA

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
- checksum BYTEA

## DataObjects:
- dataObjectID PK
- dataObjectName varchar(63)
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum BYTEA

## Hubs:
- hubId PK
- hubName varchar(30)
- addressID FK
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum BYTEA

## InventoryXHub:
- inventoryId PK
- hubId FK
- productID FK
- quantity integer
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum BYTEA

## MovementXInventory:
- movementId PK
- productID FK
- type varchar(10)
- quantity integer
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum BYTEA

## ImportationStates:
- importationStateId PK
- name varchar(20)

## Demands:
- demandId PK
- countryId FK
- quantity integer
- productID FK
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum BYTEA

## Importation:
- importationID PK
- providerID FK
- demandId FK
- description varchar(256)
- logId FK
- currencyID FK
- exchangeRate FK
- subtotalAmount decimal(19,4)
- taxRate decimal(5,4)
- shippingFee decimal(19,4)
- service decimal(19,4)
- totalAmount decimal(19,4)
- importationStateID FK
- createdAt TIMESTAMP
- updatedAt TIMESTAMP
- createdBy FK			-- UserID
- updatedBy FK			-- UserID
- enabled BOOLEAN
- checksum BYTEA

## ProductsXImportation:
- productsXImportationID PK
- productID FK
- quantity integer
- currencyID FK
- price decimal(19,4)
- importationID FK

