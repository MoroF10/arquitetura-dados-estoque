/*Adicionando as clases de produtos*/
INSERT INTO core.classe_produto
VALUES
  ('Trufas'),
	('Tabletes'),
	('Sorvetes'),
	('Sobremesas'),
	('Merchandising'),
	('Meio Amargo'),
	('Marshmallows'),
	('Lingua De Gato'),
	('Gifts'),
	('Funcional'),
	('Flores'),
	('Esferas'),
	('Embalagens'),
	('Drageados')
	('Consumo')
	('Campanha')
	('Bombons')
	('Biscoitos')
	('Bebidas Alcoolicas')
	('Bebidas')
	('Acessórios')

/*Tipos de produto*/
INSERT INTO core.tipo_produto(tipo_produto)
VALUEs
	('Linha'),
	('Campanha'),
	('Descontinuado')

/*Tipos de forma de pagamento*/
INSERT INTO core.forma_pagamento (descricao)
VALUES
  ('DINHEIRO'),
  ('DEBITO'),
  ('CREDITO'),
  ('PIX'),
  ('OUTRO');

/*Tipos de movimentação que pode acontecer no estoque*/
INSERT INTO core.tipo_movimentacao_estoque (tipo_movimentacao)
VALUES
	('Entrada'),
	('Saída'),
	('Ajuste'),
	('Inicial'),
	('Outros');
