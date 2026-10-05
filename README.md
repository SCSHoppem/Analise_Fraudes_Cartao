# 🛡️ Análise e Detecção de Anomalias em Transações de Cartão de Crédito

## 📌 Sobre o Projeto
Este projeto de Análise de Dados foca na identificação de potenciais fraudes e anomalias comportamentais em transações de cartões de crédito.
O objetivo foi criar lógicas de identificação de comportamentos suspeitos baseados no histórico individual de cada cliente, utilizando exclusivamente **SQL Server**.

## 🛠️ Ferramentas e Tecnologias
- **SQL Server (T-SQL):** Utilizado para todo o processo de ETL, limpeza, Engenharia de *Features* e Análise de Negócio.
- **Técnicas aplicadas:** CTEs (*Common Table Expressions*), Funções de Janela (*Window Functions* como `LAG`), Agregações, Joins, *Data Profiling* e manipulação de *Strings* (`LIKE`).

## ⚙️ Metodologia
O projeto foi dividido em 5 etapas principais (cujos roteiros se encontram neste repositório):
1. **Profiling:** Exploração inicial para entender a estrutura e integridade dos dados brutos.
2. **Limpeza e Tratamento:** Padronização de tipos de dados e tratamento de nulos/inconsistências.
3. **Engenharia de Gatilhos (Triggers):** Criação de 5 regras de negócio para sinalizar anomalias:
   - Valor da transação acima do padrão do cliente (3x a média).
   - Frequência atípica (transações com menos de 5 minutos de intervalo).
   - Quantidades compradas acima do padrão do cliente (3x a média).
   - Uso de endereços de entrega pouco frequentes.
   - Mudança para IPs nunca antes utilizados pelo cliente.
4. **Base Analítica Consolidada:** Criação de uma *View* unificando as marcações (0 ou 1) para cada transação.
5. **Business Intelligence:** Extração de respostas para o negócio a partir da base consolidada.

## 📊 Principais Insights de Negócio
Através das consultas de BI, foi possível responder a questões fundamentais para a prevenção de fraudes:
- **Anomalia mais comum:** Quantidades atípicas por transação (410 ocorrências), seguida de anomalias de Valor e IP. A frequência atípica foi o gatilho menos acionado (apenas 14).
- **Horários de Risco:** Picos de transações suspeitas identificados fora do horário comercial, especificamente às **8h da manhã, 18h e final da noite (23h e 0h)**.
- **Perfil Demográfico:** O público **acima de 55 anos** representou cerca de 1/3 (32%) de todas as anomalias, indicando um grupo de maior vulnerabilidade.
- **Geografia:** O estado do **Rio Grande do Sul (RS)** concentrou quase 30% do volume total de transações atípicas.
- **Categorias de Produtos:** As anomalias distribuíram-se de forma muito uniforme entre 12 categorias de produtos diferentes (desde Livros a Utensílios de Cozinha), provando que os fraudadores não têm um alvo específico nesta base.

## 🚀 Como Executar
1. Copie o repositório.
2. Execute os *scripts* na ordem numerada (`01` a `05`) no seu ambiente SQL Server.
