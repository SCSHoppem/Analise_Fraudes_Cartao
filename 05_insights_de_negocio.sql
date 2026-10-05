/*Abaixo serão respondidas as 5 perguntas de negócios sinalizadas para essa consulta, sendo elas:

1. Existem períodos do dia com maior incidência de transações potencialmente suspeitas?

2. Quais comportamentos anômalos apresentam maior incidência entre as transações sinalizadas?

3. Existem faixas etárias com maior incidência proporcional de transações suspeitas?

4. Quais estados apresentam maior incidência de transações potencialmente suspeitas?

5. Quais categorias de produtos apresentam maior incidência de transações suspeitas?
*/


--1. Existem períodos do dia com maior incidência de transações potencialmente suspeitas?

SELECT DATEPART(HOUR, Data_e_Hora_da_Transação) AS Hora_do_Dia,
       COUNT(*) AS Quantidade_Transacoes_Suspeitas
FROM base_fraudes_consolidada
WHERE (Gatilho_1_Valor + Gatilho_2_Frequencia + Gatilho_3_Quantidades + Gatilho_4_Endereço + Gatilho_5_IP) > 0
GROUP BY DATEPART(HOUR, Data_e_Hora_da_Transação)
ORDER BY Quantidade_Transacoes_Suspeitas DESC;

/*Analisando os resultados, podemos observar o seguinte comportamento:
  O pico de transações suspeitas ocorre às 8 horas da manhã, com 47 ocorrências.
  O segundo maior pico acontece ao final do dia, às 18 horas, com 44 ocorrências.
  O período da noite também se destaca, às 23 horas (41 ocorrências), às 20 horas (39 ocorrências) e à meia-noite (0h) (39 ocorrências).
  Estes dados indicam que as anomalias não estão concentradas em um único período, mas apresentam picos em horários de "transição":
  Logo no início da manhã, antes do horário de trabalho comercial, no final da tarde, após o expediente, e tarde da noite.
  Isso apresenta um padrão comum em fraudes, onde golpes são realizados fora do horário comercial para tentar evitar a detecção imediata pelas vítimas ou equipes de prevenção.
*/


--2. Quais comportamentos anômalos apresentam maior incidência entre as transações sinalizadas?

SELECT SUM(Gatilho_1_Valor) AS Total_Anomalia_Valor,
       SUM(Gatilho_2_Frequencia) AS Total_Anomalia_Frequencia,
       SUM(Gatilho_3_Quantidades) AS Total_Anomalia_Quantidades,
       SUM(Gatilho_4_Endereço) AS Total_Anomalia_Endereco,
       SUM(Gatilho_5_IP) AS Total_Anomalia_IP
FROM base_fraudes_consolidada;

/* Quantidades Atípicas (Gatilho 3): 410 transações. É de longe a anomalia mais comum na base.
   Valor Atípico (Gatilho 1): 219 transações.
   IP Incomum (Gatilho 5): 218 transações (praticamente um empate técnico com o valor).
   Endereço Pouco Frequente (Gatilho 4): 165 transações.
   Frequência Atípica / Curto Intervalo (Gatilho 2): Apenas 14 transações, sendo o comportamento mais raro.

Podemos observar que os fraudadores, ou clientes com comportamento atípico, tendem a focar mais em comprar grandes volumes de unidades do que necessariamente fazer várias compras seguidas no mesmo cartão.
*/


--3. Existem faixas etárias com maior incidência proporcional de transações suspeitas?


SELECT 
       CASE
            WHEN Idade BETWEEN 18 AND 25 THEN '1 - 18 a 25 anos'
            WHEN Idade BETWEEN 26 AND 35 THEN '2 - 26 a 35 anos'
            WHEN Idade BETWEEN 36 AND 45 THEN '3 - 36 a 45 anos'
            WHEN Idade BETWEEN 46 AND 55 THEN '4 - 46 a 55 anos'
            WHEN Idade > 55 THEN '5 - Acima de 55 anos'
            ELSE 'Idade desconhecida'
        END AS Faixa_Etaria,
       COUNT(*) AS Quantidade_Transacoes_Suspeitas
FROM base_fraudes_consolidada
WHERE (Gatilho_1_Valor + Gatilho_2_Frequencia + Gatilho_3_Quantidades + Gatilho_4_Endereço + Gatilho_5_IP) > 0
GROUP BY 
        CASE
            WHEN Idade BETWEEN 18 AND 25 THEN '1 - 18 a 25 anos'
            WHEN Idade BETWEEN 26 AND 35 THEN '2 - 26 a 35 anos'
            WHEN Idade BETWEEN 36 AND 45 THEN '3 - 36 a 45 anos'
            WHEN Idade BETWEEN 46 AND 55 THEN '4 - 46 a 55 anos'
            WHEN Idade > 55 THEN '5 - Acima de 55 anos'
            ELSE 'Idade desconhecida'
        END
ORDER BY Faixa_Etaria;

/*Observa-se que existem grandes quantidades de transações suspeitas em todas as faixas etárias, porém cerca de 1/3 das transações suspeitas, ocorrem com público acima de 55 anos*/


--4. Quais estados apresentam maior incidência de transações potencialmente suspeitas?

SELECT 
       CASE
            WHEN Endereço_de_Entrega LIKE '%/RS%' THEN 'RS'
            WHEN Endereço_de_Entrega LIKE '%/SC%' THEN 'SC'
            WHEN Endereço_de_Entrega LIKE '%/PR%' THEN 'PR'
            WHEN Endereço_de_Entrega LIKE '%/SP%' THEN 'SP'
            WHEN Endereço_de_Entrega LIKE '%/RJ%' THEN 'RJ'
            WHEN Endereço_de_Entrega LIKE '%/MG%' THEN 'MG'
            WHEN Endereço_de_Entrega LIKE '%/ES%' THEN 'ES'
            WHEN Endereço_de_Entrega LIKE '%/MS%' THEN 'MS'
            WHEN Endereço_de_Entrega LIKE '%/MT%' THEN 'MT'
            WHEN Endereço_de_Entrega LIKE '%/GO%' THEN 'GO'
            WHEN Endereço_de_Entrega LIKE '%/DF%' THEN 'DF'
            WHEN Endereço_de_Entrega LIKE '%/SE%' THEN 'SE'
            WHEN Endereço_de_Entrega LIKE '%/RN%' THEN 'RN'
            WHEN Endereço_de_Entrega LIKE '%/PI%' THEN 'PI'
            WHEN Endereço_de_Entrega LIKE '%/PE%' THEN 'PB'
            WHEN Endereço_de_Entrega LIKE '%/MA%' THEN 'MA'
            WHEN Endereço_de_Entrega LIKE '%/CE%' THEN 'CE'
            WHEN Endereço_de_Entrega LIKE '%/BA%' THEN 'BA'
            WHEN Endereço_de_Entrega LIKE '%/AL%' THEN 'AL'
            WHEN Endereço_de_Entrega LIKE '%/TO%' THEN 'TO'
            WHEN Endereço_de_Entrega LIKE '%/RR%' THEN 'RR'
            WHEN Endereço_de_Entrega LIKE '%/RO%' THEN 'RO'
            WHEN Endereço_de_Entrega LIKE '%/PA%' THEN 'PA'
            WHEN Endereço_de_Entrega LIKE '%/AM%' THEN 'AM'
            WHEN Endereço_de_Entrega LIKE '%/AP%' THEN 'AP'
            WHEN Endereço_de_Entrega LIKE '%/AC%' THEN 'AC'
            ELSE 'Estado desconhecido'
       END AS Estados,
       COUNT(*) AS Quantidade_Transacoes_Suspeitas
FROM base_fraudes_consolidada AS Consolidada
INNER JOIN Transacoes_tratadas AS Tratada
ON Tratada.ID_da_Transação = Consolidada.ID_da_Transação
WHERE (Gatilho_1_Valor + Gatilho_2_Frequencia + Gatilho_3_Quantidades + Gatilho_4_Endereço + Gatilho_5_IP) > 0
GROUP BY 
        CASE
            WHEN Endereço_de_Entrega LIKE '%/RS%' THEN 'RS'
            WHEN Endereço_de_Entrega LIKE '%/SC%' THEN 'SC'
            WHEN Endereço_de_Entrega LIKE '%/PR%' THEN 'PR'
            WHEN Endereço_de_Entrega LIKE '%/SP%' THEN 'SP'
            WHEN Endereço_de_Entrega LIKE '%/RJ%' THEN 'RJ'
            WHEN Endereço_de_Entrega LIKE '%/MG%' THEN 'MG'
            WHEN Endereço_de_Entrega LIKE '%/ES%' THEN 'ES'
            WHEN Endereço_de_Entrega LIKE '%/MS%' THEN 'MS'
            WHEN Endereço_de_Entrega LIKE '%/MT%' THEN 'MT'
            WHEN Endereço_de_Entrega LIKE '%/GO%' THEN 'GO'
            WHEN Endereço_de_Entrega LIKE '%/DF%' THEN 'DF'
            WHEN Endereço_de_Entrega LIKE '%/SE%' THEN 'SE'
            WHEN Endereço_de_Entrega LIKE '%/RN%' THEN 'RN'
            WHEN Endereço_de_Entrega LIKE '%/PI%' THEN 'PI'
            WHEN Endereço_de_Entrega LIKE '%/PE%' THEN 'PB'
            WHEN Endereço_de_Entrega LIKE '%/MA%' THEN 'MA'
            WHEN Endereço_de_Entrega LIKE '%/CE%' THEN 'CE'
            WHEN Endereço_de_Entrega LIKE '%/BA%' THEN 'BA'
            WHEN Endereço_de_Entrega LIKE '%/AL%' THEN 'AL'
            WHEN Endereço_de_Entrega LIKE '%/TO%' THEN 'TO'
            WHEN Endereço_de_Entrega LIKE '%/RR%' THEN 'RR'
            WHEN Endereço_de_Entrega LIKE '%/RO%' THEN 'RO'
            WHEN Endereço_de_Entrega LIKE '%/PA%' THEN 'PA'
            WHEN Endereço_de_Entrega LIKE '%/AM%' THEN 'AM'
            WHEN Endereço_de_Entrega LIKE '%/AP%' THEN 'AP'
            WHEN Endereço_de_Entrega LIKE '%/AC%' THEN 'AC'
            ELSE 'Estado desconhecido'
       END
ORDER BY Estados

/* Podemos observar que as transações suspeitas ocorrem em 6 diferentes estados,
   mas com grande concentração no estado do Rio Grande do Sul, representando quase 30% do volume total,
   além de 165 transações definidas com estado desconhecido, sendo caixa postal ou retirada em loja.*/


-- 5. Quais categorias de produtos apresentam maior incidência de transações suspeitas?

SELECT Tratada.Categoria_do_Produto,
       COUNT(*) AS Quantidade_Transacoes_Suspeitas
FROM base_fraudes_consolidada AS Consolidada
INNER JOIN transacoes_tratadas AS Tratada
ON Tratada.ID_da_Transação = Consolidada.ID_da_Transação
WHERE (Gatilho_1_Valor + Gatilho_2_Frequencia + Gatilho_3_Quantidades + Gatilho_4_Endereço + Gatilho_5_IP) > 0
GROUP BY Tratada.Categoria_do_Produto
ORDER BY Quantidade_Transacoes_Suspeitas DESC

/* Não foi possível evidenciar uma categoria específica de produto, vinculada a uma transação suspeita.
   As transações foram realizadas para 12 categorias de produtos diferentes, sem grande variação entre eles.*/