# Database engine: MySQL
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

