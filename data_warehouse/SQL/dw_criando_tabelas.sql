/*criando as tabela de dimensão produto*/
CREATE TABLE dw.dim_produto (
    codigo_produto INT PRIMARY KEY,
    nome_produto VARCHAR(200) NOT NULL,
    classe VARCHAR(100),
    tipo VARCHAR(100)
);

/*criando as tabela de dimensão forma de pagamento*/
CREATE TABLE dw.dim_forma_pagamento (
    id_forma_pagamento INT PRIMARY KEY,
    nome_forma_pagamento VARCHAR(100) NOT NULL
);

/*criando as tabela de dimensão calendario*/
CREATE TABLE dw.dim_calendario (
    data_id INT PRIMARY KEY,
    data_ref DATE NOT NULL UNIQUE,
    ano INT NOT NULL,
    mes INT NOT NULL,
    dia INT NOT NULL,
    trimestre INT NOT NULL
);

/*criando as tabela de fato venda*/
CREATE TABLE dw.fato_venda (
    id_venda SERIAL PRIMARY KEY,

    id_nota INT NOT NULL,
    numero_linha INT NOT NULL,

    codigo_produto INT NOT NULL,
    id_forma_pagamento INT NOT NULL,
    data_id INT NOT NULL,

    quantidade INT NOT NULL,

    valor_unitario_venda NUMERIC(12,2) NOT NULL,
    valor_total_item NUMERIC(14,2) NOT NULL,

    custo_unitario NUMERIC(12,2) NOT NULL,
    custo_total_item NUMERIC(14,2) NOT NULL,

    imposto_item NUMERIC(14,2),

    CONSTRAINT fk_fv_produto
        FOREIGN KEY (codigo_produto)
        REFERENCES dw.dim_produto (codigo_produto),

    CONSTRAINT fk_fv_forma_pagamento
        FOREIGN KEY (id_forma_pagamento)
        REFERENCES dw.dim_forma_pagamento (id_forma_pagamento),

    CONSTRAINT fk_fv_calendario
        FOREIGN KEY (data_id)
        REFERENCES dw.dim_calendario (data_id),
		
	CONSTRAINT uk_fato_venda UNIQUE (id_nota, numero_linha)
);

SELECT COUNT(*)
FROM core.item_venda iv
JOIN core.venda v ON iv.id_venda = v.id_venda
WHERE NOT EXISTS (
    SELECT 1
    FROM dw.fato_venda fv
    WHERE fv.id_nota = v.id_venda
      AND fv.numero_linha = iv.numero_linha
);


/*criando as tabela de fato estoque*/
CREATE TABLE dw.fato_estoque_snapshot (
    id_estoque SERIAL PRIMARY KEY,

    codigo_produto INT NOT NULL,
    data_id INT NOT NULL,
    quantidade INT NOT NULL,

    CONSTRAINT fk_fe_produto
        FOREIGN KEY (codigo_produto)
        REFERENCES dw.dim_produto (codigo_produto),

    CONSTRAINT fk_fe_calendario
        FOREIGN KEY (data_id)
        REFERENCES dw.dim_calendario (data_id),

    CONSTRAINT uk_produto_data UNIQUE (codigo_produto, data_id)
);

CREATE INDEX idx_fv_data
ON dw.fato_venda (data_id);

CREATE INDEX idx_fv_produto
ON dw.fato_venda (codigo_produto);

CREATE INDEX idx_fv_forma_pagamento
ON dw.fato_venda (id_forma_pagamento);
