from datetime import datetime
import psycopg2

print(f"Iniciando ETL: {datetime.now()}")

try:

    conn = psycopg2.connect(
        host = os.getenv("DB_HOST")
        database= os.getenv("DB_NAME")
        user= os.getenv("DB_USER")
        password= os.getenv("DB_PASSWORD")
    )

    cur = conn.cursor()

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
        FROM dw.fato_estoque_snapshot;
    """)

     qtd_inserida = cur.fetchone()[1]
     print("Quantidade de registros:", qtd_inserida)

    print(f"ETL finalizado: {datetime.now()}")


except Exception as e:

    print("Erro no ETL:", e)

finally:

    cur.close()
    conn.close()
