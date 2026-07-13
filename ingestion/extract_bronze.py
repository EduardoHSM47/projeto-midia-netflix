import pandas as pd
import psycopg2
from dotenv import load_dotenv
import os

# Carrega as credenciais do .env
load_dotenv(dotenv_path="config/.env")

# Configurações de conexão
conn = psycopg2.connect(
    host=os.getenv("DB_HOST"),
    port=os.getenv("DB_PORT"),
    dbname=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD")
)

print("Conectado ao Postgres com sucesso")

# Lê o csv bruto sem transformar nada
df = pd.read_csv("data/netflix_titles.csv")

print(f"CSV carregado: {len(df)} linhas, {len(df.columns)} colunas")

# Grava no postgres como Camada Bronze (Exatamente como veio)

df.to_sql(
    name="bronze_netflix",
    con=f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}",
    if_exists="replace",
    index=False
)

print("Bronze carregado no Postgres com sucesso!")

conn.close()