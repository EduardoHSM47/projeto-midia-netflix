import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, URL

load_dotenv(dotenv_path="config/.env")


def extract_bronze():
    db_url = URL.create(
        drivername="postgresql+psycopg2",
        username=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST"),
        port=int(os.getenv("DB_PORT")),
        database=os.getenv("DB_NAME"),
    )

    engine = create_engine(db_url)

    try:
        df = pd.read_csv("data/netflix_titles.csv")
        print(f"CSV carregado: {len(df)} linhas, {len(df.columns)} colunas")

        with engine.begin() as conn:
            print("Conectado ao Postgres com sucesso")

            df.to_sql(
                name="bronze_netflix",
                con=conn,
                if_exists="replace",
                index=False
            )

        print("Bronze carregado no Postgres com sucesso!")

    finally:
        engine.dispose()