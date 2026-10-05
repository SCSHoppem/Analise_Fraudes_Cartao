--01. QUANTIDADE TOTAL DE REGISTROS

SELECT 
	COUNT(*) AS Total_Registros
FROM dataset_transacoes_cartao;

--02. QUANTIDADE DE CLIENTES DISTINTOS

SELECT 
	COUNT(DISTINCT ID_do_Cliente) AS Total_Clientes_Distintos
FROM dataset_transacoes_cartao;

--03. PERÍODO DOS DADOS

SELECT
	MIN(Data_e_Hora_da_Transação) AS primeira_transação,
	MAX(Data_e_Hora_da_Transação) AS ultima_transação
FROM dataset_transacoes_cartao;

--04. EXISTEM VALORES NULL

SELECT 
	COUNT(*) AS Total_Registros,
	COUNT(*) - COUNT(ID_da_Transação) AS NULL_ID_Transação,
	COUNT(*) - COUNT(Endereço_IP) AS NULL_Endereço_IP,
	COUNT(*) - COUNT(ID_do_Cliente) AS NULL_ID_do_Cliente,
	COUNT(*) - COUNT(Número_da_Conta) AS NULL_Número_da_Conta,
	COUNT(*) - COUNT(Idade) AS NULL_Idade,
	COUNT(*) - COUNT(Endereço_de_Entrega) AS NULL_Endereço_de_Entrega,
	COUNT(*) - COUNT(Data_e_Hora_da_Transação) AS NULL_Data_e_Hora_da_Transação,
	COUNT(*) - COUNT(Valor_da_Transação_R) AS NULL_Valor_da_Transação_R,
	COUNT(*) - COUNT(Categoria_do_Produto) AS NULL_Categoria_do_Produto,
	COUNT(*) - COUNT(Unidades_Compradas) AS NULL_Unidades_Compradas
	FROM dataset_transacoes_cartao

--05. EXISTEM TRANSAÇÕES DUPLICADAS?

SELECT 
	COUNT(ID_da_Transação) AS Total_Transações,
	COUNT(DISTINCT ID_da_Transação) AS Total_Transações_Distintas,
	COUNT(ID_da_Transação) - COUNT(DISTINCT ID_da_Transação) AS Transações_Duplicadas
FROM dataset_transacoes_cartao;

--06. QUAIS SÃO OS VALORES MIN, MAX E MÉDIO DAS COMPRAS?

SELECT 
	MIN(Valor_da_Transação_R) AS Menor_transação,
	MAX(Valor_da_Transação_R) AS Maior_transação,
	AVG(Valor_da_Transação_R) AS Média_transação
FROM dataset_transacoes_cartao;

--07. QUANTAS CATEGORIAS DE PRODUTO EXISTEM

SELECT 
	COUNT(DISTINCT Categoria_do_Produto)
FROM dataset_transacoes_cartao;

--08. QUAIS AS QUANTIDADES DE PRODUTOS MIN, MAX E MÉDIA COMPRADAS?

SELECT 
	MIN(Unidades_Compradas) AS Menor_Unidades_Compradas,
	MAX(Unidades_Compradas) AS Maior_Unidades_Compradas,
	AVG(Unidades_Compradas) AS Média_Unidades_Compradas
FROM dataset_transacoes_cartao;

--09.. QUAIS SÃO AS IDADES MIN E MAX DOS COMPRADORES?

SELECT
	MIN(Idade) AS Menor_Idade,
	MAX(Idade) AS Maior_Idade
FROM dataset_transacoes_cartao;
 
--10. EXISTEM VALORES IMPOSSÍVEIS NO DATASET?

SELECT Idade,
	   Valor_da_Transação_R,
	   Unidades_Compradas
FROM dataset_transacoes_cartao
WHERE Idade <= 0 
OR 
	  Valor_da_Transação_R <= 0
OR
	  Unidades_Compradas <=0;

SELECT ID_do_Cliente,
	   COUNT(DISTINCT Número_da_Conta) AS Contas_Distintas,
	   COUNT(DISTINCT Idade) AS Idades_Distintas
FROM dataset_transacoes_cartao
GROUP BY ID_do_Cliente
HAVING COUNT(DISTINCT Número_da_Conta) > 1
OR
	   COUNT(DISTINCT Idade) > 1;
	   

	  /*Após Profiling realizado, foi evidenciado que o dataset contém 5.469 transações de 120 clientes, distribuídas entre 02/01/2025 e 16/07/2025.
	    Não foram identificados valores nulos nas variáveis avaliadas, IDs de transação duplicados ou valores impossíveis nas verificações realizadas.
	    Não foram identificados clientes associados a mais de um número de conta ou a mais de uma idade.
		Os dados apresentam valores extremos de transação e quantidade comprada que serão preservados para investigação nas etapas posteriores,
	    pois podem representar comportamentos anômalos relevantes ao objetivo do projeto.*/
	


	
