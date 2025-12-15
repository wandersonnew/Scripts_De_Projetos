CREATE PROCEDURE PROCEDURE_EQUIPAMENTOS
   @Ano INT = NULL,
   @Mes INT = NULL,
   @Dia INT = NULL,
   @Equipamento VARCHAR(30) = NULL,
   @CodProduto VARCHAR(30) = NULL
AS
BEGIN

   ;WITH FiltroDatas AS (
       SELECT @Ano AS Ano, @Mes AS Mes, @Dia AS Dia
   ),

   CTE_Perdas AS (
       SELECT 
           P.Equipamento,
           SUM(P.QtdKilos) AS TotalPerdas
       FROM SGRI_EVA_CRA_HML.dbo.Perdas P
       CROSS JOIN FiltroDatas F
       WHERE P.Ativo = 1
       AND YEAR(P.CriadoEm) = F.Ano
       AND (F.Mes IS NULL OR MONTH(P.CriadoEm) = F.Mes)
       AND (F.Dia IS NULL OR DAY(P.CriadoEm) = F.Dia)
       AND (@CodProduto IS NULL OR P.CodigoProduto = @CodProduto)
       GROUP BY P.Equipamento
   ),

   CTE_Purgas AS (
       SELECT 
           Pu.NomeEquipamento AS Equipamento,
           SUM(Pu.QtdQuilos) AS TotalPurgas
       FROM SGRI_EVA_CRA_HML.dbo.Purgas Pu
       CROSS JOIN FiltroDatas F
       WHERE Pu.Ativo = 1
       AND YEAR(Pu.CriadoEm) = F.Ano
       AND (F.Mes IS NULL OR MONTH(Pu.CriadoEm) = F.Mes)
       AND (F.Dia IS NULL OR DAY(Pu.CriadoEm) = F.Dia)
       AND (@CodProduto IS NULL OR Pu.CodigoProduto = @CodProduto)
       GROUP BY Pu.NomeEquipamento
   ),

   CTE_Rabichos AS (
       SELECT 
           R.NomeEquipamento AS Equipamento,
           SUM(R.QtdQuilos) AS TotalRabichos
       FROM SGRI_EVA_CRA_HML.dbo.Rabichos R
       CROSS JOIN FiltroDatas F
       WHERE R.Ativo = 1
       AND YEAR(R.CriadoEm) = F.Ano
       AND (F.Mes IS NULL OR MONTH(R.CriadoEm) = F.Mes)
       AND (F.Dia IS NULL OR DAY(R.CriadoEm) = F.Dia)
       AND (@CodProduto IS NULL OR R.CodigoProduto = @CodProduto)
       GROUP BY R.NomeEquipamento
   ),

   CTE_Varreduras AS (
       SELECT 
           C.Equipamento,
           SUM(C.QtdQuilos) AS TotalVarreduras
       FROM SGRI_EVA_CRA_HML.dbo.Compostos C
       CROSS JOIN FiltroDatas F
       WHERE C.Ativo = 1
       AND YEAR(C.CriadoEm) = F.Ano
       AND (F.Mes IS NULL OR MONTH(C.CriadoEm) = F.Mes)
       AND (F.Dia IS NULL OR DAY(C.CriadoEm) = F.Dia)
       GROUP BY C.Equipamento
   )

   SELECT 
       E.Nome AS Descricao,
       SUM(PP.Reserva) AS Reserva,

       COALESCE(P.TotalPerdas, 0) AS Perdas,
       COALESCE(Pu.TotalPurgas, 0) AS Purgas,
       COALESCE(R.TotalRabichos, 0) AS Rabichos,
       COALESCE(V.TotalVarreduras, 0) AS Varreduras

   FROM SGRI_EVA_CRA_HML.dbo.ProgramasProducao PP
   LEFT JOIN SGRI_EVA_CRA_HML.dbo.Equipamentos E 
       ON PP.EquipamentoId = E.Id
   LEFT JOIN SGRI_EVA_CRA_HML.dbo.Produtos Prod
       ON Prod.Id = PP.ProdutoId

   LEFT JOIN CTE_Perdas     P  ON P.Equipamento = E.Nome
   LEFT JOIN CTE_Purgas     Pu ON Pu.Equipamento = E.Nome
   LEFT JOIN CTE_Rabichos   R  ON R.Equipamento = E.Nome
   LEFT JOIN CTE_Varreduras V  ON V.Equipamento = E.Nome

   WHERE YEAR(PP.Validacao) = @Ano
   AND (@Mes IS NULL OR MONTH(PP.Validacao) = @Mes)
   AND (@Dia IS NULL OR DAY(PP.Validacao) = @Dia)
   AND (@Equipamento IS NULL OR E.Nome = @Equipamento)
   AND (@CodProduto IS NULL OR Prod.Codigo = @CodProduto)

   GROUP BY 
       E.Nome,
       P.TotalPerdas,
       Pu.TotalPurgas,
       R.TotalRabichos,
       V.TotalVarreduras;

END;

-- EXEC [SGRI_EVA_CRA_HML].[dbo].[PROCEDURE_EQUIPAMENTOS] @Ano = 2025