import psycopg2
import os
from dotenv import load_dotenv
from ingestion.extract_bronze import extract_bronze

# Carrega credenciais
load_dotenv(dotenv_path="config/.env")


def get_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD")
    )


def execute_sql_file(filepath):
    """Lê e executa um arquivo SQL no Postgres"""
    with open(filepath, "r", encoding="utf-8") as f:
        sql = f.read()

    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute(sql)
        conn.commit()
        print(f"✅ {filepath} executado com sucesso")

    except Exception as e:
        conn.rollback()
        print(f"❌ Erro ao executar {filepath}: {e}")
        raise

    finally:
        cur.close()
        conn.close()


def run_pipeline():
    print(" Iniciando pipeline Bronze → Silver → Gold → Quality Checks")
    print("=" * 50)

    # 1. Bronze
    print(" Etapa 1: Extração Bronze")
    extract_bronze()

    # 2. Silver
    print(" Etapa 2: Transformação Silver")
    execute_sql_file("transform/silver_transform.sql")

    # 3. Dimensões Silver
    print(" Etapa 3: Criando Dimensões")
    execute_sql_file("transform/silver_dimensions.sql")

    # 4. Gold
    print(" Etapa 4: Agregações Gold")
    execute_sql_file("transform/gold_aggregations.sql")

    # 5. Quality Checks
    print(" Etapa 5: Data Quality Checks")
    execute_sql_file("transform/quality_checks.sql")

    print("\n" + "=" * 50)
    print(" Pipeline concluído com sucesso!")


if __name__ == "__main__":
    run_pipeline()