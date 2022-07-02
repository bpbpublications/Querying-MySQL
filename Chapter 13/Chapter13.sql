/* Chapter 13 */


-- 1

SELECT
 MakeName
,ModelName
,SaleDate
,SalePrice
,Cost
,SalePrice - IFNULL(Cost, 0) AS GrossProfit
,SalePrice - IFNULL(Cost, 0) - IFNULL(DirectCosts, 0)
           - IFNULL(LineItemDiscount, 0) 
             AS NetProfit
FROM
(
  SELECT     
   MK.MakeName
  ,MD.ModelName
  ,SA.SaleDate
  ,SD.SalePrice
  ,ST.Cost
  ,IFNULL(SD.LineItemDiscount, 0) AS LineItemDiscount
  ,(IFNULL(ST.RepairsCost, 0) + IFNULL(ST.PartsCost, 0) 
  + IFNULL(ST.TransportInCost, 0)) AS DirectCosts
  FROM       make AS MK 
  JOIN       model AS MD USING(MakeID)
  JOIN       stock AS ST USING(ModelID)
  JOIN        salesdetails SD ON ST.StockCode = SD.StockID
  JOIN        sales AS SA USING(SalesID)
  ) AS DT;


-- 2

SELECT     DT.CustomerClassification
           ,COUNT(DT.CustomerSpend) AS CustomerCount
FROM
          (
            SELECT     SUM(SD.SalePrice) AS CustomerSpend
            ,SA.CustomerID
            ,CASE
             WHEN SUM(SD.SalePrice) <= 100000 THEN 'Tiny'
             WHEN SUM(SD.SalePrice) BETWEEN 100001 AND 200000 
                                      THEN 'Small'
             WHEN SUM(SD.SalePrice) BETWEEN 200001 AND 300000 
                                      THEN 'Medium'
             WHEN SUM(SD.SalePrice) BETWEEN 300001 AND 400000 
                                      THEN 'Large'
             WHEN SUM(SD.SalePrice) > 400000 THEN 'Mega Rich'
            END AS CustomerClassification
            FROM       salesdetails SD 
                       JOIN sales AS SA USING(SalesID)
            GROUP BY   SA.CustomerID
         ) AS DT
GROUP BY   DT.CustomerClassification
ORDER BY   DT.CustomerSpend DESC;


-- 3

SELECT    ST.DateBought, MK.MakeName, MD.ModelName, ST.Color
          ,ST.Cost, SD.SalePrice, DT.AveragePurchasePrice
          ,DT.AverageSalePrice
FROM
     (
      SELECT     MakeName 
                 ,ModelName 
                 ,AVG(Cost) AS AveragePurchasePrice
                 ,AVG(SalePrice) AS AverageSalePrice
      FROM       make AS MK1
      JOIN       model AS MD1 USING(MakeID)
      JOIN       stock AS ST1 USING(ModelID)
      JOIN       salesdetails SD1 
                 ON ST1.StockCode = SD1.StockID
      GROUP BY   MakeName, ModelName
     ) AS DT
JOIN       make AS MK
           ON MK.MakeName = DT.MakeName
JOIN       model AS MD 
           ON MK.MakeID = MD.MakeID
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
ORDER BY   MakeName, ModelName, DateBought;


-- 4

SELECT     MKX.MakeName, SDX.SalePrice
FROM       make AS MKX 
JOIN       model AS MDX ON MKX.MakeID = MDX.MakeID
JOIN       stock AS STX ON STX.ModelID = MDX.ModelID
JOIN       salesdetails SDX ON STX.StockCode = SDX.StockID
JOIN      (
           SELECT     MK.MakeName
           FROM       make AS MK 
           JOIN       model AS MD USING(MakeID)
           JOIN       stock AS ST USING(ModelID)
           JOIN       salesdetails SD 
                      ON ST.StockCode = SD.StockID
           JOIN       sales SA USING(SalesID)
           GROUP BY   MK.MakeName
           ORDER BY   SUM(SA.TotalSalePrice) DESC
           LIMIT 5
          ) SB
ON MKX.MakeName = SB.MakeName
ORDER BY   MakeName, SalePrice DESC;


-- 5

SELECT      MK.MakeName
           ,COUNT(MK.MakeName) AS VehiclesSold
           ,SUM(SD.SalePrice) AS TotalSalesPerMake
FROM       make AS MK
JOIN       model AS MD ON MK.MakeID = MD.MakeID
JOIN       stock AS ST ON ST.ModelID = MD.ModelID
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN      (
                        SELECT     MK.MakeName
                        FROM       make AS MK 
                        JOIN       model AS MD USING(MakeID)
                        JOIN       stock AS ST USING(ModelID)
                        JOIN       salesdetails SD 
                                   ON ST.StockCode = SD.StockID
                        JOIN       sales AS SA USING(SalesID)
                        GROUP BY   MK.MakeName
                        ORDER BY   COUNT(MK.MakeName) DESC
                        LIMIT 3
                       ) DT
ON        DT.MakeName = MK.MakeName
GROUP BY  MK.MakeName
ORDER BY  VehiclesSold DESC;


-- 6

SELECT 
TOT.PurchaseYear
,AGG.Color
,(AGG.CostPerYear / TOT.TotalPurchasePrice) * 100 
            AS PercentPerColorPerYear
FROM
   (
     SELECT      Color
                ,SUM(Cost) AS CostPerYear
                ,YEAR(DateBought) AS YearBought
    FROM        stock  

    GROUP BY    Color
                ,YEAR(DateBought)
   ) AGG
JOIN
   (
    SELECT      YEAR(DateBought) AS PurchaseYear, SUM(Cost) 
                AS TotalPurchasePrice
    FROM        stock
    GROUP BY    YEAR(DateBought)
   ) TOT
ON TOT.PurchaseYear = AGG.YearBought
ORDER BY PurchaseYear, PercentPerColorPerYear DESC;


-- 7

SELECT 
 DT2.CountryName
,DT2.CustomerName
,DT2.NumberOfCustomerSales
,DT2.TotalCustomerSales
,DT2.NumberOfCustomerSales / DT1.NumberOfCountrySales 
       AS PercentageOfCountryCarsSold
,DT2.TotalCustomerSales / DT1.TotalCountrySales 
       AS PercentageOfCountryCarsSoldByValue
FROM
(
    SELECT      CO.CountryName
               ,COUNT(*) AS NumberOfCountrySales
               ,SUM(SD.SalePrice) AS TotalCountrySales
    FROM       stock AS ST 
    JOIN       salesdetails SD ON ST.StockCode = SD.StockID
    JOIN       sales AS SA USING(SalesID)
    JOIN       customer CU USING(CustomerID)
    JOIN       country CO ON CU.country = CO.CountryISO2
    GROUP BY   CO.CountryName
) AS DT1
JOIN
(
    SELECT      CO.CountryName
               ,CU.CustomerName
               ,COUNT(*) AS NumberOfCustomerSales
               ,SUM(SD.SalePrice) AS TotalCustomerSales
    FROM       stock AS ST 
    JOIN       salesdetails SD ON ST.StockCode = SD.StockID
    JOIN       sales AS SA USING(SalesID)
    JOIN       customer CU USING(CustomerID)
    JOIN       country CO ON CU.country = CO.CountryISO2
    GROUP BY   CO.CountryName, CU.CustomerName
) AS DT2
ON       DT1.CountryName = DT2.CountryName
ORDER BY DT1.CountryName, DT2.NumberOfCustomerSales DESC;


-- 8

SELECT      CO.CountryName
           ,SUM(SD.SalePrice) AS sales
           ,CSQ.BudgetValue
           ,YEAR(SaleDate) AS YearOfSale
           ,MONTH(SaleDate) AS MonthOfSale
           ,SUM(CSQ.BudgetValue) 
           - SUM(SD.SalePrice) AS DifferenceBudgetToSales
FROM      salesdetails SD
JOIN      sales AS SA USING(SalesID)
JOIN      customer CU USING(CustomerID)
JOIN      country CO ON CU.country = CO.CountryISO2
JOIN           (
                  SELECT     BudgetValue, BudgetDetail, Year, Month
                  FROM       budget
                  WHERE      BudgetElement = 'country'
               ) CSQ
               ON CSQ.BudgetDetail = CO.CountryName
               AND CSQ.Year = YEAR(SaleDate)
               AND CSQ.Month = MONTH(SaleDate)
GROUP BY CO.CountryName, YEAR(SaleDate), MONTH(SaleDate)
ORDER BY CO.CountryName, YEAR(SaleDate), MONTH(SaleDate);

-- 9

SELECT      MK.MakeName
           ,MD.ModelName
           ,SD.SalePrice
           ,CSQ.MaxSalePrice AS MaxPrevYear
           ,SD.SalePrice - CSQ.MaxSalePrice 
               AS PriceDifferenceToMaxPrevYear
FROM       make AS MK 
JOIN       model AS MD ON MK.MakeID = MD.MakeID
JOIN       stock AS ST ON ST.ModelID = MD.ModelID
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA ON SA.SalesID = SD.SalesID
JOIN  (
              SELECT     MAX(SDX.SalePrice) AS MaxSalePrice
                        ,YEAR(SAX.SaleDate) AS SaleYear
                        ,MDX.ModelName
              FROM       make AS MKX 
              JOIN       model AS MDX USING(MakeID)
              JOIN       stock AS STX USING(ModelID)
              JOIN       salesdetails SDX 
                         ON STX.StockCode = SDX.StockID
              JOIN       sales AS SAX USING(SalesID)
              WHERE      YEAR(SAX.SaleDate) = 2015
              GROUP BY   YEAR(SAX.SaleDate)
                         ,MDX.ModelName
         ) CSQ
         ON CSQ.ModelName = MD.ModelName
WHERE       YEAR(SA.SaleDate) = 2016;

-- 10

SELECT      MK.MakeName
           ,MD.ModelName
           ,SD.SalePrice
           ,CSQ.MaxSalePrice AS MaxPrevYear
           ,SD.SalePrice - CSQ.MaxSalePrice 
               AS PriceDifferenceToMaxPrevYear
FROM       make AS MK 
JOIN       model AS MD ON MK.MakeID = MD.MakeID
JOIN       stock AS ST ON ST.ModelID = MD.ModelID
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA ON SA.SalesID = SD.SalesID
JOIN  (
              SELECT     MAX(SDX.SalePrice) AS MaxSalePrice
                        ,YEAR(SAX.SaleDate) AS SaleYear
                        ,MDX.ModelName
              FROM       make AS MKX 
              JOIN       model AS MDX USING(MakeID)
              JOIN       stock AS STX USING(ModelID)
              JOIN       salesdetails SDX 
                         ON STX.StockCode = SDX.StockID
              JOIN       sales AS SAX USING(SalesID)
              WHERE      YEAR(SAX.SaleDate) = 2015
              GROUP BY   YEAR(SAX.SaleDate)
                         ,MDX.ModelName
         ) CSQ
         ON CSQ.ModelName = MD.ModelName
WHERE       YEAR(SA.SaleDate) = 2016;


















