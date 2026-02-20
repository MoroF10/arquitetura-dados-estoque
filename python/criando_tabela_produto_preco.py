import pandas as pd
from sqlalchemy import create_engine, text

# --- Configurações de conexão ---
usuario = os.getenv("DB_USER")
senha = os.getenv("DB_PASSWORD")
host = os.getenv("DB_HOST")
porta = os.getenv("DB_PORT")
banco = os.getenv("DB_NAME")
schema = "core"

def conectar_banco():
  engine = create_engine(
    f"postgresql+psycopg2://{usuario}:{senha}@{host}:{porta}/{banco}")
  return engine

def ler_trata_csv(caminho):
  df = pd.read_csv(caminho, sep=';')
  df.columns = df.columns.str.strip()
  df.dropna(inplace=True)
  df['data_registro'] = pd.to_datetime(df['data_registro'], format='%d/%m/%Y')
  df['preco_produto'] = df['preco_produto'].str.replace(',', '.', regex=False).astype(float)
  return df

def carregar_dados(engine, df):
  df.to_sql(
    'historico_preco_produto', 
    engine, 
    if_exists='replace',
    schema='core', 
    index=False)
  
def main():
  caminho_csv = ''
  engine = conectar_banco()
  df = ler_trata_csv(caminho_csv)
  carregar_dados(engine, df)

  print("Carga adicionada com sucesso!")

if __name__ == "__main__":
    main()
