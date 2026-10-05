--01. ESPAÇOS INDEVIDOS EM CAMPOS DE TEXTO

SELECT
    ID_do_Cliente,
    Endereço_IP,
    Endereço_de_Entrega,
    Categoria_do_Produto
    FROM dataset_transacoes_cartao
WHERE ID_do_Cliente <> TRIM(ID_do_Cliente)
OR    Endereço_IP <> TRIM(Endereço_IP)
OR    Endereço_de_Entrega <> TRIM(Endereço_de_Entrega)
OR    Categoria_do_Produto <> TRIM(Categoria_do_Produto);

--Não foram identificados espaços indevidos no início ou no final dos campos textuais avaliados.

--02. PADRONIZAÇÃO DAS CATEGORIAS

SELECT Categoria_do_Produto,
       COUNT(ID_da_Transação) AS Quantidade_de_Transações
FROM dataset_transacoes_cartao
GROUP BY Categoria_do_Produto
ORDER BY Quantidade_de_Transações DESC;

--Foram identificadas 12 categorias de produtos, com nomenclaturas padronizadas e distribuição relativamente equilibrada entre as transações.

--03. PADRONIZAÇÃO DOS ENDEREÇOS DE ENTREGA

SELECT 
       COUNT(DISTINCT Endereço_de_Entrega) AS Endereços_distintos
FROM dataset_transacoes_cartao;

SELECT Endereço_de_Entrega,
       COUNT(ID_da_Transação) AS Quantidade_de_Transações
FROM dataset_transacoes_cartao
GROUP BY Endereço_de_Entrega
ORDER BY Quantidade_de_Transações DESC;

SELECT 
       CASE
            WHEN Endereço_de_Entrega LIKE 'Caixa Postal%' THEN 'Caixa_Postal'
            WHEN Endereço_de_Entrega = 'Retirada em loja' THEN 'Retirada_em_Loja'
            ELSE 'Endereço_Comum'
        END AS Tipo_de_Entrega,
        COUNT(ID_da_Transação) AS Quantidade_de_Transações
FROM dataset_transacoes_cartao
GROUP BY 
        CASE
            WHEN Endereço_de_Entrega LIKE 'Caixa Postal%' THEN 'Caixa_Postal'
            WHEN Endereço_de_Entrega = 'Retirada em loja' THEN 'Retirada_em_Loja'
            ELSE 'Endereço_Comum'
        END;

/*Foram identificados 3 tipos de entrega.
  Endereço comum representa a grande maioria das transações (97%), enquanto Caixa Postal e Retirada em loja apresentam baixa frequência.
  Porém, as modalidades menos frequentes serão preservadas para posterior análise de possíveis mudanças no padrão de entrega dos clientes*/

--04. PADRONIZAÇÃO DOS ENDEREÇOS DE IP

SELECT 
	  COUNT(DISTINCT Endereço_IP) AS Endereços_IP_Distintos
FROM dataset_transacoes_cartao;

/*Foram identificados 5.469 endereços IP distintos para 5.469 transações.
  O resultado indica que cada transação possui um IP exclusivo, impossibilitando a identificação de IPs habituais por cliente.
  Como o dataset é sintético, a geração dos endereços IP será ajustada para representar padrões recorrentes por cliente,
  preservando também ocorrências eventuais de IPs distintos para posterior análise comportamental.*/

--05. CRIAÇÃO DA TABELA TRATADA

SELECT *
INTO transacoes_tratadas
FROM dataset_transacoes_cartao;

--06. VALIDAÇÃO DA TABELA TRATADA

SELECT COUNT(*) AS Total_Original
FROM dataset_transacoes_cartao;

SELECT COUNT(*) AS Total_Tratada
FROM transacoes_tratadas;

SELECT COUNT(DISTINCT ID_da_Transação) AS IDs_Distintos
FROM transacoes_tratadas;

--07. ANÁLISE DAS TRANSAÇÕES POR CLIENTE

SELECT 
    MIN(Quantidade_de_Transações) AS MIN_QTD,
    MAX(Quantidade_de_Transações) AS MAX_QTD,
    AVG(Quantidade_de_Transações) AS AVG_QTD
FROM
(
    SELECT 
        ID_do_Cliente,
        COUNT(ID_da_Transação) AS Quantidade_de_Transações
    FROM transacoes_tratadas
    GROUP BY ID_do_Cliente
) AS Total_de_Transações;

--08. NUMERAÇÃO DAS TRANSAÇÕES POR CLIENTES

SELECT
    ID_do_Cliente,
    ID_da_Transação,
    Data_e_Hora_da_Transação,
    ROW_NUMBER() OVER (
        PARTITION BY ID_do_Cliente
        ORDER BY Data_e_Hora_da_Transação
    ) AS Numero_da_Transação
FROM transacoes_tratadas;

--09. CLASSIFICAÇÃO DO USO DE IP

SELECT ID_do_Cliente,
       ID_da_Transação,
       Numero_da_Transação,
       CASE
       WHEN Numero_da_Transação % 20 = 0 THEN 'IP_Eventual'
       ELSE 'IP_Habitual'
       END AS Tipo_de_IP
FROM
(
    SELECT
        ID_do_Cliente,
        ID_da_Transação,
        Data_e_Hora_da_Transação,
        ROW_NUMBER() OVER (
            PARTITION BY ID_do_Cliente
            ORDER BY Data_e_Hora_da_Transação
        ) AS Numero_da_Transação
    FROM transacoes_tratadas
) AS Numero_da_Transação;

--10. ATUALIZAÇÃO DOS ENDEREÇOS DE IP

WITH Transacoes_Numeradas AS
(
    SELECT
        ID_da_Transação,
        ID_do_Cliente,
        ROW_NUMBER() OVER (
            PARTITION BY ID_do_Cliente
            ORDER BY Data_e_Hora_da_Transação
        ) AS Numero_da_Transação,
        ROW_NUMBER() OVER (
            ORDER BY ID_do_Cliente
        ) AS Numero_Geral
    FROM transacoes_tratadas
)

UPDATE T
SET Endereço_IP =
    CASE
        -- Aproximadamente 5%: IP eventual
        WHEN N.Numero_da_Transação % 20 = 0
        THEN CONCAT(
            '200.',
            (N.Numero_Geral % 200) + 1, '.',
            (N.Numero_Geral % 150) + 1, '.',
            (N.Numero_Geral % 240) + 1
        )

        -- IP habitual 1
        WHEN N.Numero_da_Transação % 3 <> 0
        THEN CONCAT(
            '177.10.',
            ABS(CHECKSUM(N.ID_do_Cliente)) % 200 + 1, '.10'
        )

        -- IP habitual 2
        ELSE CONCAT(
            '177.20.',
            ABS(CHECKSUM(N.ID_do_Cliente)) % 200 + 1, '.20'
        )
    END

FROM transacoes_tratadas AS T
INNER JOIN Transacoes_Numeradas AS N
    ON T.ID_da_Transação = N.ID_da_Transação;

--11. VALIDAÇÃO DOS ENDEREÇOS IP APÓS TRATAMENTO

SELECT 
	  COUNT(DISTINCT Endereço_IP) AS Endereços_IP_Distintos
FROM transacoes_tratadas;

/*Após o tratamento, a quantidade de endereços IP distintos foi reduzida de 5.469 para 323.
A estrutura tratada passa a representar IPs recorrentes por cliente,
preservando também ocorrências eventuais de IPs distintos para possibilitar a análise de mudanças no padrão de acesso.
A tabela original foi preservada sem alterações.*/

--12. VALIDAÇÃO FINAL TABELA TRATADA

SELECT 
       MIN(Data_e_Hora_da_Transação) AS Primeira_Transação,
       MAX(Data_e_Hora_da_Transação) AS Última_Transação,
       MIN(Valor_da_Transação_R) AS Menor_Valor,
       MAX(Valor_da_Transação_R) AS Maior_Valor,
       AVG(Valor_da_Transação_R) AS Valor_Médio,
       MIN(Idade) AS Menor_Idade,
       MAX(Idade) AS Maior_Idade,
       MIN(Unidades_Compradas) AS Menor_Quantidade,
       MAX(Unidades_Compradas) AS Maior_Quantidade
FROM transacoes_tratadas

/*Após a criação e tratamento da tabela transacoes_tratadas, foram validados o período dos dados e os limites das principais variáveis quantitativas.
  Os resultados permaneceram consistentes com o profiling da base original, sem perda de registros ou alterações indevidas nas demais variáveis.
  A principal adequação realizada foi a reestruturação dos endereços IP, permitindo a existência de padrões recorrentes por cliente e ocorrências
  eventuais para posterior análise comportamental.
  A base está apta para a etapa de análise exploratória.*/
       

