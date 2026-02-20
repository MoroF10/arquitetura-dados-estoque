import os
from lxml import etree
import re
from datetime import datetime
import psycopg2 

# --- Configurações de conexão ---
user = os.getenv("DB_USER")
senha = os.getenv("DB_PASSWORD")
host = os.getenv("DB_HOST")
porta = os.getenv("DB_PORT")
banco = os.getenv("DB_NAME")
schema = "core"

ns = {"nfe": "http://www.portalfiscal.inf.br/nfe"}

#Função para extrair a quantidade de unidade que vem em uma caixa
def extrair_unidades_por_caixa(descricao):
    if not descricao:
        return None

    match = re.search(r'(\d+)UN$', descricao.upper())
    if match:
        return match.group(1).strip()
    
    return descricao.strip()

#função para limpar o nome do produto, deixando apenas o nome
def separar_nome_embalagem(descricao):
    if not descricao:
        return None

    # Pega padrão tipo 30GX90UN, 500G, 2L, 12UN etc no final da string
    match = re.search(r'(.+?)\s+([\dA-ZxX]+)$', descricao)

    if match:
        nome = match.group(1).strip()
        return nome
    else:
        return descricao.strip(), None

#Função que le o XML e pega os dados que serão usados 
def itens_venda(caminho):

    tree = etree.parse(caminho)
    itens = tree.xpath("//nfe:det", namespaces=ns) 

    itens_venda = []

    for item in itens:
        numero_item = item.get("nItem")  # atributo da tag <det>
        numero_nota = tree.xpath(".//nfe:nNF/text()", namespaces=ns)
        data_emissao = tree.xpath(".//nfe:ide/nfe:dhEmi/text()", namespaces=ns)
        codigo_produto = item.xpath(".//nfe:cProd/text()", namespaces=ns)
        nome_produto =  item.xpath(".//nfe:xProd/text()", namespaces=ns)
        quantidade_caixas = item.xpath(".//nfe:qCom/text()", namespaces=ns)
        quantidade_caixas = float(quantidade_caixas[0]) if quantidade_caixas else 0.0
        preco_unitario_vendido = item.xpath(".//nfe:vProd/text()", namespaces=ns)
        preco_unitario_vendido = float(preco_unitario_vendido[0]) if preco_unitario_vendido else 0.0
        lote = item.xpath(".//nfe:rastro/nfe:nLote/text()", namespaces=ns)
        data_fabricacao = item.xpath(".//nfe:rastro/nfe:dFab/text()", namespaces=ns)
        data_validade = item.xpath(".//nfe:rastro/nfe:dVal/text()", namespaces=ns)
        icms = item.xpath(".//nfe:imposto/nfe:ICMS/nfe:ICMS00/nfe:vICMS/text()", namespaces=ns)
        icms = float(icms[0]) if icms else 0.0
        ipi = item.xpath(".//nfe:imposto/nfe:IPI/nfe:IPITrib/nfe:vIPI/text()", namespaces=ns)
        ipi = float(ipi[0]) if ipi else 0.0
        pis = item.xpath(".//nfe:imposto/nfe:PIS/nfe:PISAliq/nfe:vPIS/text()", namespaces=ns)
        pis = float(pis[0]) if pis else 0.0
        cofins = item.xpath(".//nfe:imposto/nfe:COFINS/nfe:COFINSAliq/nfe:vCOFINS/text()", namespaces=ns)
        cofins = float(cofins[0]) if cofins else 0.0

        descricao = nome_produto[0] if nome_produto else None
        nome_limpo = separar_nome_embalagem(descricao)
        unidades_por_caixa = extrair_unidades_por_caixa(descricao)
        quantidade_total = None
        if unidades_por_caixa and quantidade_caixas:
            quantidade_total = int(unidades_por_caixa * quantidade_caixas)
        produto_mais_impostos = preco_unitario_vendido + icms + ipi+ pis + cofins
        preco_unidade = produto_mais_impostos / quantidade_total if quantidade_total else 0.0
        
        
        item_dict = {
            "numero_linha": numero_item,
            "numero_nota" : int(numero_nota[0]) if numero_nota else None,
            "data_emissao" : data_emissao[0] if data_emissao else None,
            "codigo_produto": int(codigo_produto[0]) if codigo_produto else None,
            "nome_produto": nome_limpo,
            "quantidade_total": quantidade_total,
            "preco_unitario_vendido": preco_unitario_vendido,
            "lote": lote[0] if lote else None,
            "data_fabricacao": data_fabricacao[0] if data_fabricacao else None,
            "data_validade": data_validade[0] if data_validade else None,
            "icms": icms,
            "ipi": ipi,
            "pis": pis,
            "cofins": cofins,
            "produto_mais_impostos": produto_mais_impostos,
            "preco_unidade": preco_unidade,
            "id_tipo_movimentacao" : 1 
        }
    
        itens_venda.append(item_dict)

    return itens_venda

#Função para inserir os dados no banco de dados, separando a venda dos itens de venda
def inserir_venda(conn, itens):
    cur = conn.cursor()

    try:
        if not itens:
            print("Nenhum item encontrado.")
            return

        # Pegando dados do documento a partir do primeiro item
        numero_nota = itens[0]["numero_nota"]
        data_emissao = itens[0]["data_emissao"]

        # Inserir documento
        cur.execute("""
            INSERT INTO core.documento_entrada
            (numero_nota, data_emissao)
            VALUES (%s, %s)
            ON CONFLICT (numero_nota) DO NOTHING
            RETURNING id_documento_entrada
        """, (numero_nota, data_emissao))

        resultado = cur.fetchone()

        if resultado:
            id_documento_entrada = resultado[0]
        else:
            # Se já existe, buscar o id
            cur.execute("""
                SELECT id_documento_entrada
                FROM core.documento_entrada
                WHERE numero_nota = %s
            """, (numero_nota,))
            
            id_documento_entrada = cur.fetchone()[0]

        # Inserir itens
        for item in itens:
            
            cur.execute("""
                INSERT INTO core.produto (codigo_produto, id_classe, nome_produto, id_tipo_produto, status_cadastro, produto_controla_estoque)
                VALUES (%s, %s, %s, %s, %s, %s)
                ON CONFLICT (codigo_produto) DO NOTHING
            """, (
                item["codigo_produto"],
                22,
                item["nome_produto"],
                1,
                "PENDENTE",
                True
            ))
            cur.execute("""
                INSERT INTO core.item_entrada
                (codigo_produto, id_documento_entrada, quantidade, valor_produto, lote, 
                 data_fabricacao, data_vencimento, icms, ipi, pis, cofins, custo_total_item)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id_item_entrada
            """, (
                item["codigo_produto"],
                id_documento_entrada,
                item["quantidade_total"],
                item["preco_unitario_vendido"],
                item["lote"],
                item["data_fabricacao"],
                item["data_validade"],
                item["icms"],
                item["ipi"],
                item["pis"],
                item["cofins"],
                item["produto_mais_impostos"]
            ))
            id_item_entrada = cur.fetchone()[0]
            
            cur.execute("""
                INSERT INTO core.movimento_estoque
                (codigo_produto, quantidade, data_movimentacao, id_tipo_movimentacao, id_item_entrada)
                VALUES (%s, %s, %s, %s, %s)
            """, (
                item["codigo_produto"],
                item["quantidade_total"],
                datetime.now(),
                1,
                id_item_entrada)) 
                

        conn.commit()
        print(f"Nota {numero_nota} inserida com sucesso!")

    except Exception as e:
        conn.rollback()
        print(f"Erro ao inserir nota {numero_nota}:", e)

    finally:
        cur.close()


#Dados da conexão com o banco
def main():
    try:
        caminho = ""
        conn = psycopg2.connect(
        database= "estoque_vendas",
        user=user,
        password=senha,
        host=host,
        port=porta
    )
        itens = itens_venda(caminho)
        #caminho da pasta com os arquivos
        inserir_venda(conn, itens)

        conn.close()       
            
    except Exception as e:
        print(f"Erro na execução: {e}") 

if __name__ == "__main__":
    main()
