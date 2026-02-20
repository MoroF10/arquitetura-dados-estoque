#Importando aS bibliotecas usadas 
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
  return df

def carrega_dados(df, engine):
  df.to_sql(
    'produto', 
    engine, 
    if_exists='append',
    schema='core', 
    index=False)

def main():
  caminho = 'docs/csv/produtos.csv'

  engine = conectar_banco()
  df = ler_trata_csv(caminho)
  carrega_dados(df, engine)

  print("Carga adicionada com sucesso!")


if __name__ == "__main__":
    main()



caminho = (r'C:\Users\ferna\Cacaushow\Csv\Banco Novo\Produtos_core.csv')
