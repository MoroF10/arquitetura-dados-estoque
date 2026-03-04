/*inserindo dados na tabela dim_calendario*/
INSERT INTO dw.dim_calendario (
    data_id,
    data_ref,
    ano,
    mes,
    dia,
    trimestre
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT AS data_id,
    d AS data_ref,
    EXTRACT(YEAR FROM d)::INT,
    EXTRACT(MONTH FROM d)::INT,
    EXTRACT(DAY FROM d)::INT,
    EXTRACT(QUARTER FROM d)::INT
FROM generate_series(
    '2024-11-01'::DATE,
    '2030-12-31'::DATE,
    INTERVAL '1 day'
) AS d;

/*inserindo dados na tabela dim_produto*/
INSERT INTO dw.dim_produto (
    codigo_produto,
    nome_produto,
    classe,
    tipo
)
SELECT
    p.codigo_produto,
    p.nome_produto,
    c.classe_produto,
    t.tipo_produto
FROM core.produto p
JOIN core.classe_produto c 
    ON p.id_classe = c.id_classe
JOIN core.tipo_produto t 
    ON p.id_tipo_produto = t.id_tipo_produto;

/*inserindo dados na tabela forma_pagamento*/
INSERT INTO dw.dim_forma_pagamento
VALUES
(1,'DINHEIRO'),
(2,'DEBITO'),
(3,'CREDITO'),
(4,'PIX'),
(0,'OUTRO');


/*inserindo dados na tabela fato_venda*/
INSERT INTO dw.fato_venda (
    id_nota,
    numero_linha,
    codigo_produto,
    id_forma_pagamento,
    data_id,
    quantidade,
    valor_unitario_venda,
    valor_total_item,
    custo_unitario,
    custo_total_item,
    imposto_item
)
SELECT
    v.id_venda AS id_nota,
    iv.numero_linha,

    iv.codigo_produto,

    1 AS id_forma_pagamento,

    dc.data_id,

    iv.quantidade,

    iv.preco_unitario_vendido AS valor_unitario_venda,
    iv.quantidade * iv.preco_unitario_vendido AS valor_total_item,

    hp.preco_produto AS custo_unitario,
    iv.quantidade * hp.preco_produto AS custo_total_item,

    (v.valor_imposto / v.valor_total) 
        * (iv.quantidade * iv.preco_unitario_vendido) AS imposto_item

FROM core.item_venda iv

JOIN core.venda v
    ON iv.id_venda = v.id_venda

JOIN dw.dim_calendario dc
    ON dc.data_ref = DATE(v.data_venda)

LEFT JOIN LATERAL (
    SELECT h.preco_produto
    FROM core.historico_preco_produto h
    WHERE h.codigo_produto = iv.codigo_produto
      AND h.data_registro <= v.data_venda
    ORDER BY h.data_registro DESC
    LIMIT 1
) hp ON TRUE

LEFT JOIN LATERAL (
    SELECT h.preco_produto
    FROM core.historico_preco_produto h
    WHERE h.codigo_produto = iv.codigo_produto
    ORDER BY h.data_registro ASC
    LIMIT 1
) hp_base ON hp.preco_produto IS NULL

WHERE NOT EXISTS (
    SELECT 1
    FROM dw.fato_venda fv
    WHERE fv.id_nota = v.id_venda
      AND fv.numero_linha = iv.numero_linha
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

/*inserindo dados iniciais na tabela estoque_snapshot*/
INSERT INTO dw.fato_estoque_snapshot (codigo_produto, data_id, quantidade)

SELECT
    m.codigo_produto,
    d.data_id,
    SUM(
        CASE
            WHEN m.id_tipo_movimentacao = 4 THEN m.quantidade
            WHEN m.id_tipo_movimentacao = 2 THEN -m.quantidade
            ELSE 0
        END
    ) AS saldo_inicial

FROM core.movimento_estoque m
JOIN dw.dim_calendario d
    ON d.data_ref = DATE(m.data_movimentacao)

WHERE DATE(m.data_movimentacao) = '2026-02-27'

GROUP BY m.codigo_produto, d.data_id;
