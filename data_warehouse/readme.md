
# 📊 Data Warehouse – Camada Analítica
## 1. Objetivo

O Data Warehouse foi desenvolvido para suportar análise de dados e tomada de decisão a partir das informações transacionais do sistema Core (OLTP).

A camada analítica é separada da camada transacional, garantindo:

- Performance para consultas analíticas

- Organização orientada a métricas

- Baixo acoplamento com o sistema operacional

- Escalabilidade

## 2. Arquitetura

Core (OLTP – 3FN)
⬇ ETL
Data Warehouse (Modelo Estrela)
⬇
Power BI

O DW consome exclusivamente dados do Core, respeitando a separação entre OLTP e OLAP.

## 3. Modelagem Dimensional

A modelagem segue o padrão Star Schema, com tabelas fato centralizadas e dimensões desnormalizadas para otimizar consultas analíticas.

### 🔹 Tabelas Fato

- fato_venda

  - Métricas de quantidade vendida

  - Valor unitário

  - Valor total

  - Relacionamento com produto, data e forma de pagamento

- fato_estoque_snapshot

  - Snapshot diário do estoque

  - Base para cálculo de cobertura e giro

  - Permite análise temporal do saldo

### 🔹 Tabelas Dimensão

- dim_produto

- dim_calendario

- dim_tipo_movimentacao

- dim_forma_pagamento

Dimensões estruturadas para:

- Filtros analíticos

- Segmentação

- Drill-down em dashboards

## 4. Estratégia de Carga (ETL)

O processo de carga implementa:

- Extração do Core

- Transformações de regra de negócio

- Inserção incremental nas tabelas fato

- Controle para evitar duplicidade

- Filtros temporais (ex: restrição por data mínima)

A carga foi projetada para:

- Manter consistência histórica

- Preservar integridade referencial

- Permitir evolução futura para SCD Type 2

## 5. Métricas Suportadas

O modelo permite cálculo de:

- Giro de estoque

- Cobertura de estoque

- Produtos sem venda

- Estoque crítico

- Volume vendido por período

- Análise temporal de movimentações

- Base para cálculo de margem

## 6. Boas Práticas Aplicadas

- Separação clara entre OLTP e OLAP

- Modelagem estrela

- Chaves substitutas (surrogate keys quando aplicável)

- Integridade referencial

- Estrutura preparada para escalabilidade

- Organização por schemas (dw)

## 7. Integração com Power BI

O Data Warehouse foi projetado para consumo direto no Power BI, permitindo:

- Criação de dashboards analíticos

- Uso eficiente de DAX

- Performance otimizada devido ao modelo dimensional

## 8. Evoluções Futuras

- Implementação de Slowly Changing Dimensions (SCD)

- Automação completa da carga incremental

- Orquestração de ETL

- Migração para ambiente em nuvem (ex: Azure)


Pipeline completo

Boas práticas de BI

Isso posiciona seu projeto acima do nível básico.
