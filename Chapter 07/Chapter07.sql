/* CHAPTER 7 */


-- 1

SELECT       SUM(Cost) AS TotalCost 
FROM         stock;


-- 2

SELECT        SUM(ST.Cost) AS TotalCost
             ,SUM(SD.SalePrice) AS TotalSales 
             ,SUM(SD.SalePrice) - SUM(ST.Cost) AS GrossProfit
FROM         stock ST	
JOIN         salesdetails SD
             ON ST.StockCode = SD.StockID;


-- 3

SELECT     MD.ModelName, SUM(ST.Cost) AS TotalCost
FROM       stock ST
JOIN       model MD USING(ModelID)
GROUP BY   MD.ModelName
ORDER BY   MD.ModelName;


-- 4

SELECT     MK.MakeName, MD.ModelName, SUM(ST.Cost) AS TotalCost
FROM       stock ST
JOIN       model MD USING(ModelID)
JOIN       make AS MK USING(MakeID)
GROUP BY   MK.MakeName, MD.ModelName
ORDER BY   MK.MakeName, MD.ModelName;


-- 5

SELECT     MK.MakeName, MD.ModelName
           ,AVG(ST.Cost) AS AverageCost 
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
GROUP BY   MK.MakeName, MD.ModelName
ORDER BY   MK.MakeName, MD.ModelName;


-- 6

SELECT       MK.MakeName, MD.ModelName 
            ,COUNT(SD.SalesDetailsID) AS NumberofCarsSold
FROM        make AS MK 
JOIN        model AS MD USING(MakeID)
JOIN        stock AS ST USING(ModelID)
JOIN        salesdetails SD ON ST.StockCode = SD.StockID
GROUP BY    MK.MakeName, MD.ModelName
ORDER BY    MK.MakeName, MD.ModelName;


-- 7

SELECT  COUNT(DISTINCT CountryName) AS CountriesWithSales
FROM    SalesByCountry;


-- 8

SELECT       MD.ModelName
            ,MAX(SD.SalePrice) AS TopSalePrice
            ,MIN(SD.SalePrice) AS BottomSalePrice
FROM        model AS MD
JOIN        stock AS ST USING(ModelID)
JOIN        salesdetails SD ON ST.StockCode = SD.StockID
GROUP BY    MD.ModelName
ORDER BY    MD.ModelName;


-- 9

SELECT     MK.MakeName, COUNT(SD.SalePrice) AS RedCarsSold
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
WHERE      ST.Color = 'Red'
GROUP BY   MK.MakeName
ORDER BY   MK.MakeName;


-- 10

SELECT     CountryName, COUNT(SalesDetailsID) AS NumberofCarsSold
FROM       salesbycountry
GROUP BY   CountryName	
HAVING     COUNT(SalesDetailsID) > 50;


-- 11

SELECT     CU.CustomerName, COUNT(SD.SalesDetailsID) 
               AS NumberofCarsSold
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA ON SA.SalesID = SD.SalesID
JOIN       customer CU ON SA.CustomerID = CU.CustomerID
WHERE      (SD.SalePrice 
            - (
                ST.Cost + IFNULL(ST.RepairsCost,0) + ST.PartsCost 
                + ST.TransportInCost)
               ) > 5000
GROUP BY   CU.CustomerName
HAVING     COUNT(SD.SalesDetailsID) >= 3
ORDER BY   CU.CustomerName;


-- 12

SELECT      MK.MakeName
FROM        make AS MK 
JOIN        model AS MD USING(MakeID)
JOIN        stock AS ST USING(ModelID)
JOIN        salesdetails SD ON ST.StockCode = SD.StockID
GROUP BY    MK.MakeName
ORDER BY    SUM(SD.SalePrice) DESC
            LIMIT 3;










