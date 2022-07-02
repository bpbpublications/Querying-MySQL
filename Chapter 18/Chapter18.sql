/* Chapter 18 */


-- 1

SELECT       CustomerName
            ,CONCAT(MakeName, ', ', ModelName) AS MakeAndModel
            ,SalePrice
            ,RANK() OVER (ORDER BY SalePrice DESC) 
                   AS SalesImportance
FROM        salesbycountry
WHERE       YEAR(SaleDate) = 2018
ORDER BY    SalesImportance;


-- 2

SELECT       CONCAT(MK.MakeName, ', ', MD.ModelName) 
               AS MakeAndModel
            ,SD.SalePrice
            ,RANK() OVER (PARTITION BY MK.MakeName 
                          ORDER BY SD.SalePrice DESC) 
                                 AS SalesImportance
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      YEAR(SA.SaleDate) = 2017
ORDER BY   MakeName, SD.SalePrice DESC;


-- 3

WITH
AllSalesProfit_CTE (CustomerName, MakeName
                    ,ModelName, SalePrice, ProfitPerModel)
AS
(
SELECT       CustomerName, MakeName, ModelName
             ,SalePrice
             ,((SalePrice - 
                 (Cost + IFNULL(RepairsCost,0) 
                  + IFNULL(PartsCost,0) + IFNULL(TransportInCost,0)))
                / SalePrice) * 100
FROM        salesbycountry
)
  
SELECT       CustomerName, MakeName, ModelName
             ,ProfitPerModel, SalePrice
             ,RANK() OVER 
                      (PARTITION BY CustomerName, MakeName 
                       ORDER BY ProfitPerModel DESC) 
                         AS SalesImportance
FROM        AllSalesProfit_CTE
ORDER BY    CustomerName, MakeName, SalesImportance;


-- 4


SELECT      MakeName, Color
FROM
             (
             SELECT       DISTINCT MakeName, Color
                         ,RANK() OVER (PARTITION BY MakeName
                                       ORDER BY SalePrice DESC)
                            AS ColorRank
             FROM       make AS MK 
             JOIN       model AS MD USING(MakeID)
             JOIN       stock AS ST USING(ModelID)
             JOIN       salesdetails SD 
                        ON ST.StockCode = SD.StockID
             ) SQ	
WHERE       ColorRank = 1
ORDER BY MakeName;


-- 5

SELECT      Color, MakeAndModel, SalesImportance
FROM
(
SELECT       ST.Color, CONCAT(MK.MakeName, ', ', MD.ModelName)
                         AS MakeAndModel
             ,SD.SalePrice
             ,DENSE_RANK() OVER (ORDER BY SD.SalePrice DESC) 
                           AS SalesImportance
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN 
           (
            SELECT   Color, COUNT(*) AS NumberOfSales
            FROM     stock AS ST
            JOIN     salesdetails SD 
                     ON ST.StockCode = SD.StockID
            GROUP BY Color
            ORDER BY NumberOfSales DESC
            LIMIT 5
            ) CL
            ON CL.Color = ST.Color
) RK
WHERE       SalesImportance <= 10
ORDER BY    SalesImportance;


-- 6

SELECT     ST.Color
           ,CONCAT(MK.MakeName, ', ', MD.ModelName) 
                  AS MakeAndModel
           ,SD.SalePrice
           ,NTILE(10) OVER (ORDER BY SD.SalePrice DESC) 
                  AS SalesDecile
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
ORDER BY   SalesDecile, ST.Color, MakeAndModel;


-- 7

WITH PercentileList_CTE
AS
(
SELECT     RepairsCost
          ,Cost
          ,NTILE(100) OVER (ORDER BY Cost DESC) AS Percentile
FROM      stock
)

SELECT    Percentile
          ,SUM(Cost) AS TotalCostPerPercentile
          ,SUM(RepairsCost) AS RepairsCostPerPercentile
              ,SUM(RepairsCost) / SUM(Cost) AS RepairCostRatio
FROM      PercentileList_CTE
GROUP BY  Percentile
ORDER BY  RepairCostRatio DESC;


-- 8

WITH Top20PercentSales_CTE
AS
(
SELECT SD.SalesDetailsID, MK.MakeName, MD.ModelName, SD.SalePrice
       ,NTILE(5) OVER (ORDER BY SD.SalePrice DESC) 
             AS SalesQuintile
FROM   make AS MK 
JOIN   model AS MD ON MK.MakeID = MD.MakeID
JOIN   stock AS ST ON ST.ModelID = MD.ModelID
JOIN   salesdetails SD ON ST.StockCode = SD.StockID
)
SELECT      CTE.MakeName, CTE.ModelName, CTE.SalePrice
FROM        Top20PercentSales_CTE CTE
JOIN        (
                  SELECT   MakeName
                  FROM     Top20PercentSales_CTE
                  WHERE    SalesQuintile = 2
                  GROUP BY MakeName
                  ORDER BY SUM(SalePrice) DESC
                  LIMIT 3
             ) SB
           ON CTE.MakeName = SB.MakeName
ORDER BY   SalePrice DESC;


-- 9

WITH SalesByPercentile_CTE
AS
(
SELECT MK.MakeName, MD.ModelName, SD.SalePrice
       ,NTILE(100) OVER (ORDER BY SD.SalePrice DESC) 
          AS SalesPercentile
FROM   make AS MK 
JOIN   model AS MD ON MK.MakeID = MD.MakeID
JOIN   stock AS ST ON ST.ModelID = MD.ModelID
JOIN   salesdetails SD ON ST.StockCode = SD.StockID
)
SELECT    MakeName, ModelName, SalePrice
FROM      SalesByPercentile_CTE
WHERE     SalesPercentile <= 10
ORDER BY  MakeName, ModelName, SalePrice;


-- 10

SELECT      MK.MakeName, MD.ModelName, SA.InvoiceNumber
            ,SD.SalePrice
           ,ROUND(CUME_DIST() 
           OVER (PARTITION BY MK.MakeName ORDER BY SD.SalePrice), 2) 
           AS RelativeStanding
FROM       make AS MK 	
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
ORDER BY   MK.MakeName, SD.SalePrice, RelativeStanding;


-- 11

SELECT      CO.CountryName, SA.SaleDate, SA.InvoiceNumber
           ,CONCAT(FORMAT(PERCENT_RANK() 
           OVER (PARTITION BY CO.CountryName 
           ORDER BY SA.TotalSalePrice), 2) * 100, ' %')
                AS PercentageRanking
FROM       sales AS SA 	
JOIN       customer CU USING(CustomerID)
JOIN       country CO ON CU.country = CO.CountryISO2
ORDER BY   CO.CountryName, SA.TotalSalePrice DESC;


-- 12

SELECT     DISTINCT  CU.CustomerName
           ,TotalSalePrice
           ,MEDIAN(TotalSalePrice) 
               OVER(PARTITION BY CustomerName) AS MedianValuePerCustomer
           ,TotalSalePrice - MEDIAN(TotalSalePrice) 
                               OVER(PARTITION BY CustomerName) 
               AS SaleToMedianDelta
FROM       sales AS SA 	
JOIN       customer CU ON SA.CustomerID = CU.CustomerID
ORDER BY   CU.CustomerName;






