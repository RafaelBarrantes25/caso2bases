-- 1. Instalar la extensión
CREATE EXTENSION mysql_fdw;

-- 2. Crear el servidor remoto (usamos el nombre del contenedor de MySQL)
CREATE SERVER mysql_server
FOREIGN DATA WRAPPER mysql_fdw
OPTIONS (host 'db_mysql', port '3306');

-- 3. Crear el mapeo de usuario
CREATE USER MAPPING FOR "user"
SERVER mysql_server
OPTIONS (username 'user', password 'pass');

-- 4. Importar las tablas (Esto traerá las tablas de Dynamic Brands a Postgres)
IMPORT FOREIGN SCHEMA Dynamic
FROM SERVER mysql_server
INTO public;
