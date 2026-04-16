FROM postgres:latest

# Instalar las dependencias para el Foreign Data Wrapper de MySQL
RUN apt-get update && apt-get install -y \
    postgresql-17-mysql-fdw \
    && rm -rf /var/lib/apt/lists/*
