/*Adicionanando dados de forma automatica*/
CREATE OR REPLACE PROCEDURE dw.carga_completa()
LANGUAGE plpgsql
AS $$
DECLARE
    v_execucao_id INT;

    v_data_ultima_snapshot DATE;
    v_data_max_oltp DATE;
    v_data_atual DATE;

    v_snapshots_gerados INT := 0;
    v_data_inicio_processada DATE;
BEGIN

    -- registrar início
    INSERT INTO dw.log_execucao_etl(status, mensagem)
    VALUES ('INICIADO', 'Carga DW iniciada')
    RETURNING id_execucao INTO v_execucao_id;

    CALL dw.atualizar_dim_produto();

    CALL dw.atualizar_fato_venda();

    SELECT MAX(dc.data_ref)
    INTO v_data_ultima_snapshot
    FROM dw.fato_estoque_snapshot fs
    JOIN dw.dim_calendario dc ON fs.data_id = dc.data_id;

    IF v_data_ultima_snapshot IS NULL THEN
        v_data_ultima_snapshot := DATE '2026-02-27';
    END IF;

    SELECT MAX(DATE(data_movimentacao))
    INTO v_data_max_oltp
    FROM core.movimento_estoque;

    IF v_data_max_oltp IS NULL THEN
        RAISE NOTICE 'Nenhuma movimentação encontrada.';
        RETURN;
    END IF;

    v_data_atual := v_data_ultima_snapshot + 1;
    v_data_inicio_processada := v_data_atual;

    -- loop de snapshots
    WHILE v_data_atual <= v_data_max_oltp LOOP

        RAISE NOTICE 'Gerando snapshot para %', v_data_atual;

        CALL dw.gerar_snapshot_estoque(v_data_atual);

        v_snapshots_gerados := v_snapshots_gerados + 1;

        v_data_atual := v_data_atual + 1;

    END LOOP;

    -- atualizar log com sucesso
    UPDATE dw.log_execucao_etl
    SET
        fim_execucao = CURRENT_TIMESTAMP,
        data_inicio_processada = v_data_inicio_processada,
        data_fim_processada = v_data_max_oltp,
        snapshots_gerados = v_snapshots_gerados,
        status = 'SUCESSO'
    WHERE id_execucao = v_execucao_id;

EXCEPTION
WHEN OTHERS THEN

    UPDATE dw.log_execucao_etl
    SET
        fim_execucao = CURRENT_TIMESTAMP,
        status = 'ERRO',
        mensagem = SQLERRM
    WHERE id_execucao = v_execucao_id;

    RAISE;

END;
$$;
