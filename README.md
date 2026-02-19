# 📌 Sistema Core OLTP para Gestão de Estoque e Vendas

## 1. Objetivo

O banco de dados Core é um sistema transacional (OLTP) projetado para armazenar, de forma estruturada e normalizada, todas as operações relacionadas a:

- Vendas

- Movimentações de estoque

- Auditorias físicas

- Histórico de custo dos produtos

Ele atua como *Single Source of Truth*, garantindo:

- Integridade referencial

- Rastreabilidade

- Consistência

- Escalabilidade

## 2. Escopo Funcional
### 🔹 Vendas

- Registro diário de vendas

- Detalhamento por item

- Base para análise futura de giro e volume

### 🔹 Entradas de Estoque

- Registro de notas fiscais

- Quantidade recebida por produto

- Data da entrada

- Atualização de custo

### 🔹 Saídas de Estoque

- Perdas

- Ajustes manuais

- Transferências

- Consumo interno

- Outras saídas operacionais

## 3. Auditoria de Estoque

O modelo contempla auditoria física periódica com:

- Registro da contagem física

- Comparação com saldo teórico

- Registro de divergências

- Histórico por produto e data

- Permite rastreabilidade completa de perdas e inconsistências.

## 4. Histórico de Custos

O sistema mantém histórico temporal de custo dos produtos, permitindo:

- Análise de margem

- Avaliação de impacto de custo

- Evolução de preços ao longo do tempo

## 5. Modelagem de Dados

- Terceira Forma Normal (3FN)

- Estratégia Snowflake

- Integridade referencial com constraints

- Estrutura preparada para escalabilidade

## 6. Fora do Escopo

O Core não é orientado a BI.

Não contém:

- Tabelas fato

- Métricas agregadas

- Snapshots analíticos

- Views voltadas para Power BI

## 7. Integração com Camada Analítica

O Core serve como origem para:

- Data Warehouse

- Data Mart

- Modelagem estrela

A separação entre OLTP e OLAP garante:

- Performance

- Clareza arquitetural

- Evolução independente das camadas
