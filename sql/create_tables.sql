/*Criando Tabela de identificação classes produtos*/
CREATE TABLE core.classe_produto (
	id_classe SERIAL PRIMARY KEY,
	classe_produto VARCHAR(30),
	ativo BOOLEAN NOT NULL DEFAULT TRUE
);

/*Criando Tabela de tipos Produto(campanha, linha, descontinuado)*/
CREATE TABLE core.tipo_produto (
	id_tipo_produto SERIAL PRIMARY KEY,
	tipo_produto VARCHAR(30) NOT NULL UNIQUE,
	produto_controla_estoque BOOLEAN NOT NULL DEFAULT TRUE
);
