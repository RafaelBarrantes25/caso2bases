import pandas as pd
from sqlalchemy import create_engine
import sys

def main():
    try:
        print("🚀 Iniciando integración de datos para Dashboard Gerencial...")

        # 1. Configuración de motores (Asegúrate de que las contraseñas coincidan con tu Docker)
        pg_engine = create_engine('postgresql://user:pass@localhost:5432/Etheria')
        my_engine = create_engine('mysql+mysqlconnector://root:rootpass@localhost:3306/dynamic_db')

        query_pg = """
            SELECT p.productid, p.name, pxp.price AS costprice
            FROM Products p
            JOIN ProductsXProvider pxp ON p.productid = pxp.productid
        """
        df_etheria = pd.read_sql(query_pg, pg_engine)
        
        # 3. EXTRACCIÓN - MySQL (Dynamic Brands)
        # Se ajustó a los nombres exactos de 1tablas_dynamic.sql
        query_my = """
            SELECT pws.productID, pws.price AS salePrice, w.webSiteName, c.countryCommonName 
            FROM ProductsXWebSite pws
            JOIN WebSites w ON pws.webSiteID = w.webSiteID
            JOIN Countries c ON w.countryID = c.countryID
        """
        df_dynamic = pd.read_sql(query_my, my_engine)

        print("📥 Datos extraídos exitosamente.")

        # 4. TRANSFORMACIÓN
        # Unimos usando productid (minúscula de Postgres) y productID (CamelCase de MySQL)
        df_final = pd.merge(
            df_dynamic, 
            df_etheria, 
            left_on='productID', 
            right_on='productid'
        )

        # Cálculo de Indicadores
        df_final['rentabilidad_abs'] = df_final['salePrice'] - df_final['costprice']
        df_final['margen_porc'] = (df_final['rentabilidad_abs'] / df_final['salePrice']) * 100

        print(f"🧪 {len(df_final)} registros procesados y unificados.")

        # 5. CARGA
        df_final.to_sql('bi_reporte_gerencial', pg_engine, if_exists='replace', index=False)

        print("✅ ÉXITO: Tabla 'bi_reporte_gerencial' actualizada.")

    except Exception as e:
        print(f"❌ Error crítico: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
