/* CHAPTER 8 */


-- 1

SELECT     MK.MakeName, MD.ModelName, ST.DateBought
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)	
JOIN       stock AS ST USING(ModelID)
WHERE      ST.DateBought = 20150725;


-- 2

SELECT     MK.MakeName, MD.ModelName
FROM       make AS MK JOIN model AS MD 
           USING(MakeID)	
JOIN       stock AS ST ON ST.ModelID = MD.ModelID
WHERE      ST.DateBought BETWEEN '2018-07-15' AND '2018-08-31'
ORDER BY   MK.MakeName;


-- 3

SELECT STR_TO_DATE('2018-07-25','%Y-%m-%d');


-- 4

SELECT    
            MK.MakeName
           ,MD.ModelName 
           ,ST.DateBought
           ,SA.SaleDate
           ,DATEDIFF(SA.SaleDate, ST.DateBought) 
              AS DaysInStockBeforeSale
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails AS SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
ORDER BY   DaysInStockBeforeSale DESC;


-- 5

SELECT     SUM(ST.Cost) 
           / DATEDIFF('20151231', '20150701') 
             AS AverageDailyPurchase
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
WHERE      ST.DateBought BETWEEN '20150701' AND '20151231';


-- 6

SELECT     MK.MakeName, MD.ModelName
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA ON SA.SalesID = SD.SalesID
WHERE      DATE(SA.SaleDate) = '20160228';


-- 7

SELECT     MK.MakeName, MD.ModelName
           ,YEAR(SA.SaleDate) AS YearOfSale 
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails AS SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      YEAR(SA.SaleDate) = 2015
ORDER BY   MK.MakeName, MD.ModelName;


-- 8

SELECT DISTINCT MK.MakeName, MD.ModelName, YEAR(SA.SaleDate)
                AS YearOfSale
FROM            make AS MK 
JOIN            model AS MD USING(MakeID)
JOIN            stock AS ST USING(ModelID)
JOIN            salesdetails SD ON ST.StockCode = SD.StockID
JOIN            sales AS SA USING(SalesID)
WHERE           YEAR(SA.SaleDate) IN (2015, 2016)
ORDER BY        YEAR(SA.SaleDate), MakeName, ModelName;


-- 9

SELECT     MK.MakeName, MD.ModelName, SA.SaleDate
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      YEAR(SA.SaleDate) = 2015 
           AND MONTH(SA.SaleDate) = 7;


-- 10

SELECT     MK.MakeName, MD.ModelName
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      QUARTER(SA.SaleDate) = 3
           AND YEAR(SA.SaleDate) = 2015;


-- 11

SELECT     MK.MakeName, MD.ModelName
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      DAYOFWEEK(SA.SaleDate) = 6
           AND YEAR(SA.SaleDate) = 2016
ORDER BY   MK.MakeName, MD.ModelName;


-- 12

SELECT     MK.MakeName, MD.ModelName
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      WEEKOFYEAR(SA.SaleDate) = 26
           AND YEAR(SA.SaleDate) = 2017;


-- 13

SELECT      DAYOFWEEK(SA.SaleDate) AS DayOfWeek
           ,SUM(SD.SalePrice) AS Sales
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesDetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      YEAR(SA.SaleDate) = 2015
GROUP BY   DAYOFWEEK(SA.SaleDate)
ORDER BY   Sales DESC;


-- 14

SELECT      DAYNAME(SA.SaleDate) AS DayOfWeek
           ,SUM(SD.SalePrice) AS sales
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      YEAR(SA.SaleDate) = 2015
GROUP BY   DAYNAME(SA.SaleDate)
ORDER BY   WEEKDAY(SA.SaleDate);


-- 15

SELECT      DAYOFYEAR(SA.SaleDate) AS DayOfYear
           ,SUM(SD.SalePrice) AS TotalSales
           ,AVG(SD.SalePrice) AS AverageSales
FROM       salesdetails SD
JOIN       sales AS SA USING(SalesID)
GROUP BY   DAYOFYEAR(SA.SaleDate)
ORDER BY   DAYOFYEAR(SA.SaleDate);


-- 16

SELECT      DAY(SA.SaleDate) AS DayOfMonth
           ,SUM(SD.SalePrice) AS TotalSales
           ,AVG(SD.SalePrice) AS AverageSales
FROM       salesdetails SD
JOIN       sales AS SA USING(SalesID)
GROUP BY   DAY(SA.SaleDate)
ORDER BY   DAY(SA.SaleDate);


-- 17

SELECT      MONTHNAME(SA.SaleDate) AS Month
           ,COUNT(*) AS sales
FROM       salesdetails SD 
JOIN       sales AS SA USING(SalesID)
WHERE      YEAR(SA.SaleDate) = 2018
GROUP BY   MONTH(SA.SaleDate)
ORDER BY   MONTH(SA.SaleDate);


-- 18

SELECT     SUM(SD.SalePrice) AS CumulativeJaguarSales
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      SA.SaleDate BETWEEN DATE_SUB('20170725', INTERVAL 75 DAY) 
           AND '20170725'
           AND MK.MakeName = 'Jaguar';


-- 19

SELECT     MK.MakeName, SUM(SD.SalePrice) AS CumulativeSales
FROM       Make AS MK 
JOIN       Model AS MD USING(MakeID)
JOIN       Stock AS ST USING(ModelID)
JOIN       SalesDetails AS SD ON ST.StockCode = SD.StockID
JOIN       Sales AS SA USING(SalesID)
WHERE      CAST(SA.SaleDate AS DATE)  
           BETWEEN DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
           AND CURDATE() 
GROUP BY   MK.MakeName
ORDER BY   MK.MakeName ASC;


-- 20

SELECT CURDATE();