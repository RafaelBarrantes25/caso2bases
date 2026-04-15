# Database engine: PostgreSQL18
## TiposDeProducto:
- tipoProductoId PK
- nombreTipo varchar(50)

## Medidas:
- medidaId PK
- unidad varchar(20)
- capacidad decimal(10,2)

## GlobalProducts:
- globalProductId char(36) PK
- tipoProductoId FK

## Proveedores:
- proveedorID PK
- nombre varchar(64)
- emailContacto varchar(254)
- telefonoContacto varchar(20)
- ubicacionID FK

## Productos:
- productoId PK
- globalProductId FK
- nombre varchar(80)
- tipoProductoId FK
- descripcion varchar(300)
- medidaId FK
- precioBaseUSD decimal(19, 4)
- descontinuado boolean
- checksum varchar(64)

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
- globalProductId FK
- countryId FK
- cantidadDemandada integer
- fecha timestamp

## Importaciones:
- importacionID PK
- proveedorID FK
- demandaId FK
- descripcion varchar(256)
- fechaCreacion timestamp
- subtotalUSD decimal(19, 4)
- impuestosUSD decimal(19, 4)
- fleteUSD decimal(19, 4)
- totalUSD decimal(19, 4)
- estadoImportacionId FK
- creadoPor varchar(64)

## ProductosXImportacion:
- productosXImportacionID PK
- productoID FK
- cantidad integer
- costoUnitarioUSD decimal(19, 4)
- importacionID FK

