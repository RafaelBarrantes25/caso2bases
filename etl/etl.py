import pandas as pd
from sqlalchemy import create_engine
import sys

def main():
    try:
        pg_engine = create_engine('postgresql://user:pass@localhost:5432/Etheria')
        my_engine = create_engine('mysql+mysqlconnector://user:pass@localhost:3306/Dynamic')

        # --- 1. EXTRACCIÓN ETHERIA (Postgres) ---
        query_pg = """
            SELECT 
                p.productID,
                cat.categoryName AS categoria,
                pxp.price AS costo,
                'Costo Directo' AS tipo_costo,
                COALESCE(prov.name, 'Sin Marca') AS marca,
                COALESCE(co.countryCommonName, 'Sin País') AS pais_origen,
                EXTRACT(MONTH FROM pxp.createdAt) AS mes,
                EXTRACT(YEAR FROM pxp.createdAt) AS anio
            FROM Products p
            LEFT JOIN Categories cat ON p.categoryID = cat.categoryID
            LEFT JOIN ProductsXProvider pxp ON p.productID = pxp.productID
            LEFT JOIN Providers prov ON pxp.providerId = prov.providerID
            LEFT JOIN Addresses addr ON prov.addressID = addr.addressID
            LEFT JOIN Cities ci ON addr.cityID = ci.cityID
            LEFT JOIN States st ON ci.stateID = st.stateID
            LEFT JOIN Countries co ON st.countryID = co.countryID
        """
        df_pg = pd.read_sql(query_pg, pg_engine)
        # Normalizamos: forzamos minúsculas en los nombres de columnas del DF
        df_pg.columns = [c.lower() for c in df_pg.columns]

        # --- 2. EXTRACCIÓN DYNAMIC (MySQL) ---
        query_my = """
            SELECT 
                pws.productID,
                ws.webSiteName AS tienda,
                pws.price AS venta,
                co.countryCommonName AS pais_venta
            FROM ProductsXWebSite pws
            JOIN WebSites ws ON pws.webSiteID = ws.webSiteID
            JOIN Countries co ON ws.countryID = co.countryID
        """
        df_my = pd.read_sql(query_my, my_engine)
        # Normalizamos: forzamos minúsculas en los nombres de columnas del DF
        df_my.columns = [c.lower() for c in df_my.columns]

        # --- 3. TRANSFORMACIÓN: UNIÓN HORIZONTAL ---
        # Ahora usamos 'productid' en minúsculas para asegurar el match
        df_final = pd.merge(df_pg, df_my, on='productid', how='inner')

        # --- 4. CÁLCULOS ---
        df_final['rentabilidad'] = df_final['venta'] - df_final['costo']

        # Seleccionamos las columnas usando el nuevo estándar en minúsculas
        columnas_ordenadas = [
            'categoria', 'marca', 'tienda', 'pais_origen', 'pais_venta', 
            'tipo_costo', 'costo', 'venta', 'rentabilidad', 'mes', 'anio'
        ]
        df_reporte = df_final[columnas_ordenadas]

        # --- 5. CARGA ---
        # 'replace' borrará la tabla anterior automáticamente si ya existía
        df_reporte.to_sql('bi_reporte_gerencial', pg_engine, if_exists='replace', index=False)

        print(f"✅ ETL Exitoso: {len(df_reporte)} registros procesados.")

    except Exception as e:
        print(f"❌ Error en el proceso: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
