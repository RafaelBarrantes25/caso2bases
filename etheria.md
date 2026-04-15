# Database engine: PostgreSQL18

# Database name: Etheria

Context: Tenemos un holding comercial que opera bajo un modelo de negocio híbrido de importación y ventas digitales de alta gama. Esta base de datos es de una empresa que se encarga de la cadena de suministro.

# Tables:

-- Tablas de infraestructura y normalización de ubicaciones

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
- activa boolean

## TiposDeProducto:

- tipoProductoId PK
- nombreTipo varchar(50)

## Medidas:

- medidaId PK
- unidad varchar(20)
- capacidad decimal(10,2)

## Proveedores:

- proveedorID PK
- nombre varchar(64)
- emailContacto varchar(254)
- telefonoContacto varchar(20)
- ubicacionID FK

## Productos:

- productoId PK
- nombre varchar(80)
- tipoProductoId FK
- descripcion varchar(300)
- medidaId FK
- precioBaseUSD decimal(19, 4)
- descontinuado boolean
- checksum varchar(64)

## MovimientosInventario:

- movimientoId PK
- productoID FK
- tipo varchar(10)
- cantidad integer
- fecha timestamp

-- Flujo de operación con trazabilidad económica y auditoría

## EstadosImportacion:

- estadoImportacionId PK
- nombre varchar(20)

## Importaciones:

- importacionID PK
- proveedorID FK
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
