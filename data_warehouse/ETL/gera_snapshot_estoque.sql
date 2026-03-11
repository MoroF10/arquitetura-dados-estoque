/*criando o procedure para inserir dados novos na tabela estoque*/
CREATE OR REPLACE PROCEDURE dw.gerar_snapshot_estoque(p_data DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_data_id_hoje INT;
    v_data_id_ontem INT;
BEGIN

    -- Buscar data_id de hoje
    SELECT data_id
    INTO v_data_id_hoje
    FROM dw.dim_calendario
    WHERE data_ref = p_data;

    -- Buscar data_id de ontem
    SELECT data_id
    INTO v_data_id_ontem
    FROM dw.dim_calendario
    WHERE data_ref = p_data - 1;

    INSERT INTO dw.fato_estoque_snapshot (codigo_produto, data_id, quantidade)

    SELECT
        COALESCE(prev.codigo_produto, mov.codigo_produto) AS codigo_produto,
        v_data_id_hoje,
        COALESCE(prev.quantidade,0) + COALESCE(mov.movimentacao_dia,0) AS saldo_final

    FROM dw.fato_estoque_snapshot prev

    FULL JOIN
    (
        SELECT
            m.codigo_produto,
            SUM(
                CASE
                    WHEN m.id_tipo_movimentacao = 4 THEN m.quantidade
					WHEN m.id_tipo_movimentacao = 1 THEN m.quantidade
                    WHEN m.id_tipo_movimentacao = 2 THEN -m.quantidade
                    ELSE 0
                END
            ) AS movimentacao_dia
        FROM core.movimento_estoque m
        WHERE DATE(m.data_movimentacao) = p_data
        GROUP BY m.codigo_produto
    ) mov
        ON mov.codigo_produto = prev.codigo_produto
		AND prev.data_id = v_data_id_ontem
		
    WHERE prev.data_id = v_data_id_ontem
		OR prev.data_id IS NULL

    ON CONFLICT (codigo_produto, data_id)
    DO UPDATE
    SET quantidade = EXCLUDED.quantidade;

END;
$$;



