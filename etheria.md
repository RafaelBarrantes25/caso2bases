# Database engine: PostgreSQL18

Database name: Etheria

Context: Tenemos un holding comercial que opera bajo un modelo de negocio híbrido de importación y ventas digitales de alta gama.
Esta base de datos es de una empresa que se encarga de la cadena de suministro. Importan productos naturales y curativos exóticos de todo el mundo (bebidas, alimentos, cosmética dermatológica, capilar, aromaterapia, jabones y aceites esenciales).
Todos los productos son de gama alta y poseen propiedades medicinales/saludables.
Se importan en "bulk" (cajas sin marca ni etiquetado) en dólares (USD).
Todo llega a un centro logístico en la costa Caribe de Nicaragua.

# Tables:


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
- adressID PK
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

## ProductType:
- productTypeId PK
- typeName varchar(50)

## Measurement:
- measurementId PK
- unit varchar(20)        -- Ej: ml, g, Kg
- quantity decimal(10,2)  -- Ej: 500, 1000, 1


## Providers:
- providerId PK
- nombre varchar(64)
- currencyId FK
- exchangerateId FK
- productsxproviderId FK
- emailContacto varchar(254)
- telefonoContacto varchar(20)
- ubicacionID FK

## ProductsXProvider
- productsxproviderId PK
- productId FK
- providerId FK
- currencyId FK



## Products:
- productId PK
- nombre varchar(80)
- tipoProductoId FK
- descripcion varchar(300)
- medidaId FK
- providerId FK
- precioBaseUSD decimal(19, 4)
- descontinuado boolean
- checksum varchar(64)


## Logs:
- logID PK
- eventTypeID FK
- description varchar(255)
- sourceID FK
- severityID FK
- postTime Timestamp
- userID FK
- checksum bytea
- dataObjectID1 FK
- dataObjectID2 FK

## EventTypes:
- EventTypeID PK
- LogType varchar(30)

## Sources:
- sourceID PK
- sourceName varchar(50) not null			-- Ej: Cliente, empleado, sistema
- clienteID FK

## Severities:
- severityID PK
- severityLevel tinyint				-- Ej: 0, 2, 5
- severityName varchar(10)			-- Ej: Emergency, Critical, Notice

## DataObjects:
- dataObjectID PK
- dataObjectName varchar(63)

## Hubs:
- hubId PK
- ubicacionID FK

## InventarioHub:
- inventarioId PK
- hubId FK
- productoID FK
- cantidad integer

## MovimientosInventario:
- movimientoId PK
- productoID FK
- tipo varchar(10)
- cantidad integer
- fecha timestamp

## EstadosImportacion:
- estadoImportacionId PK
- nombre varchar(20)

## DemandaImportacion:
- demandaId PK
- countryId FK
- cantidadDemandada integer
- fecha timestamp

## Importaciones:
- importacionID PK
- proveedorID FK
- demandaId FK
- descripcion varchar(256)
- logId FK
- subtotalUSD decimal(19, 4)
- impuestosUSD decimal(19, 4)
- fleteUSD decimal(19, 4)
- totalUSD decimal(19, 4)
- estadoImportacionId FK

## ProductosXImportacion:
- productosXImportacionID PK
- productoID FK
- cantidad integer
- costoUnitarioUSD decimal(19, 4)
- importacionID FK

