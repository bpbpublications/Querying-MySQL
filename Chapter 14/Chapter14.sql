/* Chapter 14 */


-- 1

WITH Sales2015_CTE 
AS
(
SELECT     MK.MakeName, MD.ModelName, ST.Color
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      YEAR(SaleDate) = 2015
)
SELECT     MakeName, ModelName, Color
FROM       Sales2015_CTE
GROUP BY   MakeName, ModelName, Color
ORDER BY   MakeName, ModelName, Color;


-- 2

WITH Sales_CTE
AS
(
SELECT     MakeName
           ,SalePrice - (
                         ST.Cost 
                         + IFNULL(ST.RepairsCost, 0) 
                         + IFNULL(ST.PartsCost, 0) 
                         + IFNULL(ST.TransportInCost, 0)
                        ) AS Profit
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
)

SELECT     MakeName, AVG(Profit) AS AverageProfit
FROM       sales_CTE
GROUP BY   MakeName;


-- 3

WITH Discount2015_CTE (Make, Model
                       ,Color, SalePrice, LineItemDiscount)
AS
(
SELECT     MK.MakeName, MD.ModelName, ST.Color
           ,SD.SalePrice, SD.LineItemDiscount
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      YEAR(SA.SaleDate) = 2015
)

SELECT     make, model, Color, LineItemDiscount, SalePrice
           ,(SELECT AVG(LineItemDiscount) * 2 FROM Discount2015_CTE) 
           AS AverageDiscount2015
FROM       Discount2015_CTE
WHERE      LineItemDiscount > (SELECT AVG(LineItemDiscount) * 2 
                               FROM Discount2015_CTE);


-- 4

WITH ExpensiveCar_CTE (
                        MakeName, ModelName, SalePrice
                       ,Color, SaleDate
                       ,InvoiceNumber, CustomerName
                       )
AS
(
SELECT     MK.MakeName, MD.ModelName, SD.SalePrice
           ,ST.Color, SA.SaleDate
           ,SA.InvoiceNumber, CU.CustomerName
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
JOIN       customer CU ON SA.CustomerID = CU.CustomerID
WHERE      YEAR(SaleDate) = 2015
)
SELECT     SLS.MakeName, SLS.ModelName, SLS.Color, SLS.CustomerName
           ,SLS.SalePrice, SLS.SaleDate, SLS.InvoiceNumber
FROM       ExpensiveCar_CTE SLS
           JOIN (
                  SELECT    MakeName
                           ,MAX(SalePrice) AS MaxSalePrice
                  FROM     ExpensiveCar_CTE
                  GROUP BY MakeName
                 ) MX
           ON SLS.MakeName = MX.MakeName
           AND SLS.SalePrice = MX.MaxSalePrice;


-- 5

WITH SalesBudget_CTE
AS
(
SELECT     BudgetValue, BudgetDetail, Year, Month
FROM       budget
WHERE      BudgetElement = 'country'
)

SELECT     CO.CountryName
           ,YEAR(SA.SaleDate) AS YearOfSale
           ,MONTH(SA.SaleDate) AS MonthOfSale
           ,SUM(SD.SalePrice) AS SalePrice
           ,SUM(CTE.BudgetValue) AS BudgetValue
           ,SUM(CTE.BudgetValue) 
           - SUM(SD.SalePrice) AS DifferenceBudgetToSales
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
JOIN       customer CU ON SA.CustomerID = CU.CustomerID
JOIN       country CO ON CU.country = CO.CountryISO2
JOIN       SalesBudget_CTE CTE
           ON CTE.BudgetDetail = CO.CountryName
           AND CTE.Year = YEAR(SA.SaleDate)
           AND CTE.Month = MONTH(SA.SaleDate)
GROUP BY   CO.CountryName, YEAR(SA.SaleDate), MONTH(SA.SaleDate);


-- 6

WITH ColorSales_CTE
AS
(SELECT     Color
           ,SUM(SD.SalePrice) AS TotalSalesValue
FROM       stock ST 
JOIN       salesdetails SD  ON ST.StockCode = SD.StockID 
JOIN       sales AS SA USING(SalesID)

WHERE      YEAR(SA.SaleDate) = 2016

GROUP BY   Color
)
,
ColorBudget_CTE
AS
(
SELECT  BudgetDetail AS Color, BudgetValue
FROM    Budget
WHERE   BudgetElement = 'Color'
            AND YEAR = 2016
)

SELECT      BDG.Color, SLS.TotalSalesValue, BDG.BudgetValue
            ,(SLS.TotalSalesValue - BDG.BudgetValue) AS BudgetDelta
FROM        ColorSales_CTE SLS
JOIN        ColorBudget_CTE BDG
            ON SLS.Color = BDG.Color;

-- 7


WITH Outer2015Sales_CTE
AS
(
SELECT     MK.MakeName
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      YEAR(SaleDate) = 2015
)
,
CoreSales_CTE (MakeName, NumberOfSales)
AS
(
SELECT     MakeName
           ,COUNT(*)
FROM       Outer2015Sales_CTE
GROUP BY   MakeName
HAVING     COUNT(*) >= 2
)
SELECT      CTE.MakeName, MK2.MakeCountry AS CountryCode
           ,NumberOfSales 
FROM       CoreSales_CTE CTE
JOIN       make MK2
           ON CTE.MakeName = MK2.MakeName;


-- 8

WITH Initial2017Sales_CTE
AS
(
SELECT     SD.SalePrice, CU.CustomerName, SA.SaleDate
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
JOIN       customer AS CU USING(CustomerID)
WHERE      YEAR(SaleDate) = 2017
)
,
AggregateSales_CTE (CustomerName, SalesForCustomer)
AS
(
SELECT     CustomerName, SUM(SalePrice)
FROM       Initial2017Sales_CTE
GROUP BY   CustomerName
)
,
TotalSales_CTE (TotalSalePrice)
AS
(
SELECT     SUM(SalePrice)
FROM       Initial2017Sales_CTE
)

SELECT
 IT.CustomerName
,IT.SalePrice
, IT.SaleDate
,CONCAT(FORMAT((IT.SalePrice / AG.SalesForCustomer * 100), 2) , ' %')
           AS SaleAsPercentageForCustomer
,CONCAT(FORMAT((IT.SalePrice / TT.TotalSalePrice * 100), 2), ' %') 
           AS SalePercentOverall
           FROM       Initial2017Sales_CTE IT
           JOIN       AggregateSales_CTE AG
           ON         IT.CustomerName = AG.CustomerName
           CROSS JOIN TotalSales_CTE TT
 ORDER BY  IT.CustomerName, IT.SaleDate;












