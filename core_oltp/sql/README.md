## 🧮 Estrutura SQL

Os scripts SQL responsáveis pela criação e manutenção do Core OLTP estão organizados na pasta:

/sql/

A modelagem segue:

- Terceira Forma Normal (3FN)
- Estratégia Snowflake
- Separação entre estrutura (DDL) e consultas (DML)

Essa organização garante:

- Integridade referencial
- Redução de redundância
- Clareza arquitetural
