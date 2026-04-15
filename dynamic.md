
# Database engine: MySQL

# Database name: Dynamic

Context: Holding comercial que opera bajo un modelo de negocio híbrido. Empresa de base tecnológica con IA capaz de generar sitios de e-commerce dinámicos.

# Tables:

-- Estándar de moneda (Currency Pattern) y localización normalizada

## Currencies:

- currencyId PK
- moneda varchar(20)
- simbolo char(5)
- tasaCambioUSD decimal(12, 6)
- ultimaActualizacion timestamp

## Countries:

- countryId PK
- isoCode varchar(3)
- nombre varchar(50)

## Ubicaciones:

- ubicacionId PK
- countryId FK
- provincia varchar(50)
- ciudad varchar(50)
- direccion varchar(128)

## SitiosWeb:

- sitioWebID PK
- nombre varchar(64)
- URL varchar(150)
- logo_url varchar(255)
- enfoque varchar(256)
- config_json json
- currencyId FK
- ubicacionID FK
- abierto boolean

## ProductosLocales:

- productoLocalId PK
- productoRemotoUUID char(36)
- sitioWebID FK
- precioLocal decimal(19, 4)
- enExistencia boolean

## Clientes:

- clienteID PK
- nombre varchar(64)
- email varchar(254) UNIQUE
- password_hash varchar(255)
- ubicacionID FK
- fechaRegistro timestamp

## EstadosOrden:

- estadoId PK
- nombre varchar(20)

## Ordenes:

- ordenID PK
- numeroOrden varchar(32) UNIQUE
- sitioWebID FK
- clienteID FK
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
- requisitosLegales varchar(256)
- permisosDeSalud varchar(256)
- courierServiceID FK
- estadoEnvioId FK

## ProductosXPaquete:

- productosXPaqueteID PK
- productoLocalID FK
- cantidad integer
- paqueteID FK


