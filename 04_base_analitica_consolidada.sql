-- 01 CONSOLIDAÇÃO DOS GATILHOS

CREATE VIEW base_fraudes_consolidada AS													-- Criação da visualização final que ficará salva no banco.

WITH Base_Frequencia AS (																
		 SELECT *,
			   DATEDIFF(
					MINUTE,
					LAG(Data_e_Hora_da_Transação) OVER (
						PARTITION BY ID_do_Cliente
						ORDER BY Data_e_Hora_da_Transação
					),
					Data_e_Hora_da_Transação
				) AS Minutos_Desde_Transação_Anterior
		 FROM transacoes_tratadas
),
		 Medias_Cliente AS (
			 SELECT ID_do_Cliente,
					AVG(Unidades_Compradas) AS Média_Quantidades,
					AVG(Valor_da_Transação_R) AS Média_Valor
			 FROM transacoes_tratadas
			 GROUP BY ID_do_Cliente
			 ),
		Uso_Endereco AS (
    		SELECT ID_do_Cliente,
				   Endereço_de_Entrega,
				   COUNT(*) AS Quantidade_Uso_Endereço
			FROM transacoes_tratadas
			GROUP BY ID_do_Cliente, Endereço_de_Entrega
			),
		 
		Uso_IP AS (
   			SELECT ID_do_Cliente,
				   Endereço_IP,
				   COUNT(*) AS Transações_por_IP	
			FROM transacoes_tratadas
			GROUP BY ID_do_Cliente,
					 Endereço_IP
			)

-- CONSULTA PRINCIPAL

SELECT T.ID_da_Transação,
       T.ID_do_Cliente,
	   T.Idade,
	   T.Data_e_Hora_da_Transação,
	   T.Valor_da_Transação_R,
	   CASE 
		    WHEN T.Valor_da_Transação_R >= Média_Valor * 3 -- GATILHO 1: Valor
				THEN 1 
			ELSE 0 
	   END AS Gatilho_1_Valor,
	   CASE
			WHEN T.Minutos_Desde_Transação_Anterior <= 5 -- GATILHO 2: Frequência
				THEN 1
			ELSE 0
	   END AS Gatilho_2_Frequencia,
	   CASE
			WHEN T.Unidades_Compradas >= 3* Média_Quantidades -- GATILHO 3: Quantidade
				THEN 1
			ELSE 0
	   END AS Gatilho_3_Quantidades,
	   CASE
			WHEN E.Quantidade_Uso_Endereço <= 3 -- GATILHO 4: Endereço
				THEN 1
			ELSE 0
	   END AS Gatilho_4_Endereço,
	   CASE
			WHEN Transações_por_IP = 1 -- GATILHO 5: IP
				THEN 1
			ELSE 0
	   END AS Gatilho_5_IP
FROM Base_Frequencia AS T
LEFT JOIN Medias_Cliente AS M 
    ON T.ID_do_Cliente = M.ID_do_Cliente
LEFT JOIN Uso_Endereco AS E 
    ON T.ID_do_Cliente = E.ID_do_Cliente AND T.Endereço_de_Entrega = E.Endereço_de_Entrega
LEFT JOIN Uso_IP AS I 
    ON T.ID_do_Cliente = I.ID_do_Cliente AND T.Endereço_IP = I.Endereço_IP;