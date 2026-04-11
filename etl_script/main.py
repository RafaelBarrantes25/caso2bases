import pandas as pd
from sqlalchemy import create_engine

# Conexiones (usando los nombres de los servicios de Docker)
engine_eth = create_engine('postgresql://user:pass@db_postgres:5432/basepostgre')
engine_dyn = create_engine('mysql+pymysql://user:pass@db_mysql:3306/basemysql')

# 1. Extraer: Costos de importación de Etheria
df_costos = pd.read_sql("SELECT productoId, nombre, precioId FROM Productos", engine_eth)
df_precios_compra = pd.read_sql("SELECT precioId, valor FROM Precios", engine_eth)

# 2. Extraer: Ventas de Dynamic
df_ventas = pd.read_sql("SELECT productoID, cantidad, realizada FROM Ordenes", engine_dyn)
df_precios_venta = pd.read_sql("SELECT productoId, precioID FROM Productos", engine_dyn)

# 3. Transformar: Unificar por Nombre de Producto (Mapeo Semántico)
# Aquí es donde ocurre la magia que la gerencia no puede ver actualmente
dashboard_data = pd.merge(df_costos, df_ventas, left_on='productoId', right_on='productoID')

# 4. Cargar: Guardar en una nueva tabla de "Analítica" en Postgres
dashboard_data.to_sql('vista_gerencial_rentabilidad', engine_eth, if_exists='replace')
