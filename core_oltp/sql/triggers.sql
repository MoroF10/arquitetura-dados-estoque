/*Criando trigger que vai automaticamente adicionar o valor do preço do produto no histórico*/
CREATE OR REPLACE FUNCTION core.fn_atualizar_historico_preco()
RETURNS TRIGGER AS
$$
DECLARE
    v_custo_unitario NUMERIC(10,2);
    v_ultimo_preco NUMERIC(10,2);
BEGIN
    
    -- Calcula custo unitário
    v_custo_unitario := NEW.custo_total_item / NEW.quantidade;

    -- Busca último preço registrado do produto
    SELECT preco_produto
    INTO v_ultimo_preco
    FROM core.historico_preco_produto
    WHERE codigo_produto = NEW.codigo_produto
    ORDER BY data_registro DESC
    LIMIT 1;

    -- Se não existe preço anterior OU mudou o valor, insere novo histórico
    IF v_ultimo_preco IS NULL OR v_ultimo_preco <> v_custo_unitario THEN
        
        INSERT INTO core.historico_preco_produto (
            codigo_produto,
            preco_produto,
            data_registro
        )
        VALUES (
            NEW.codigo_produto,
            v_custo_unitario,
            NOW()
        );

    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trg_atualizar_historico_preco
AFTER INSERT ON core.item_entrada
FOR EACH ROW
EXECUTE FUNCTION core.fn_atualizar_historico_preco();


/*Criando trigger que vai automaticamente adicionar o valor do preço do produto no histórico*/
CREATE OR REPLACE FUNCTION core.fn_movimenta_estoque_venda()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_data_venda TIMESTAMP;
BEGIN
    -- Buscar data da venda
    SELECT v.data_venda
    INTO v_data_venda
    FROM core.venda v
    WHERE v.id_venda = NEW.id_venda;

    -- Inserir movimentação de saída
    INSERT INTO core.movimento_estoque (
        codigo_produto,
        quantidade,
        data_movimentacao,
        id_tipo_movimentacao,
        id_item_entrada
    )
    VALUES (
        NEW.codigo_produto,
        NEW.quantidade,
        v_data_venda,
        2, -- 2 = Saída (confirme na sua tabela tipo_movimentacao_estoque)
        NULL
    );

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_movimenta_estoque_venda
AFTER INSERT ON core.item_venda
FOR EACH ROW
EXECUTE FUNCTION core.fn_movimenta_estoque_venda();
