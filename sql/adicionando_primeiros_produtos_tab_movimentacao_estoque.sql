INSERT INTO core.movimento_estoque (
    codigo_produto,
    quantidade,
    data_movimentacao,
    id_tipo_movimentacao,
    id_item_entrada
)
SELECT
    ia.codigo_produto,
    ia.quantidade_contada,
    a.data_auditoria,
    4,
    NULL
FROM core.item_auditoria_estoque ia
JOIN core.auditoria_estoque a
    ON a.id_auditoria = ia.id_auditoria
WHERE ia.id_auditoria = (
    SELECT MAX(id_auditoria)
    FROM core.auditoria_estoque
)
AND ia.quantidade_contada > 0;
