CREATE VIEW vista_indicadores_gerenciales AS
SELECT 
    p.nombre AS producto_sourcing,
    pl.nombre AS nombre_marca_ia, -- Tabla de MySQL
    sw.nombre AS sitio_web,        -- Tabla de MySQL
    p.precioBaseUSD AS costo_usd,
    o.montoTotal AS venta_local,   -- Tabla de MySQL
    (o.montoTotal / o.tasaCambioHistorica) - p.precioBaseUSD AS utilidad_real_usd
FROM Productos p
JOIN ProductosLocales pl ON p.globalProductId = pl.globalProductId
JOIN ProductosXOrden pxo ON pl.productoLocalId = pxo.productoLocalID
JOIN Ordenes o ON pxo.ordenID = o.ordenID
JOIN SitiosWeb sw ON o.sitioWebID = sw.sitioWebID;
