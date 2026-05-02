import pandas as pd
from sqlalchemy import create_engine
import sys

def main():
    try:
        print("🚀 Iniciando integración de datos para Dashboard Gerencial...")

        # Configuración de motores basada en docker-compose.yml[cite: 4]
        # Etheria (PostgreSQL) y Dynamic (MySQL)
        pg_engine = create_engine('postgresql://user:pass@localhost:5432/Etheria')
        my_engine = create_engine('mysql+mysqlconnector://user:pass@localhost:3306/Dynamic')

        # EXTRACCIÓN - PostgreSQL (Etheria)
        # Nombres de tablas y columnas validados con esquema de Etheria[cite: 7]
        query_pg = """
            SELECT p.productID, p.name, pxp.price AS costPrice
            FROM Products p
            JOIN ProductsXProvider pxp ON p.productID = pxp.productID
        """
        df_etheria = pd.read_sql(query_pg, pg_engine)
        
        # EXTRACCIÓN - MySQL (Dynamic)
        # Nombres de tablas y columnas validados con esquema de Dynamic[cite: 5]
        query_my = """
            SELECT pws.productID, pws.price AS salePrice, w.webSiteName, c.countryCommonName 
            FROM ProductsXWebSite pws
            JOIN WebSites w ON pws.webSiteID = w.webSiteID
            JOIN Countries c ON w.countryID = c.countryID
        """
        df_dynamic = pd.read_sql(query_my, my_engine)

        print("📥 Datos extraídos exitosamente. Iniciando normalización...")

        # TRANSFORMACIÓN - Normalización de nombres para evitar KeyErrors
        # Convertimos todos los nombres de columnas a minúsculas en ambos mundos
        df_etheria.columns = [c.lower() for c in df_etheria.columns]
        df_dynamic.columns = [c.lower() for c in df_dynamic.columns]

        # Ahora el merge funcionará usando 'productid' (todo en minúsculas)
        df_final = pd.merge(df_dynamic, df_etheria, on='productid')

        # Ajustamos los cálculos usando los nuevos nombres en minúsculas
        # saleprice viene de Dynamic[cite: 6] y costprice de Etheria
        df_final['rentabilidad_abs'] = df_final['saleprice'] - df_final['costprice']
        df_final['margen_porc'] = (df_final['rentabilidad_abs'] / df_final['saleprice']) * 100

        print(f"🧪 {len(df_final)} registros procesados tras el cruce de bases.")

        # CARGA - Reporte en la base de Etheria
        df_final.to_sql('bi_reporte_gerencial', pg_engine, if_exists='replace', index=False)

        print("✅ ÉXITO: Tabla 'bi_reporte_gerencial' actualizada.")

    except Exception as e:
        print(f"❌ Error crítico: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
