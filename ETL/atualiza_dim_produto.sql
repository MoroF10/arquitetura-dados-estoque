/*Procurando dados novos na tabela dim_produto*/
CREATE OR REPLACE PROCEDURE dw.atualizar_dim_produto()
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO dw.dim_produto (codigo_produto, nome_produto, classe, tipo)
    SELECT
        p.codigo_produto,
        p.nome_produto,
        c.nome_classe,
        t.nome_tipo
    FROM core.produto p
    JOIN core.classe_produto c ON p.id_classe = c.id_classe
    JOIN core.tipo_produto t ON p.id_tipo_produto = t.id_tipo_produto
    WHERE NOT EXISTS (
        SELECT 1
        FROM dw.dim_produto d
        WHERE d.codigo_produto = p.codigo_produto
    );

END;
$$;
