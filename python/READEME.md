# Scripts Python 

Esta pasta contém os scripts responsáveis pela ingestão e tratamento de dados utilizados no Banco Core OLTP.

Os processos implementados incluem:

- Leitura de arquivos CSV e XML

- Tratamento e padronização de dados

- Conversão de tipos (datas, valores numéricos)

- Validações básicas

- Inserção de dados no schema core (PostgreSQL)

Os scripts utilizam:

- psycopg2 para inserções transacionais

- SQLAlchemy para cargas estruturadas

- Variáveis de ambiente para configuração segura de conexão

O objetivo desta camada é automatizar a entrada de dados no banco, garantindo consistência e integridade.
