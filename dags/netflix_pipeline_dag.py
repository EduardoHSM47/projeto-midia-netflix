from datetime import datetime

import psycopg2
import pandas as pd
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

        df = pd.read_csv("/opt/airflow/data/netflix_titles.csv")

        connection_string = (
            f"postgresql://{db['user']}:{db['password']}"
            f"@{db['host']}:{db['port']}/{db['dbname']}"
        )

        df.to_sql(
            name="bronze_netflix",
            con=connection_string,
            if_exists="replace",
            index=False,
        )

        print(f"Bronze carregada com sucesso: {len(df)} registros.")

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