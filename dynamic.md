Database engine: MySQL
Database name: Dynamic

Context: Tenemos un holding comercial que opera bajo un modelo de negocio híbrido de importación y ventas digitales de alta gama.
Esta base de datos es de una empresa de base tecnológica donde han desarrollado una IA capaz de generar sitios de e-commerce dinámicos.
A partir de parámetros (logo, enfoque, país), la IA despliega tiendas virtuales con marcas blancas.
Pueden abrir y cerrar "N" sitios en diferentes países de Latam con un solo clic, cada uno con un enfoque de marketing y mensajes distintos para el mismo producto base.

# Tables:
-- Tablas necesarias para otras tablas
## Ubicaciones:
- ubicacionId PK
- pais varchar(20)
- provincia varchar(20)
- ciudad varchar(20)
- direccion varchar(128)

## PreciosLocales:
- precioLocalId PK
- moneda varchar(20)
- simbolo char
- tasaCambio decimal(10,5)
- activo boolean

-- "Puntero" a Productos en postgres de EtheriaGlobal (FEDERATED Storage Engine)
## ProductosRemotos:
- productoRemotoId PK
- productoID INT (FK Virtual -> PostgreSQL.Productos)
- nombre varchar(40)
- precioLocalID FK
- enExistencia boolean

-- Comienzo del flujo de operación
## SitiosWeb:
- sitioWebID PK
- nombre varchar (32)
- URL varchar (100)
- logo_url text
- enfoque varchar(256)
- ubicacionID FK
- abierto boolean

## ProductosXSitioWeb:
- productosXSitioWebID PK
- productoRemotoID FK
- SitioWebID FK

## Clientes:
- clienteID PK
- nombre varchar(32)
- email varchar(32)
- ubicacionID FK

## Ordenes:
- ordenID PK
- sitioWebID FK
- descripcion varchar(256)
- clienteID FK
- fechaCreacion timestamp
- precioLocalId PK
- estado varchar(9)				-- Entregada, activa, cancelada

## ProductosXOrden:
- productosXOrdenID PK
- productoRemotoID FK
- cantidad integer
- ordenID FK

## CourierServices:
- courierServiceID PK
- nombre varchar(32)
- ubicacionID FK

## Paquetes:
- paqueteID PK
- sitioWebEncargadoID FK
- ubicacionActualID FK
- ubicacionDestinoID FK
- requisitosLegales varchar(256)
- permisosDeSalud varchar(256)
- courierServiceID FK
- clienteID FK

## ProductosXPaquete:
- productosXPaqueteID PK
- productoRemotoID FK
- cantidad integer
- paqueteID FK
