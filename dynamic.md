# Database engine: MySQL
# Database name: Dynamic

Context: Holding comercial que opera bajo un modelo de negocio híbrido. Empresa de base tecnológica con IA capaz de generar sitios de e-commerce dinámicos.

# Tables:
-- Estándar de moneda (Currency Pattern) y localización
## Currencies:
- currencyId PK
- moneda varchar(20)
- simbolo char
- tasaCambioUSD decimal(12, 6)
- ultimaActualizacion timestamp

## Ubicaciones:
- ubicacionId PK
- pais varchar(20)
- provincia varchar(20)
- ciudad varchar(20)
- direccion varchar(128)

## SitiosWeb:
- sitioWebID PK
- nombre varchar(32)
- URL varchar(100)
- logo_url varchar(255)
- enfoque varchar(256)
- config_json json
- currencyId FK
- ubicacionID FK
- abierto boolean

## ProductosLocales:
- productoLocalId PK
- productoRemotoID INT
- sitioWebID FK
- precioLocal decimal(19, 4)
- enExistencia boolean

## Clientes:
- clienteID PK
- nombre varchar(32)
- email varchar(32)
- password_hash varchar(255)
- ubicacionID FK
- fechaRegistro timestamp

## Ordenes:
- ordenID PK
- numeroOrden varchar(32)
- sitioWebID FK
- clienteID FK
- fechaCreacion timestamp
- currencyId FK
- tasaCambioHistorica decimal(12, 6)
- montoTotal decimal(19, 4)
- estado varchar(15)
- checksum varchar(64)

## ProductosXOrden:
- productosXOrdenID PK
- productoLocalID FK
- cantidad integer
- precioVentaHistorico decimal(19, 4)
- ordenID FK

## CourierServices:
- courierServiceID PK
- nombre varchar(32)
- ubicacionID FK

## Paquetes:
- paqueteID PK
- ordenID FK
- ubicacionActualID FK
- ubicacionDestinoID FK
- requisitosLegales varchar(256)
- permisosDeSalud varchar(256)
- courierServiceID FK
- estadoEnvio varchar(20)

## ProductosXPaquete:
- productosXPaqueteID PK
- productoLocalID FK
- cantidad integer
- paqueteID FK
