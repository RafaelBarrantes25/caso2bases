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
- nombreTipo varchar(20)

## Medidas:
- medidaId PK
- unidad varchar(20)
- capacidad float(5)

## Proveedores:
- proveedorID PK
- nombre varchar(32)
- emailContacto varchar(64)
- telefonoContacto varchar(20)
- ubicacionID FK

## Productos:
- productoId PK
- nombre varchar(40)
- tipoProductoId FK
- descripcion varchar(200)
- medidaId FK
- precioBaseUSD decimal(19, 4)
- stockActual integer
- descontinuado boolean
- checksum varchar(64)

-- Flujo de operación con trazabilidad económica y auditoría
## Importaciones:
- importacionID PK
- proveedorID FK
- descripcion varchar(256)
- fechaCreacion timestamp
- subtotalUSD decimal(19, 4)
- impuestosUSD decimal(19, 4)
- fleteUSD decimal(19, 4)
- totalUSD decimal(19, 4)
- estado varchar(15)
- creadoPor varchar(32)

## ProductosXImportacion:
- productosXImportacionID PK
- productoID FK
- cantidad integer
- costoUnitarioUSD decimal(19, 4)
- importacionID FK
