### Automatização ETL Pipeline

O Data Warehouse é atualizado por meio de um processo ETL automatizado.

Fluxo:

1. Atualização da dimensão de produtos
2. Carga incremental da tabela fato de vendas
3. Geração de snapshot diário de estoque
4. Execução automática via script Python

O processo detecta automaticamente dias pendentes e executa a geração de snapshots de forma incremental.


