/*Adicionanando dados de forma automatica*/
CREATE OR REPLACE PROCEDURE dw.carga_completa()
LANGUAGE plpgsql
AS $$
DECLARE
    v_data_ultima_snapshot DATE;
    v_data_max_oltp DATE;
    v_data_atual DATE;
BEGIN

    --  Atualizar dimensão
    CALL dw.atualizar_dim_produto();

    -- Atualizar fato venda
    CALL dw.atualizar_fato_venda();

    -- Buscar última data do snapshot
    SELECT MAX(dc.data_ref)
    INTO v_data_ultima_snapshot
    FROM dw.fato_estoque_snapshot fs
    JOIN dw.dim_calendario dc ON fs.data_id = dc.data_id;

    -- Se não existir snapshot ainda, usar data inicial fixa
    IF v_data_ultima_snapshot IS NULL THEN
        v_data_ultima_snapshot := DATE '2026-02-27';
    END IF;

    -- Buscar última data existente no OLTP
    SELECT MAX(DATE(data_movimentacao))
    INTO v_data_max_oltp
    FROM core.movimento_estoque;

    -- Segurança: se não houver movimentação, sair
    IF v_data_max_oltp IS NULL THEN
        RAISE NOTICE 'Nenhuma movimentação encontrada.';
        RETURN;
    END IF;

    -- Começar no próximo dia após o último snapshot
    v_data_atual := v_data_ultima_snapshot + 1;

    -- Loop incremental dia a dia
    WHILE v_data_atual <= v_data_max_oltp LOOP

        RAISE NOTICE 'Gerando snapshot para %', v_data_atual;

        CALL dw.gerar_snapshot_estoque(v_data_atual);

        v_data_atual := v_data_atual + 1;

    END LOOP;

END;
$$;
