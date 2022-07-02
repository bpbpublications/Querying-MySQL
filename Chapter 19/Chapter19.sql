/* Chapter 19 */


-- 1

SELECT       SA.InvoiceNumber 
            ,DATE_FORMAT(SA.SaleDate, '%e %M %Y')  AS DateOfSale
            ,SD.SalePrice
            ,SUM(SD.SalePrice) 
            OVER (ORDER BY SA.SaleDate ASC) AS AccumulatedSales
            ,AVG(SD.SalePrice) 
            OVER (ORDER BY SA.SaleDate ASC) 
                  AS AverageSalesValueToDate
FROM        salesdetails SD
JOIN        sales AS SA USING(SalesID)
WHERE       YEAR(SA.SaleDate) = 2017
ORDER BY    SA.SaleDate;


-- 2

SELECT      DateBought
            ,SUM(Cost) AS PurchaseCost
            ,SUM(SUM(Cost)) 
               OVER (ORDER BY DateBought ASC) AS CostForTheYear
FROM        stock
WHERE       YEAR(DateBought) = 2016
GROUP BY    DateBought
ORDER BY    DateBought;


-- 3

SELECT      DATE(SA.SaleDate) AS DateOfSale
           ,CU.CustomerName, CU.Town
           ,SD.SalePrice
           ,COUNT(SD.SalesDetailsID) 
             OVER (PARTITION BY YEAR(SA.SaleDate) 
                   ORDER BY SA.SaleDate, SalesDetailsID ASC) 
                      AS AnnualNumberOfSalesToDate
FROM       salesdetails SD
JOIN       sales AS SA USING(SalesID)
JOIN       customer CU ON SA.CustomerID = CU.CustomerID
ORDER BY   SA.SaleDate;


-- 4

SELECT       DATE(SaleDate) AS DateOfSale
            ,DailyCount AS NumberOfSales
            ,SUM(DailyCount) OVER 
                   (PARTITION BY YEAR(SaleDate) ORDER BY SaleDate ASC) 
                   AS AnnualNumberOfSalesToDate
            ,SUM(DailySalePrice) OVER 
                   (PARTITION BY YEAR(SaleDate) ORDER BY SaleDate ASC) 
                   AS AnnualSalePriceToDate
FROM        (
             SELECT       SaleDate
                         ,COUNT(SD.SalesDetailsID) AS DailyCount
                         ,SUM(SD.SalePrice) AS DailySalePrice
             FROM        salesdetails SD
             JOIN        sales AS SA USING(SalesID)
             GROUP BY    SaleDate
            ) DT
ORDER BY    SaleDate;


-- 5

SELECT       SA.SaleDate
            ,SD.SalePrice, CU.CustomerName, CU.Town, MK.MakeName
            ,COUNT(SD.SalesDetailsID) 
              OVER (PARTITION BY YEAR(SaleDate) ORDER BY SaleDate ASC) 
              AS AnnualNumberOfSalesToDate
            ,ROW_NUMBER() OVER (ORDER BY SaleDate ASC) 
              AS SalesCounter        
FROM        make AS MK 
JOIN        model AS MD ON MK.MakeID = MD.MakeID
JOIN        stock AS ST ON ST.ModelID = MD.ModelID
JOIN        salesdetails SD ON ST.StockCode = SD.StockID
JOIN        sales AS SA ON SA.SalesID = SD.SalesID
JOIN        customer CU ON SA.CustomerID = CU.CustomerID
ORDER BY    SaleDate;


-- 6

WITH Tally_CTE
AS
(
SELECT     ROW_NUMBER() OVER (ORDER BY StockCode) AS Num
FROM       stock
ORDER BY   Num 
LIMIT 52
)

SELECT           Num, SalesForTheWeek
FROM             Tally_CTE CTE
LEFT OUTER JOIN  
                 (
                 SELECT         SUM(TotalSalePrice) 
                                   AS SalesForTheWeek
                               ,WEEK(SaleDate) + 1 AS WeekNo
                 FROM          sales
                 WHERE         YEAR(SaleDate) = 2016
                 GROUP BY      WEEK(SaleDate)
                 ) SLS
                 ON CTE.Num = SLS.WeekNo;


-- 7

WITH Tally_CTE
AS
(
SELECT     ROW_NUMBER() OVER (ORDER BY ST1.StockCode) - 1 AS Num
FROM       stock ST1
CROSS JOIN stock ST2
LIMIT 10000
)
,DateRange_CTE
AS
(
SELECT     DATE_ADD('20170101', INTERVAL Num DAY) AS DateList 
FROM       Tally_CTE 
WHERE      Num <= DATEDIFF('20170630', '20170101')
)

SELECT           DATE(DateList) AS SaleDate, SalesPerDay
FROM             DateRange_CTE CTE
LEFT JOIN
           (
           SELECT         DATE(SaleDate) AS DateOfSale
                         ,SUM(TotalSalePrice) AS SalesPerDay
           FROM          sales
           GROUP BY      DATE(SaleDate)
           ) SLS
           ON CTE.DateList = SLS.DateOfSale;


-- 8

SELECT      CU.CustomerName
           ,SA.SaleDate
           ,SA.TotalSalePrice
           ,SA.TotalSalePrice - LAG(SA.TotalSalePrice,1) 
                                OVER (PARTITION BY CU.CustomerName 
                                ORDER BY SA.SaleDate)
                        AS DifferenceToPreviousSalePrice
FROM       sales SA
JOIN       customer CU USING(CustomerID)
ORDER BY   SA.SaleDate;


-- 9

SELECT    CU.CustomerName
          ,SA.SaleDate
          ,SA.TotalSalePrice AS CurrentSale
          ,FIRST_VALUE(SA.TotalSalePrice) 
           OVER (PARTITION BY CU.CustomerName 
                  ORDER BY SA.SaleDate, SA.SalesID)
                 AS InitialOrder
          ,LAST_VALUE(SA.TotalSalePrice) 
           OVER (PARTITION BY CU.CustomerName 
                 ORDER BY SA.SaleDate, SA.SalesID 
           ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) 
           AS FinalOrder	
FROM       sales SA
JOIN       customer CU USING(CustomerID);


-- 10

SELECT      CU.CustomerName
           ,SA.SaleDate
           ,SA.TotalSalePrice
           ,AVG(SA.TotalSalePrice) 
            OVER (PARTITION BY CU.CustomerName ORDER BY SA.SaleDate 
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) 
                AS AverageSalePrice
FROM       sales AS SA 
JOIN       customer CU USING(CustomerID)
ORDER BY   CU.CustomerName, SA.SaleDate;


-- 11


SELECT   
 CU.CustomerName
,SA.SaleDate
,SA.TotalSalePrice
,FIRST_VALUE(TotalSalePrice) OVER (PARTITION BY CU.CustomerName
                                  ORDER BY SA.SaleDate) 
                                     AS FirstOrder
,LAG(TotalSalePrice, 3) OVER (PARTITION BY CU.CustomerName
                                  ORDER BY SA.SaleDate)
                                     AS LastButThreeOrder
,LAG(TotalSalePrice, 2) OVER (PARTITION BY CU.CustomerName
                                  ORDER BY SA.SaleDate) 
                                     AS LastButTwoOrder
,LAG(TotalSalePrice, 1) OVER (PARTITION BY CU.CustomerName
                                  ORDER BY SA.SaleDate) 
                                     AS LastButOneOrder
,LAST_VALUE(TotalSalePrice) OVER (PARTITION BY CU.CustomerName
                                  ORDER BY SA.SaleDate) 
                                     AS LatestOrder
FROM     sales AS SA 	
JOIN     customer CU USING(CustomerID)
ORDER BY CU.CustomerName, SA.SaleDate;





















