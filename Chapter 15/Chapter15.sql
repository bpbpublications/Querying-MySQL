/* Chapter 15 */


-- 1

SELECT
           SalesDetailsID
          ,SalePrice
          ,(SELECT TotalSalePrice FROM sales 
WHERE     SalesId = SD.SalesId) AS TotalSales
FROM      salesdetails SD
ORDER BY  SalesDetailsID;


-- 2

SELECT
 CS.CustomerName
,SA.INVOICENUMBER
,SD.SalePrice
,SD.SalePrice
/
(
  SELECT     SUM(SDC.SalePrice)
  FROM       salesdetails SDC
  JOIN       sales SAC USING(SalesID)
  JOIN       customer CSC ON SAC.CustomerID = CSC.CustomerID 
  WHERE      SAC.CustomerID = CS.CustomerID
) * 100 AS PercentSalesPerCustomer
FROM       salesdetails SD 
JOIN       sales AS SA USING(SalesID)
JOIN       customer CS USING(CustomerID)
ORDER BY   CS.CustomerName;


-- 3

SELECT     MKX.MakeName, STX.RepairsCost, STX.StockCode
FROM       make AS MKX JOIN model AS MDX USING(MakeID)
JOIN       stock AS STX USING(ModelID)
JOIN       salesdetails SDX ON STX.StockCode = SDX.StockID
WHERE      STX.RepairsCost >
                 (
                  SELECT     AVG(ST.RepairsCost) AS AvgRepairCost
                  FROM       make AS MK
                  JOIN       model AS MD USING(MakeID)
                  JOIN       stock AS ST USING(ModelID)
                  WHERE      MK.MakeName = MKX.MakeName
                  ) * 1.5;


-- 4

SELECT     MKX.MakeName, STX.RepairsCost, STX.StockCode
,(
    SELECT     AVG(ST.RepairsCost) AS AvgRepairCost
    FROM       make AS MK
    JOIN       model AS MD USING(MakeID)
    JOIN       stock AS ST USING(ModelID)
    WHERE      MK.MakeName = MKX.MakeName
 ) AS MakeAvgRepairCost

FROM       make AS MKX 
JOIN       model AS MDX USING(MakeID)
JOIN       stock AS STX ON STX.ModelID = MDX.ModelID
JOIN       salesdetails SDX ON STX.StockCode = SDX.StockID
WHERE      STX.RepairsCost >
                 (
                  SELECT     AVG(ST.RepairsCost) AS AvgRepairCost
                  FROM       make AS MK
                  JOIN       model AS MD USING(MakeID)
                  JOIN       stock AS ST USING(ModelID)
                  WHERE     MK.MakeName = MKX.MakeName
                  ) * 1.5;


-- 5

SELECT     CUX.CustomerName
          ,CUX.Town
          ,COX.CountryName
FROM      customer CUX
JOIN      country COX ON CUX.country = COX.CountryISO2
WHERE     COX.CountryISO2 IN
                (
                 SELECT     DISTINCT CU.country
                 FROM       salesdetails SD 
                 JOIN       sales AS SA USING(SalesID)
                 JOIN       customer CU USING(CustomerID)
                 JOIN       country CO 
                            ON CU.country = CO.CountryISO2
                 WHERE      CU.country = CUX.country
                 GROUP BY   CU.CustomerID
                 HAVING     SUM(SD.SalePrice) > 500000
                 )
ORDER BY   COX.CountryName, CUX.CustomerName;


-- 6

SELECT     MKX.MakeName, MDX.ModelName
FROM       make AS MKX 
           JOIN model AS MDX USING(MakeID)
           JOIN stock AS STX USING(ModelID)
GROUP BY   MKX.MakeName, MDX.ModelName
HAVING     MAX(STX.Cost) >= 
                  (
                   SELECT     AVG(ST.Cost) * 1.5 AS AvgCostPerModel
                   FROM       make AS MK 
                   JOIN       model AS MD USING(MakeID)
                   JOIN       stock AS ST USING(ModelID)
                   WHERE      MD.ModelName = MDX.ModelName
                              AND MK.MakeName = MKX.MakeName
                    );


-- 7

SELECT DISTINCT    CU.CustomerName
FROM               customer CU
WHERE              EXISTS
                   (
                    SELECT    *
                    FROM      sales SA
                    WHERE     SA.CustomerID = CU.CustomerID
                              AND YEAR(SA.SaleDate) = 2017
                   )
ORDER BY           CU.CustomerName;


-- 8

SELECT     CONCAT(MakeName, ', ', ModelName) AS VehicleInStock
           ,ST.Stockcode
FROM       make AS MK 
JOIN       model AS MD ON MK.MakeID = MD.MakeID
JOIN       stock AS ST ON ST.ModelID = MD.ModelID
WHERE      NOT EXISTS	
                      (SELECT  *
                       FROM    salesdetails SD
                       WHERE   ST.StockCode = SD.StockID);


-- 9

SELECT     MKX.MakeName, MDX.ModelName
           ,YEAR(STX.DateBought) AS PurchaseYear
FROM       make AS MKX JOIN model AS MDX 
           ON MKX.MakeID = MDX.MakeID
           JOIN stock AS STX ON STX.ModelID = MDX.ModelID
WHERE      YEAR(STX.DateBought) IN (2015, 2016)
GROUP BY   MKX.MakeName, YEAR(STX.DateBought)
HAVING     MAX(STX.Cost) >= 
                          (	
                           SELECT  AVG(ST.Cost) * 2 
                                   AS AvgCostPerModel
                           FROM    make AS MK 
                                   JOIN model AS MD 
                                   ON MK.MakeID = MD.MakeID
                                   JOIN stock AS ST 
                                   ON ST.ModelID = MD.ModelID
                           WHERE   MK.MakeName = MKX.MakeName
                                   AND  MD.ModelName 
                                           = MDX.ModelName
                                   AND YEAR(ST.DateBought) 
                                           = PurchaseYear
                         );


-- 10

SELECT     SalesID
           ,TotalSalePrice
          ,CASE WHEN 
                     (
                       SELECT SUM(SalePrice)
                        FROM   salesdetails
                        WHERE  SalesID = sales.SalesID
                      ) = TotalSalePrice
                            THEN 'OK'
                            ELSE 'Error in Invoice'
                 END AS LineItemCheck
FROM       sales
ORDER BY   SalesID;



