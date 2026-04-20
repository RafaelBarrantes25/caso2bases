Database engine: MySQL
Database name: Dynamic

Context: Tenemos un holding comercial que opera bajo un modelo de negocio híbrido de importación y ventas digitales de alta gama.
Esta base de datos es de una empresa de base tecnológica donde han desarrollado una IA capaz de generar sitios de e-commerce dinámicos.
A partir de parámetros (logo, enfoque, país), la IA despliega tiendas virtuales con marcas blancas.
Pueden abrir y cerrar "N" sitios en diferentes países de Latam con un solo clic, cada uno con un enfoque de marketing y mensajes distintos para el mismo producto base.

#Tables:
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

-- HAY QUE AÑADIR PRODUCTS

## WebSites:
- webSiteID PK
- webSiteName varchar(32)
- URL varchar(255)
- logoURL varchar(255)
- focus varchar(255)
- targetAudience varchar(30)
- addressID FK			-- Esto tal vez haya que usar el modelo de officeAdress del profe o solo poner CountryID
- enabled boolean 

## Ordenes:
- ordenID PK
- numeroOrden varchar(32) UNIQUE
- sitioWebID FK
- clienteID FK
- countryId FK
- importacionID FK
- fechaCreacion timestamp
- currencyId FK
- tasaCambioHistorica decimal(12, 6)
- montoTotal decimal(19, 4)
- estadoId FK
- checksum varchar(64)

## ProductosXOrden:
- productosXOrdenID PK
- productoLocalID FK
- cantidad integer
- precioVentaHistorico decimal(19, 4)
- ordenID FK

## CourierServices:
- courierServiceID PK
- nombre varchar(64)
- ubicacionID FK

## EstadosEnvio:
- estadoEnvioId PK
- nombre varchar(20)

## Paquetes:
- paqueteID PK
- ordenID FK
- ubicacionActualID FK
- ubicacionDestinoID FK
- courierServiceID FK
- estadoEnvioId FK

## Envios:
- envioId PK
- paqueteID FK
- fechaSalida timestamp
- fechaEntrega timestamp
- costoTotal decimal(19,4)

## CostosLogisticos:
- costoLogisticoId PK
- paqueteID FK
- tipo varchar(20)
- monto decimal(19,4)
- moneda varchar(10)

## ProductosXPaquete:
- productosXPaqueteID PK
- productoLocalID FK
- cantidad integer
- paqueteID FK

