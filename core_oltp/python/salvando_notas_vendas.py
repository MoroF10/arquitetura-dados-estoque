# Importando bibliotecas 
import os
from lxml import etree
import psycopg2

# --- Configurações de conexão ---
user = os.getenv("DB_USER")
senha = os.getenv("DB_PASSWORD")
host = os.getenv("DB_HOST")
porta = os.getenv("DB_PORT")
banco = os.getenv("DB_NAME")
schema = "core"     

ns = {"nfe": "http://www.portalfiscal.inf.br/nfe"}  

#Função que trabalha os dados da nota por item , separa eles por linha e quantidade e preço
def itens_venda(caminho):

    tree = etree.parse(caminho)
    itens = tree.xpath("//nfe:det", namespaces=ns) 

    itens_venda = []

    for item in itens:
        numero_item = item.get("nItem")  # atributo da tag <det>
        
        codigo_produto = item.xpath(".//nfe:cProd/text()", namespaces=ns)
        quantidade = item.xpath(".//nfe:qCom/text()", namespaces=ns)
        preco_unitario_vendido = item.xpath(".//nfe:vUnCom/text()", namespaces=ns)
    
        item_dict = {
            "numero_linha": numero_item,
            "codigo_produto": codigo_produto[0] if codigo_produto else None,
            "quantidade": float(quantidade[0]) if quantidade else 0.0,
            "preco_unitario_vendido": float(preco_unitario_vendido[0]) if preco_unitario_vendido else 0.0
        }
    
        itens_venda.append(item_dict)

    return itens_venda

def get_value(xpath_result, default=None):
    return xpath_result[0] if xpath_result else default

#Função que altera a forma de pagamento para número
def map_forma_pagamento(tpag, xpag=None):

    mapping_tpag = {
        "01": 1,  # Dinheiro
        "03": 3,  # Crédito
        "04": 2,  # Débito
        "17": 4  # PIX oficial
    }

    # Se não for 99, usa o código direto
    if tpag != "99":
        return mapping_tpag.get(tpag, 0)

    # Se for 99, precisamos olhar o xPag
    mapping_xpag = {
        "PIX": 4,
        "PIX POS": 4,
        "POS CREDITO": 3,
        "POS DEBITO": 2,
        "Dinheiro": 1
    }

    return mapping_xpag.get(xpag, 0)

#Função que retorna os dados gerais da venda por nota 
def dados_venda(caminho):

    tree = etree.parse(caminho)
    tpag = get_value(
        tree.xpath("//nfe:pag/nfe:detPag/nfe:tPag/text()", namespaces=ns),
        ""
    )
    xpag = get_value(
        tree.xpath("//nfe:pag/nfe:detPag/nfe:xPag/text()", namespaces=ns),
        ""
    )
    dados_venda = {
        'numero_nota': get_value(
            tree.xpath("//nfe:protNFe/nfe:infProt/nfe:chNFe/text()", namespaces=ns)
        ),
    
        'data_venda': get_value(
            tree.xpath("//nfe:ide/nfe:dhEmi/text()", namespaces=ns)
        ),
    
        'valor_total': float(
            get_value(
                tree.xpath("//nfe:total/nfe:ICMSTot/nfe:vProd/text()", namespaces=ns),
                0
            )
        ),
    
        'valor_imposto': float(
            get_value(
                tree.xpath("//nfe:total/nfe:ICMSTot/nfe:vTotTrib/text()", namespaces=ns),
                0
            )
        ),
        'id_forma_pagamento': map_forma_pagamento(tpag, xpag)
     
        
        
    }
    return (dados_venda)

#Função que insere os dados de venda e do item de venda direto no banco 
def inserir_venda(conn, dados_venda, itens_venda):
    cur = conn.cursor()

    try:
        # Inserir venda
        cur.execute("""
            INSERT INTO core.venda 
            (numero_nota, data_venda, valor_total, valor_imposto, id_forma_pagamento)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (numero_nota) DO NOTHING
            RETURNING id_venda
        """, (
            dados_venda["numero_nota"],
            dados_venda["data_venda"],
            dados_venda["valor_total"],
            dados_venda["valor_imposto"],
            dados_venda["id_forma_pagamento"]
        ))

        resultado = cur.fetchone()
        

        if resultado is None:
            print(f"Nota {dados_venda['numero_nota']} já existe. Pulando inserção.")
            conn.rollback()
            return

        id_venda = resultado[0]

        # Inserir itens
        for item in itens_venda:
            cur.execute("""
                INSERT INTO core.item_venda
                (id_venda, codigo_produto, numero_linha, quantidade, preco_unitario_vendido)
                VALUES (%s, %s, %s, %s, %s)
            """, (
                id_venda,
                item["codigo_produto"],
                item["numero_linha"],
                item["quantidade"],
                item["preco_unitario_vendido"]
            ))

        conn.commit()
        print(f"Venda {dados_venda['numero_nota']} inserida com sucesso!")

    except Exception as e:
        conn.rollback()
        print(f"Erro ao inserir venda {dados_venda['numero_nota']}:", e)

    finally:
        cur.close()


#Função que processa a pasta com os arquivos XML, limpa e insere no banco 
def processar_pasta(pasta, conn):

    for arquivo in os.listdir(pasta):
        if arquivo.endswith(".xml"):

            caminho = os.path.join(pasta, arquivo)

            if not os.path.exists(caminho):
                print(f"Arquivo não encontrado: {caminho}")
                continue

            try:
                lista_itens = itens_venda(caminho)
                dados = dados_venda(caminho)

                inserir_venda(conn, dados, lista_itens)

            except Exception as e:
                print(f"Erro ao processar arquivo {arquivo}: {e}")


def main():
    try:
        conn = psycopg2.connect(
            dbname=banco,
            user=user,
            password=senha,
            host=host,
            port=porta
        )

        caminho = ''
        processar_pasta(caminho, conn)

    except Exception as e:
        print("Erro ao conectar ao banco de dados:", e)

    conn.close()

if __name__ == "__main__":
    main()
