from datetime import datetime

import pandas as pd
import psycopg2
from sqlalchemy import create_engine, URL

from airflow.sdk import DAG, task
from airflow.hooks.base import BaseHook


def get_db_config():
    connection = BaseHook.get_connection("netflix_postgres")

    return {
        "host": connection.host,
        "port": connection.port,
        "dbname": connection.schema,
        "user": connection.login,
        "password": connection.password,
    }


def execute_sql_file(filepath):
    with open(filepath, "r", encoding="utf-8") as file:
        sql = file.read()

    conn = psycopg2.connect(**get_db_config())
    cursor = conn.cursor()

    try:
        cursor.execute(sql)
        conn.commit()

    except Exception:
        conn.rollback()
        raise

    finally:
        cursor.close()
        conn.close()


with DAG(
    dag_id="netflix_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    tags=["netflix", "data-engineering"],
) as dag:

    @task
    def extract_bronze():
        db = get_db_config()

        db_url = URL.create(
            drivername="postgresql+psycopg2",
            username=db["user"],
            password=db["password"],
            host=db["host"],
            port=db["port"],
            database=db["dbname"],
        )

        engine = create_engine(db_url)

        try:
            df = pd.read_csv("/opt/airflow/data/netflix_titles.csv")

            with engine.begin() as conn:
                df.to_sql(
                    name="bronze_netflix",
                    con=conn,
                    if_exists="replace",
                    index=False,
                )

            print(f"Bronze carregada com sucesso: {len(df)} registros.")

        finally:
            engine.dispose()

    @task
    def transform_silver():
        execute_sql_file("/opt/airflow/transform/silver_transform.sql")
        print("Silver criada com sucesso.")

    @task
    def create_dimensions():
        execute_sql_file("/opt/airflow/transform/silver_dimensions.sql")
        print("Dimensões e bridges criadas com sucesso.")

    @task
    def aggregate_gold():
        execute_sql_file("/opt/airflow/transform/gold_aggregations.sql")
        print("Gold criada com sucesso.")

    @task
    def quality_checks():
        execute_sql_file("/opt/airflow/transform/quality_checks.sql")
        print("Quality checks executados com sucesso.")

    bronze = extract_bronze()
    silver = transform_silver()
    dimensions = create_dimensions()
    gold = aggregate_gold()
    quality = quality_checks()

    bronze >> silver >> dimensions >> gold >> quality