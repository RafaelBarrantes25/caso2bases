Database engine: MySQL
Database name: Dynamic

Context: Ustedes han sido contratados por un holding comercial que opera bajo un modelo de negocio híbrido de importación y ventas digitales de alta gama.
Esta es una empresa de base tecnológica. Han desarrollado una IA capaz de generar sitios de e-commerce dinámicos.
A partir de parámetros (logo, enfoque, país), la IA despliega tiendas virtuales con marcas blancas.
Pueden abrir y cerrar "N" sitios en diferentes países de Latam con un solo clic, cada uno con un enfoque de marketing y mensajes distintos para el mismo producto base.

# Tables:

## Productos:
- productoId PK
- nombre varchar(40)
- descripcion varchar(200)

## Precio:
- precioId PK
- paisId FK
- moneda varchar(20)
- tasaCambio decimal(10,5)

## Pais:
- paisId PK
- paisOrigen varchar(20)
- paisDestino varchar(20)
