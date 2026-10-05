/*Objetivo:
  Identificar potenciais anomalias comportamentais nas transações com cartão de crédito,considerando o histórico individual dos clientes.

  Gatilhos analisados:
  1. Valor da transação acima do padrão do cliente;
  2. Alta frequência de transações em curto intervalo;
  3. Quantidade comprada acima do padrão do cliente;
  4. Mudança no padrão de endereço de entrega;
  5. Mudança no padrão de endereço IP.

  Os gatilhos representam sinais de comportamento atípico e não confirmação de fraude.*/

 --01. VALOR DA TRANSAÇÃO

 SELECT ID_do_Cliente,
	    COUNT(ID_da_Transação) AS QTD_Transações,
		MIN(Valor_da_Transação_R) AS Menor_Valor,
		MAX(Valor_da_Transação_R) AS Maior_Valor,
		AVG(Valor_da_Transação_R) AS Valor_Médio
 FROM transacoes_tratadas
 GROUP BY ID_do_Cliente
 ORDER BY Valor_Médio DESC;

--1° Gatilho, valor.

SELECT T.ID_do_Cliente,
	   T.ID_da_Transação,
	   T.Valor_da_Transação_R,
	   M.Valor_Médio_Cliente,
	   CASE
			WHEN T.Valor_da_Transação_R >= M.Valor_Médio_Cliente * 3
				THEN 'Valor_Atípico'
			ELSE 'Valor_Habitual'
	   END AS Gatilho_Valor
FROM transacoes_tratadas AS T
 INNER JOIN
 ( 
	SELECT ID_do_Cliente,
		   ROUND(AVG(Valor_da_Transação_R),2) AS Valor_Médio_Cliente
	FROM transacoes_tratadas
	GROUP BY ID_do_Cliente
 ) AS M ON T.ID_do_Cliente = M.ID_do_Cliente;

 /*Foram classificadas como potencialmente atípicas as transações cujo valor é igual ou superior a 3 vezes o valor médio das transações do próprio cliente.
   O critério considera o comportamento individual de cada cliente e representa um sinal de anomalia, não uma confirmação de fraude.*/

--02 FREQUÊNCIA DAS TRANSAÇÕES

SELECT ID_do_Cliente,
       ID_da_Transação,
       Data_e_Hora_da_Transação,
       Minutos_Desde_Transação_Anterior,
	   CASE
			WHEN Minutos_Desde_Transação_Anterior <= 5
				THEN 'Frequência_Atípica'
			WHEN Minutos_Desde_Transação_Anterior IS NULL
				THEN 'Sem_Histórico_Anterior'
			ELSE 'Frequência_Habitual'
	   END AS Gatilho_Frequência
FROM
(
	SELECT ID_do_Cliente,
		   ID_da_Transação,
		   Data_e_Hora_da_Transação,
		   DATEDIFF(
				MINUTE,
				LAG(Data_e_Hora_da_Transação) OVER (
					PARTITION BY ID_do_Cliente
					ORDER BY Data_e_Hora_da_Transação
				),
				Data_e_Hora_da_Transação
				) AS Minutos_Desde_Transação_Anterior
	FROM transacoes_tratadas
) AS F;

/*Foram classificadas como potencialmente atípicas as transações realizadas em intervalo de até 5 minutos em relação à transação anterior do mesmo cliente.
  A primeira transação de cada cliente foi classificada como 'Sem_Histórico_Anterior', pois não existe transação anterior para comparação.
  O critério representa um sinal de comportamento atípico e não confirmação de fraude.*/

--03 QUANTIDADES COMPRADAS

SELECT ID_do_Cliente,
	   COUNT(ID_da_Transação) AS QTD_Transações,
       MIN(Unidades_Compradas) AS Menor_Unidade,
	   MAX(Unidades_Compradas) AS Maior_Unidade,
	   AVG(Unidades_Compradas) AS Média_Unidades
FROM transacoes_tratadas
GROUP BY ID_do_Cliente
ORDER BY Média_Unidades;

--3° Gatilho, quantidades.

SELECT T.ID_do_Cliente,
	   T.ID_da_Transação,
       T.Unidades_Compradas,
       M.Média_Unidades_Cliente,
	   CASE
			WHEN T.Unidades_Compradas >= 3* M.Média_Unidades_Cliente
				THEN 'Quantidade_Atípica'
			ELSE 'Quantidade_Habitual'
	   END AS Gatilho_Quantidade
FROM transacoes_tratadas AS T
INNER JOIN
(
	SELECT ID_do_Cliente,
		   AVG(CAST(Unidades_Compradas AS DECIMAL (10,2))) AS Média_Unidades_Cliente
    FROM transacoes_tratadas
	GROUP BY ID_do_Cliente
) AS M ON T.ID_do_Cliente = M.ID_do_Cliente;

/*Foram classificadas como potencialmente atípicas as transações cuja unidade é igual ou superior a 3 vezes o valor médio das transações do próprio cliente.
  O critério considera o comportamento individual de cada cliente e representa um sinal de anomalia, não uma confirmação de fraude.*/

--04.ENDEREÇO DE ENTREGA

--QUANTIDADE DE ENDEREÇOS DISTINTOS POR CLIENTE

SELECT ID_do_Cliente,
	   COUNT(DISTINCT Endereço_de_Entrega) AS Endereços_Distintos
FROM transacoes_tratadas
GROUP BY ID_do_Cliente
ORDER BY Endereços_Distintos DESC

--FREQUÊNCIA DE UTILIZAÇÃO DE CADA ENDEREÇO POR CLIENTE

SELECT ID_do_Cliente,
	   Endereço_de_Entrega,
	   COUNT(ID_da_Transação) AS Quantidade_Uso_Endereço
FROM transacoes_tratadas
GROUP BY ID_do_Cliente,
	     Endereço_de_Entrega
ORDER BY ID_do_Cliente,
	     Quantidade_Uso_Endereço DESC

--FREQUÊNCIA DO ENDEREÇO ASSOCIADA A CADA TRANSAÇÃO

SELECT T.ID_do_Cliente,
	   T.ID_da_Transação,
	   T.Endereço_de_Entrega,
	   E.Quantidade_Uso_Endereço
FROM transacoes_tratadas AS T
INNER JOIN
(	SELECT ID_do_Cliente,
	   Endereço_de_Entrega,
	   COUNT(ID_da_Transação) AS Quantidade_Uso_Endereço
FROM transacoes_tratadas
GROUP BY ID_do_Cliente,
	     Endereço_de_Entrega
) AS E ON T.ID_do_Cliente = E.ID_do_Cliente
	   AND T.Endereço_de_Entrega = E.Endereço_de_Entrega;

--DISTRIBUIÇÃO DA FREQUÊNCIA DE USO POR PAR CLIENTE/ENDEREÇO ENTREGA

WITH uso_endereco AS (
    SELECT
        ID_do_Cliente,
        Endereço_de_Entrega,
        COUNT(*) AS Quantidade_Uso_Endereço
    FROM transacoes_tratadas
    GROUP BY ID_do_Cliente, Endereço_de_Entrega
)
SELECT
    Quantidade_Uso_Endereço,
    COUNT(*) AS Quantidade_Clientes_Endereços
FROM uso_endereco
GROUP BY Quantidade_Uso_Endereço
ORDER BY Quantidade_Uso_Endereço;

--CONTAGEM DE USOS DE ENDEREÇO PELO MESMO CLIENTE, APÓS DEFINIÇÃO DE ATÉ 3 USOS DE ENDEREÇO COMO QUALIFICÁVEL PARA INVESTIGAÇÃO

WITH uso_endereco AS (
    SELECT
        ID_do_Cliente,
        Endereço_de_Entrega,
        COUNT(*) AS Quantidade_Uso_Endereço
    FROM transacoes_tratadas
    GROUP BY ID_do_Cliente, Endereço_de_Entrega
	)
SELECT COUNT(*) AS Total_Transacoes
FROM transacoes_tratadas AS T
INNER JOIN uso_endereco AS E
    ON T.ID_do_Cliente = E.ID_do_Cliente
   AND T.Endereço_de_Entrega = E.Endereço_de_Entrega
WHERE E.Quantidade_Uso_Endereço <= 3;

--165 TRANSAÇÕES ATENDERAM AO CRITÉRIO DE POUCO FREQUENTE.

SELECT 165.0  * 100 / COUNT(*) AS Percentual_Endereço_Pouco_Frequente
FROM transacoes_tratadas;

/*Dos 5.469 registros analisados, 165 (3,02%) envolveram endereços usados até três vezes pelo mesmo cliente.
Esse critério indica transações para investigação, sem confirmar fraude.*/

--TRANSAÇÕES QUE POSSUEM O GATILHO.

WITH uso_endereco AS (
    SELECT
        ID_do_Cliente,
        Endereço_de_Entrega,
        COUNT(*) AS Quantidade_Uso_Endereço
    FROM transacoes_tratadas
    GROUP BY ID_do_Cliente, Endereço_de_Entrega
	)
SELECT T.ID_da_Transação,
	   T.ID_do_Cliente,
	   T.Endereço_de_Entrega,
	   E.Quantidade_Uso_Endereço,
	   CASE
			WHEN E.Quantidade_Uso_Endereço <= 3
				THEN 1
			ELSE 0
		END AS Gatilho_4_Endereço
FROM transacoes_tratadas AS T
INNER JOIN uso_endereco AS E
    ON T.ID_do_Cliente = E.ID_do_Cliente
    AND T.Endereço_de_Entrega = E.Endereço_de_Entrega;


--APLICAÇÃO DO 4° GATILHO 

WITH uso_endereco AS (
    SELECT
        ID_do_Cliente,
        Endereço_de_Entrega,
        COUNT(*) AS Quantidade_Uso_Endereço
    FROM transacoes_tratadas
    GROUP BY ID_do_Cliente, Endereço_de_Entrega
	),
	 transacoes_com_gatilho_4 AS (
		SELECT T.ID_da_Transação,
			   T.ID_do_Cliente,
			   T.Endereço_de_Entrega,
			   E.Quantidade_Uso_Endereço,
			   CASE
					WHEN E.Quantidade_Uso_Endereço <= 3
						THEN 1
					ELSE 0
				END AS Gatilho_4_Endereço_Entrega
		FROM transacoes_tratadas AS T
		INNER JOIN uso_endereco AS E
			ON T.ID_do_Cliente = E.ID_do_Cliente
			AND T.Endereço_de_Entrega = E.Endereço_de_Entrega
			)
			SELECT ID_da_Transação,
			       ID_do_Cliente,
			       Endereço_de_Entrega,
				   Quantidade_Uso_Endereço,
				   Gatilho_4_Endereço_Entrega
			FROM transacoes_com_gatilho_4
			WHERE Gatilho_4_Endereço_Entrega = 1
			ORDER BY ID_do_Cliente, ID_da_Transação;

/*Das 5.469 transações, foram evidenciados endereços de entrega usados até 3 vezes pelo mesmo cliente → indicador 1 para 165 transações sinalizadas,
  representando 3,02% do total.*/

--05. MUDANÇA NO PADRÃO DE ENDEREÇO DE IP

--IDENTIFICAÇÃO DAS QUANTIDADES DE TRANSAÇÕES POR IP DE CADA CLIENTE

SELECT ID_do_Cliente,
	   Endereço_IP,
	   COUNT(*) AS Transações_por_IP	
FROM transacoes_tratadas
GROUP BY ID_do_Cliente,
	     Endereço_IP
ORDER BY ID_do_Cliente,COUNT(*) DESC

--DISTRIBUIÇÃO DA FREQUÊNCIA DE USO POR PAR CLIENTE/ENDEREÇO IP

WITH Uso_IP AS (
	SELECT ID_do_Cliente,
		   Endereço_IP,
		   COUNT(*) AS Transações_por_IP	
	FROM transacoes_tratadas
	GROUP BY ID_do_Cliente,
			 Endereço_IP
	)
SELECT
    Transações_por_IP,
    COUNT(*) AS Quantidade_Clientes_IP
FROM Uso_IP
GROUP BY Transações_por_IP
ORDER BY Transações_por_IP;

--OBSERVADO QUE 218 PARES DE CLIENTE/ENDEREÇO IP OCORRERAM APENAS 1 VEZ E APÓS SÓ HÁ REGISTROS APARTIR DE 9 TRANSAÇÕES,
  
SELECT 218.0  * 100 / COUNT(*) AS Percentual_IP_Incomum
FROM transacoes_tratadas;

/*Das 5.469 transações, foram evidenciados endereços IP usados somente 1 vez pelo mesmo cliente → indicador 1 para 218 transações sinalizadas,
  representando 3,99% do total.*/

--APLICAÇÃO DO 5° GATILHO 

WITH Uso_IP AS (
	SELECT ID_do_Cliente,
		   Endereço_IP,
		   COUNT(*) AS Transações_por_IP	
	FROM transacoes_tratadas
	GROUP BY ID_do_Cliente,
			 Endereço_IP
	),
	 transacoes_com_gatilho_5 AS (
		SELECT T.ID_da_Transação,
			   T.ID_do_Cliente,
			   T.Endereço_IP,
			   E_IP.Transações_por_IP,
			   CASE
					WHEN Transações_por_IP = 1
						THEN 1
					ELSE 0
			   END AS Gatilho_5_Endereço_IP
		FROM transacoes_tratadas AS T
		INNER JOIN Uso_IP AS E_IP
			ON T.ID_do_Cliente = E_IP.ID_do_Cliente
			AND T.Endereço_IP = E_IP.Endereço_IP
			)
			SELECT ID_da_Transação,
			       ID_do_Cliente,
			       Endereço_IP,
				   Transações_por_IP,
				   Gatilho_5_Endereço_IP
			FROM transacoes_com_gatilho_5
			WHERE Gatilho_5_Endereço_IP = 1
			ORDER BY ID_do_Cliente, ID_da_Transação;