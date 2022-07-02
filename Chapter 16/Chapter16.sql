/* Chapter 16 */


-- 1

SELECT  MakeName, ModelName, CustomerName, CountryName, Cost
        ,RepairsCost, PartsCost, TransportInCost
        ,SalePrice, SaleDate
FROM    sales2015
UNION 	
SELECT  MakeName, ModelName, CustomerName, CountryName, Cost
        ,RepairsCost, PartsCost, TransportInCost
        ,SalePrice, SaleDate
FROM    sales2016
UNION
SELECT  MakeName, ModelName, CustomerName, CountryName, Cost
        ,RepairsCost, PartsCost, TransportInCost
        ,SalePrice, SaleDate
FROM    sales2017;


-- 2

SELECT DISTINCT MakeName, ModelName, CustomerName, CountryName
FROM            sales2015
JOIN            sales2016 
                USING(MakeName, ModelName
                       ,CustomerName, CountryName)
ORDER BY        MakeName, ModelName;


-- 3

SELECT DISTINCT TB1.MakeName
FROM
(
SELECT     MK.MakeName
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
WHERE      YEAR(DateBought) = 2015
) TB1
JOIN
(	
SELECT     MK.MakeName
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
WHERE      YEAR(DateBought) = 2016
) TB2
ON       TB1.MakeName = TB2.MakeName
ORDER BY TB1.MakeName;


-- 4


SELECT  MakeName, ModelName
FROM
(
   SELECT  MakeName, ModelName, CustomerName, CountryName, Cost
   ,RepairsCost, PartsCost, TransportInCost, SalePrice, SaleDate
   FROM    sales2015
   UNION 
   SELECT  MakeName, ModelName, CustomerName, CountryName, Cost
   ,RepairsCost, PartsCost, TransportInCost, SalePrice, SaleDate
   FROM    sales2016
   UNION
   SELECT  MakeName, ModelName, CustomerName, CountryName, Cost
   ,RepairsCost, PartsCost, TransportInCost, SalePrice, SaleDate
   FROM    sales2017
) SQ
WHERE   CountryName = 'Germany';


-- 5

SELECT DISTINCT TB1.MakeAndModel
FROM
(
  SELECT     CONCAT(MK.MakeName, '-', MD.ModelName) AS MakeAndModel
  FROM       make AS MK 
  JOIN       model AS MD USING(MakeID)
  JOIN       stock AS ST USING(ModelID)
  WHERE      YEAR(DateBought) = 2016
) TB1
LEFT JOIN
(
  SELECT     CONCAT(MK.MakeName, '-', MD.ModelName) AS MakeAndModel
  FROM       make AS MK 
  JOIN       model AS MD USING(MakeID)
  JOIN       stock AS ST USING(ModelID)
  WHERE      YEAR(DateBought) = 2015
) TB2
ON       TB1.MakeAndModel = TB2.MakeAndModel
WHERE    TB2.MakeAndModel IS NULL
ORDER BY TB1.MakeAndModel;


-- 6

WITH MakeAndModel_CTE
AS
(
SELECT DISTINCT TB1.MakeName, TB1.ModelName
FROM
(
SELECT     MakeName, ModelName
FROM       Sales2016
) TB1
LEFT JOIN
(
SELECT     MakeName, ModelName
FROM       Sales2017
) TB2
           USING (MakeName, ModelName)
WHERE      TB2.MakeName IS NULL
           AND TB2.ModelName IS NULL
)
SELECT  *
FROM    Sales2016
JOIN    MakeAndModel_CTE   
         USING (MakeName, ModelName);

-- 7

WITH IdenticalData_CTE
AS
(
SELECT DISTINCT MakeName, ModelName, CustomerName, CountryName
FROM            sales2015
JOIN            sales2016 
                USING(MakeName, ModelName, CustomerName, CountryName)
ORDER BY        MakeName, ModelName
)

SELECT  *, '2015 Data'
FROM    sales2015
JOIN    IdenticalData_CTE
         USING (MakeName, ModelName, CustomerName, CountryName)
UNION
SELECT  *, '2016 Data'
FROM    sales2016
JOIN    IdenticalData_CTE
         USING (MakeName, ModelName, CustomerName, CountryName);


-- 8

SELECT     MK.MakeName
FROM       Make AS MK 
INNER JOIN Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Stock AS ST ON ST.ModelID = MD.ModelID
WHERE      YEAR(DateBought) = 2015
INTERSECT
SELECT     MK.MakeName
FROM       Make AS MK 
INNER JOIN Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Stock AS ST ON ST.ModelID = MD.ModelID
WHERE      YEAR(DateBought) = 2016;


-- 9

SELECT     CONCAT(MK.MakeName, MD.ModelName) AS MakeModel
FROM       make AS MK 
JOIN       model AS MD ON MK.MakeID = MD.MakeID
JOIN       stock AS ST ON ST.ModelID = MD.ModelID
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA ON SA.SalesID = SD.SalesID
WHERE      YEAR(SaleDate) = 2015
EXCEPT
SELECT     CONCAT(MK.MakeName, MD.ModelName)
FROM       make AS MK 
JOIN       model AS MD ON MK.MakeID = MD.MakeID
JOIN       stock AS ST ON ST.ModelID = MD.ModelID
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA ON SA.SalesID = SD.SalesID
WHERE      YEAR(SaleDate) = 2016;












