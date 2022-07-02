/* Chapter 12 */


-- 1


SELECT      CO.CountryName
           ,COUNT(SD.SalesDetailsID) AS CarsSold
           ,(SELECT COUNT(SalesDetailsID)
             FROM salesdetails) AS SalesTotal
FROM       salesdetails SD 
JOIN       sales AS SA USING (SalesID)
JOIN       customer CU USING (CustomerID)
JOIN       country CO ON CU.country = CO.CountryISO2
GROUP BY   CO.CountryName;


-- 2

SELECT     MK.MakeName
           ,SUM(SD.SalePrice) AS SalePrice
           ,SUM(SD.SalePrice) / (SELECT SUM(SalePrice) 
                              FROM SalesDetails) AS SalesRatio
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
GROUP BY   MK.MakeName;


-- 3

SELECT     ST.Color
FROM       stock AS ST 	
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
WHERE      SD.SalePrice = (SELECT MAX(SalePrice) 
                               FROM salesdetails);


-- 4


SELECT     MK.MakeName, MD.ModelName, ST.RepairsCost
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
WHERE      ST.RepairsCost > 3 * (SELECT AVG(RepairsCost) 
                                 FROM Stock);

-- 5


SELECT     MK.MakeName, MD.ModelName, ST.Cost, ST.RepairsCost
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
WHERE      ST.RepairsCost BETWEEN
                        (SELECT AVG(RepairsCost) FROM stock) * 0.9
                          AND
                        (SELECT AVG(RepairsCost) FROM stock) * 1.1
ORDER BY   MK.MakeName, MD.ModelName, ST.Cost;


-- 6

SELECT     MK.MakeName, AVG(SD.SalePrice) AS AverageUpperSalePrice
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
GROUP BY   MK.MakeName
HAVING     AVG(SD.SalePrice) > 2 * (SELECT AVG(SalePrice)
                                   FROM   salesdetails);



-- 7

SELECT     MK.MakeName, MD.ModelName, SD.SalePrice
           ,ST.Color, YEAR(SA.SaleDate) AS YearOfSale
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      Color IN (SELECT     DISTINCT STX.Color
                     FROM       stock AS STX
                     JOIN       salesdetails AS SDX 
                                ON STX.StockCode = SDX.StockID
                     JOIN       sales AS SAX USING(SalesID)
                     WHERE      YEAR(SAX.SaleDate) = 2015
                     )
ORDER BY   YearOfSale DESC, MK.MakeName
            ,MD.ModelName, SD.SalePrice DESC;


-- 8


SELECT     MK.MakeName, MD.ModelName, SD.SalePrice
           ,ST.Color, YEAR(SA.SaleDate) AS YearOfSale
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      Color NOT IN (SELECT     DISTINCT ST.Color
                         FROM       model AS MD
                         JOIN       stock AS ST USING(ModelID)
                         JOIN       salesdetails SD 
                                    ON ST.StockCode = SD.StockID
                         JOIN       sales AS SA USING(SalesID)
                         WHERE      YEAR(SA.SaleDate) = 2015
                         )
ORDER BY   YearOfSale DESC, MK.MakeName, MD.ModelName
           ,SD.SalePrice DESC;



-- 9

SELECT     MK.MakeName, MD.ModelName, SD.SalePrice 
FROM       make AS MK
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      Color IN (SELECT     ST.Color
                     FROM       model AS MD
                     JOIN       stock AS ST USING(ModelID)
                     JOIN       salesdetails SD 
                                ON ST.StockCode = SD.StockID
                     WHERE      SD.SalePrice = 
                                      (
                                       SELECT  MAX(SD.SalePrice) 
                                       FROM    salesdetails SD
                                       JOIN    sales SA
                                               USING(SalesID)
                                      )
                     )
ORDER BY   SD.SalePrice DESC
LIMIT 5;


-- 10

SELECT     MK.MakeName
           ,SUM(SD.SalePrice) AS SalePrice
           ,SUM(SD.SalePrice) / 
                        (SELECT     SUM(SD.SalePrice) 
                         FROM       SalesDetails SD 
                         JOIN       Sales AS SA USING(SalesID)
                         WHERE      YEAR(SaleDate) = 2015
                        ) AS SalesRatio
FROM       make AS MK	
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      YEAR(SA.SaleDate) = 2015
GROUP BY   MK.MakeName;


-- 11

SELECT      MK.MakeName
           ,MD.ModelName
           ,SD.SalePrice AS ThisYearsSalePrice
           ,SD.SalePrice	
             - (SELECT     AVG(SD.SalePrice) 
                FROM       stock ST
                JOIN       salesdetails SD 
                           ON ST.StockCode = SD.StockID
                JOIN       sales AS SA USING(SalesID)
                WHERE      YEAR(SaleDate) = 2015) 
                           AS DeltaToLastYearAverage
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      YEAR(SA.SaleDate) = 2016;














