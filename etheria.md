Database engine: PostgreSQL18
Database name: Etheria

Context: Ustedes han sido contratados por un holding comercial que opera bajo un modelo de negocio híbrido de importación y ventas digitales de alta gama. Esta empresa se encarga de la cadena de suministro. Importan productos naturales y curativos exóticos de todo el mundo (bebidas, alimentos, cosmética dermatológica, capilar, aromaterapia, jabones y aceites esenciales).
Todos los productos son de gama alta y poseen propiedades medicinales/saludables.
Se importan en "bulk" (cajas sin marca ni etiquetado) en dólares (USD).
Todo llega a un centro logístico en la costa Caribe de Nicaragua.

# Tables:

## Productos:
- productoId PK
- medidaId FK
- precioId FK
- paisId FK
- tipoProductoId FK
- nombre varchar(40)
- descripcion varchar(200)
- activo boolean

## TipoProducto:
- tipoProductoId PK
- nombreTipo varchar(20)

## Medidas:
- medidaId PK
- unidad varchar(20)
- cantidad float(5)

## Precio:
- precioId FK
- moneda varchar(20)
- valor float(10)

## Pais:
- paisId PK
- paisOrigen varchar(20)
- paisDestino varchar (20)
