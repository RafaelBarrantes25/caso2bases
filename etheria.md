Database engine: PostgreSQL18
Database name: Etheria

Context: Tenemos un holding comercial que opera bajo un modelo de negocio híbrido de importación y ventas digitales de alta gama.
Esta base de datos es de una empresa que se encarga de la cadena de suministro. Importan productos naturales y curativos exóticos de todo el mundo (bebidas, alimentos, cosmética dermatológica, capilar, aromaterapia, jabones y aceites esenciales).
Todos los productos son de gama alta y poseen propiedades medicinales/saludables.
Se importan en "bulk" (cajas sin marca ni etiquetado) en dólares (USD).
Todo llega a un centro logístico en la costa Caribe de Nicaragua.

# Tables:
-- Tablas necesarias para otras tablas
## Ubicaciones:
- ubicacionId PK
- pais varchar(20)
- provincia varchar(20)
- ciudad varchar(20)
- direccion varchar(128)

## TiposDeProducto:
- tipoProductoId PK
- nombreTipo varchar(20)

## Medidas:
- medidaId PK
- unidad varchar(20)
- cantidad float(5)

## Proveedores:
- proveedorID PK
- nombre varchar(32)
- ubicacionID FK

## Productos:
- productoId PK
- nombre varchar(40)
- tipoProductoId FK
- descripcion varchar(200)
- medidaId FK
- precioUSD decimal(19, 4)
- cantidad integer					-- Si >= 0 se solicita una importación
- descontinuado boolean

-- Comienzo del flujo de operación
## Importaciones:
- importacionID PK
- proveedorID PK
- descripcion varchar(256)
- fechaCreacion timestamp
- precioUSD decimal(19, 4)
- estado varchar(9)				-- Entregada, activa, cancelada

## ProductosXImportacion:
- productosXImportacionID PK
- productoID FK
- cantidad integer
- importacionID FK

-- Creo que esto se puede borrar
## Exportaciones:
- exportacionID PK
- productoID FK
- cantidad integer
- fecha TIMESTAMP
- precioID FK
- proveedorID FK
