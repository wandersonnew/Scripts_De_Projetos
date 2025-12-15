CREATE PROCEDURE PROCEDURE_EVOLUCAO
   @Ano INT = NULL,
   @Mes INT = NULL,
   @Dia INT = NULL,
   @Equipamento VARCHAR(30) = NULL,
   @CodProduto VARCHAR(30) = NULL
AS
BEGIN

   SELECT
       E.Nome AS Equipamento,
       V.DataValidacao AS Validacao,
       SUM(PP.Reserva) AS Reserva
   FROM SGRI_EVA_CRA_HML.dbo.ProgramasProducao PP
   CROSS APPLY (
       SELECT CAST(PP.Validacao AS DATE) AS DataValidacao
   ) AS V
   LEFT JOIN SGRI_EVA_CRA_HML.dbo.Equipamentos E
       ON PP.EquipamentoId = E.Id
   LEFT JOIN SGRI_EVA_CRA_HML.dbo.Produtos Prod
       ON Prod.Id = PP.ProdutoId
   WHERE PP.Validacao IS NOT NULL
       AND YEAR(PP.Validacao) = @Ano
       AND (@Mes IS NULL OR MONTH(PP.Validacao) = @Mes)
       AND (@Dia IS NULL OR DAY(PP.Validacao) = @Dia)
       AND (@Equipamento IS NULL OR E.Nome = @Equipamento)
       AND (@CodProduto IS NULL OR Prod.Codigo = @CodProduto)
   GROUP BY 
       E.Nome,
       V.DataValidacao
   ORDER BY 
       V.DataValidacao;
END;

-- EXEC [SGRI_EVA_CRA_HML].[dbo].[PROCEDURE_EVOLUCAO] @Ano = 2025