/*Adicionando novos dados na tabela fato_venda*/
CREATE OR REPLACE PROCEDURE dw.atualizar_fato_venda()
LANGUAGE plpgsql
AS $$
DECLARE
    registros_restantes INT;
BEGIN

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
	
	    COALESCE(hp.preco_produto, hp_base.preco_produto) AS custo_unitario,

		iv.quantidade * COALESCE(hp.preco_produto, hp_base.preco_produto) AS custo_total_item,
	
	    (v.valor_imposto / v.valor_total) 
	        * (iv.quantidade * iv.preco_unitario_vendido) AS imposto_item
	
	FROM core.item_venda iv
	
	JOIN core.venda v
	    ON iv.id_venda = v.id_venda
	
	JOIN dw.dim_calendario dc
	    ON dc.data_ref = DATE(v.data_venda)
	
	LEFT JOIN LATERAL (
	    SELECT hp.preco_produto
	    FROM core.historico_preco_produto hp
	    WHERE hp.codigo_produto = iv.codigo_produto
	      AND hp.data_registro <= v.data_venda
	    ORDER BY hp.data_registro DESC
	    LIMIT 1
	) hp ON TRUE
	
	LEFT JOIN LATERAL (
	    SELECT hp.preco_produto
	    FROM core.historico_preco_produto hp
	    WHERE hp.codigo_produto = iv.codigo_produto
	    ORDER BY hp.data_registro ASC
	    LIMIT 1
	) hp_base ON hp.preco_produto IS NULL

	WHERE DATE(v.data_venda) <= CURRENT_DATE - 1
	AND NOT EXISTS (
	    SELECT 1
	    FROM dw.fato_venda fv
	    WHERE fv.id_nota = v.id_venda
	      AND fv.numero_linha = iv.numero_linha
	);
	
	SELECT COUNT(*)
	INTO registros_restantes
	FROM core.item_venda iv
	JOIN core.venda v ON iv.id_venda = v.id_venda
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM dw.fato_venda fv
	    WHERE fv.id_nota = v.id_venda
	      AND fv.numero_linha = iv.numero_linha
	);

RAISE NOTICE 'Registros ainda não carregados: %', registros_restantes;
END;
$$;
