/* CHAPTER 6 */


-- 1

SELECT   MakeName, ModelName
                     ,Cost + RepairsCost + PartsCost  + TransportInCost 
         AS TotalCost
FROM     salesbycountry
ORDER BY MakeName, ModelName;


-- 3

SELECT   MakeName, ModelName
         ,SalePrice - (Cost + RepairsCost + PartsCost + TransportInCost) 
         AS GrossMargin
FROM     SalesByCountry;


-- 4

SELECT   (SalePrice - 
           (Cost + RepairsCost + PartsCost + TransportInCost)) 
           / SalePrice AS RatioOfCostsToSales
FROM     SalesByCountry;


-- 5

SELECT   (SalePrice - (Cost + RepairsCost + PartsCost 
                       + TransportInCost)) 
         / NULLIF(SalePrice, 0) AS RatioOfCostsToSales
FROM     SalesByCountry;


-- 6

SELECT    MakeName, ModelName
          ,(SalePrice * 1.05) 
          - (Cost + RepairsCost + PartsCost + TransportInCost) 
             AS ImprovedSalesMargins
FROM      salesbycountry
ORDER BY  MakeName, ModelName;


-- 7

SELECT    MK.MakeName
          ,(SD.SalePrice - (ST.Cost + ST.RepairsCost 
                            + ST.PartsCost + ST.TransportInCost)) 
          / NULLIF(SD.SalePrice, 0) AS Profitability 
FROM      make AS MK
JOIN      model AS MD ON MK.MakeID = MD.MakeID
JOIN      stock AS ST ON ST.ModelID = MD.ModelID
JOIN      salesdetails SD ON ST.StockCode = SD.StockID
ORDER BY  Profitability DESC
          LIMIT 50;


-- 8

SELECT   MK.MakeName, MD.ModelName
         ,ST.Cost + ST.RepairsCost 
         + IFNULL(ST.PartsCost, 0) + ST.TransportInCost 
         AS TotalCost
FROM     make AS MK
JOIN     model AS MD USING(MakeID)
JOIN     stock AS ST USING(ModelID)
JOIN     SalesDetails SD ON ST.StockCode = SD.StockID;


-- 9

SELECT     DISTINCT MK.MakeName, MD.ModelName, SD.SalePrice
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
WHERE      SD.SalePrice - 
             (ST.Cost + ST.RepairsCost + IFNULL(ST.PartsCost, 0)
              + ST.TransportInCost) > 5000
ORDER BY   MK.MakeName, MD.ModelName, SD.SalePrice DESC;


-- 10

SELECT     DISTINCT MK.MakeName, MD.ModelName
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
WHERE      (ST.Color = 'Red' AND SD.LineItemDiscount >= 1000 
           AND (SD.SalePrice - (ST.Cost + ST.RepairsCost 
                                + IFNULL(ST.PartsCost, 0) 
                                + ST.TransportInCost)) > 5000) 
           OR (ST.PartsCost > 500 AND ST.RepairsCost > 500)
ORDER BY   MK.MakeName, MD.ModelName;



















