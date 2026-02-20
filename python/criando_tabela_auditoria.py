import csv
import psycopg2
from datetime import date
import os

# --- Configurações de conexão ---
user = os.getenv("DB_USER")
senha = os.getenv("DB_PASSWORD")
host = os.getenv("DB_HOST")
porta = os.getenv("DB_PORT")
banco = os.getenv("DB_NAME")
schema = "core"


def inserir_auditoria(conn, data_auditoria, observacoes):
    cur = conn.cursor()
    
    cur.execute("""
        INSERT INTO core.auditoria_estoque (data_auditoria, observacoes)
        VALUES (%s, %s)
        RETURNING id_auditoria;
    """, (data_auditoria, observacoes))
    
    id_auditoria = cur.fetchone()[0]
    
    return id_auditoria

def inserir_itens_auditoria(conn, id_auditoria, itens):
    cur = conn.cursor()
    
    for item in itens:
        cur.execute("""
            INSERT INTO core.item_auditoria_estoque
            (id_auditoria, codigo_produto, quantidade_sistema, quantidade_contada )
            VALUES (%s, %s, %s, %s);
        """, (
            id_auditoria,
            item['codigo_produto'],
            item['quantidade_sistema'],
            item['quantidade_contada']
            
        ))

def to_int_safe(valor):
    if valor is None or valor.strip() == '':
        return 0
    return int(float(valor.replace(',', '.')))

def processar_auditoria_csv(conn, caminho):
    try:
        cur = conn.cursor()
        
        # 1 - Criar auditoria
        id_auditoria = inserir_auditoria(
            conn,
            date.today(),
            "Auditoria via CSV"
        )
        
        # 2 - Ler CSV
        itens = []
        with open(caminho, newline='', encoding='utf-8-sig') as csvfile:
            reader = csv.DictReader(csvfile, delimiter=';')
            for row in reader:
                estoque_sistema = to_int_safe(row['quantidade_teorica'])
                estoque_fisico = to_int_safe(row['quantidade_contada'])
                itens.append({
                    'codigo_produto': int(row['codigo_produto']),
                    'quantidade_sistema': estoque_sistema,
                    'quantidade_contada': estoque_fisico,
                    
                })
        
        # 3 - Inserir itens
        inserir_itens_auditoria(conn, id_auditoria, itens)
        
        # 4 - Commit
        conn.commit()
        
        print(f"Auditoria {id_auditoria} inserida com sucesso.")
    
    except Exception as e:
        conn.rollback()
        print("Erro:", e)

    
#Dados da conexão com o banco
def main():
    try:
        caminho = ''
        conn = psycopg2.connect(
        database= "estoque_vendas",
        user=user,
        password=senha,
        host=host,
        port=porta
    )
        processar_auditoria_csv(conn, caminho)
        conn.close()
            
    except Exception as e:
        print(f"Erro na execução: {e}") 

if __name__ == "__main__":
    main()

conn.close()

