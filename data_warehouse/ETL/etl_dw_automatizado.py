import os
from datetime import datetime
import psycopg2


def etl_dw():

    conn = psycopg2.connect(
        host=os.getenv("DB_HOST"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD")
    )

    cur = conn.cursor()

    try:

        cur.execute("CALL dw.carga_completa();")
        conn.commit()

        cur.execute("""
            SELECT MAX(data_id)
            FROM dw.fato_estoque_snapshot
        """)
        ultima_data = cur.fetchone()[0]

        print("Último snapshot gerado:", ultima_data)

        cur.execute("""
            SELECT
                MAX(data_id),
                COUNT(*)
            FROM dw.fato_estoque_snapshot
        """)

        _, qtd_registros = cur.fetchone()

        print("Quantidade de registros:", qtd_registros)

        print(f"ETL finalizado: {datetime.now()}")

    except Exception as e:

        conn.rollback()
        print("Erro no ETL:", e)

    finally:

        cur.close()
        conn.close()


def main():

    print(f"Iniciando ETL: {datetime.now()}")

    etl_dw()


if __name__ == "__main__":
    main()


