# 📊 Arquitetura de Dados – Sistema Completo de Estoque e Vendas (OLTP + OLAP)
## 1. Visão Geral

Este projeto implementa uma arquitetura completa de dados dividida em duas camadas:

- Core (OLTP) → Sistema transacional normalizado

- Data Warehouse (OLAP) → Camada analítica orientada a BI

A separação segue boas práticas de arquitetura de dados, garantindo:

- Integridade transacional

- Performance analítica

- Escalabilidade

- Evolução independente das camadas

## 🔹 Camada 1 – Core (OLTP)
### 📌 Objetivo

O banco Core é um sistema transacional projetado para armazenar todas as operações operacionais do negócio, funcionando como Single Source of Truth.

Ele registra:

- Vendas

- Movimentações de estoque

- Auditorias físicas

- Histórico de custo

- Entradas via nota fiscal

## 🔎 Escopo Funcional
### 🛒 Vendas

- Registro diário de vendas

- Detalhamento por item

- Trigger automática para movimentação de estoque

### 📦 Entradas de Estoque

- Registro de notas fiscais

- Atualização de custo

- Controle por produto

- Integração via ETL (XML → PostgreSQL)

### 📤 Saídas de Estoque

- Perdas

- Ajustes manuais

- Transferências

- Consumo interno

### 📋 Auditoria de Estoque

- Registro de contagem física

- Comparação com saldo teórico

- Registro de divergências

- Histórico por produto e data

### 💰 Histórico de Custos

- Controle temporal de custo

- Base para cálculo de margem

- Rastreabilidade de variações

### 🏗️ Modelagem do Core

- Terceira Forma Normal (3FN)

- Estratégia Snowflake

- Integridade referencial com constraints

- Triggers para automação de movimentação

- Estrutura preparada para alto volume transacional

## 🔹 Camada 2 – Data Warehouse (OLAP)
### 📌 Objetivo

O Data Warehouse foi construído para análise de dados e suporte à decisão.

Ele consome dados do Core e transforma em modelo analítico otimizado para BI.

### 🧮 Modelagem Analítica

- Modelagem Estrela

- Tabelas Fato:

  - Fato Vendas

  - Fato Snapshot de Estoque

- Dimensões:

  - Dim Produto

  - Dim Calendario

  - Dim Forma Pagamento


### 📊 Recursos Analíticos

- Snapshot diário de estoque

- Base para cálculo de:

  - Giro

  - Cobertura

  - Estoque crítico

  - Produtos sem venda

  - Margem estimada

  - Estrutura preparada para Power BI

## 🔄 Processo de ETL

O projeto implementa processo de carga estruturado:

- Extração do Core

- Transformações (normalização, tratamento, regras de negócio)

- Carga incremental no DW

- Controle de integridade

- Regras para evitar duplicidade

- Filtros temporais (ex: restrições por data mínima)

Ferramentas utilizadas:

- PostgreSQL

- SQL

- Python (processamento de XML de nota fiscal)

## 📐 Arquitetura

Core (OLTP)
⬇ ETL
Data Warehouse (OLAP)
⬇
Power BI

Essa separação garante:

- Performance transacional

- Performance analítica

- Clareza arquitetural

- Manutenção facilitada

- Escalabilidade futura

## 🛠 Tecnologias Utilizadas

- PostgreSQL

- SQL avançado

- Modelagem 3FN

- Modelagem Estrela

- Snowflake

- Python (ETL)

- Power BI

## 🚀 Evolução Futura

- Camada de Data Mart

- Automação de carga incremental

- Implementação de SCD Type 2

- Migração para ambiente cloud (Azure)
