/* Chapter 21 */


-- 1

SELECT   Color
         ,SUM(CASE WHEN YEAR(SaleDate) = 2015 THEN SD.SalePrice 
                   ELSE NULL END) AS '2015'
         ,SUM(CASE WHEN YEAR(SaleDate) = 2016 THEN SD.SalePrice 
                   ELSE NULL END) AS '2016'
         ,SUM(CASE WHEN YEAR(SaleDate) = 2017 THEN SD.SalePrice 
                   ELSE NULL END) AS '2017'
         ,SUM(CASE WHEN YEAR(SaleDate) = 2018 THEN SD.SalePrice 
                   ELSE NULL END) AS '2018'
FROM     stock ST
JOIN     salesdetails SD 
         ON ST.StockCode = SD.StockID
JOIN     sales SA 
         ON SA.SalesID = SD.SalesID
GROUP BY Color;


-- 2

WITH PivotDataSource_CTE (Make, Model, Color)
AS
(
SELECT   MK.MakeName, MD.ModelName, ST.Color
FROM     make MK 
JOIN     model MD ON MK.MakeID = MD.MakeID
JOIN     stock ST ON ST.ModelID = MD.ModelID
)

SELECT   make, model
         ,COUNT(CASE WHEN Color = 'Black' THEN Color 
                     ELSE NULL END) 
AS 'Black'
         ,COUNT(CASE WHEN Color = 'Blue' THEN Color 
                     ELSE NULL END) 
AS 'Blue'
         ,COUNT(CASE WHEN Color = 'British Racing Green' 
                 THEN Color ELSE NULL END) AS 'British Racing Green'
         ,COUNT(CASE WHEN Color = 'Canary Yellow' THEN Color 
                     ELSE NULL END) AS 'Canary Yellow'
         ,COUNT(CASE WHEN Color = 'Dark Purple' THEN Color 
                     ELSE NULL END) AS 'Dark Purple'         
         ,COUNT(CASE WHEN Color = 'Green' THEN Color 
                     ELSE NULL END) AS 'Green'
         ,COUNT(CASE WHEN Color = 'Night Blue' THEN Color 
                     ELSE NULL END) AS 'Night Blue'
         ,COUNT(CASE WHEN Color = 'Pink' THEN Color 
                     ELSE NULL END)
                                    AS 'Pink'
         ,COUNT(CASE WHEN Color = 'Red' THEN Color 
                     ELSE NULL END) AS 'Red'
         ,COUNT(CASE WHEN Color = 'Silver' THEN Color 
                     ELSE NULL END) AS 'Silver'
FROM     PivotDataSource_CTE
GROUP BY Make, Model;


-- 3

SELECT     Color, YearOfSale
           ,CASE CJ.YearOfSale
               WHEN '2015' THEN '2015'
               WHEN '2016' THEN '2016'
               WHEN '2017' THEN '2017'
               WHEN '2018' THEN '2018'
            END AS SalesValue
FROM       pivottable
CROSS JOIN
          (
           SELECT '2015' AS YearOfSale
           UNION
           SELECT '2016' AS YearOfSale
           UNION
           SELECT '2017' AS YearOfSale
           UNION
           SELECT '2018' AS YearOfSale
           ) CJ
ORDER BY    Color, YearOfSale;


-- 4

SELECT      MakeName, Color, SUM(Cost) AS Cost
FROM        make MK 
JOIN        model MD ON MK.MakeID = MD.MakeID
JOIN        stock ST ON ST.ModelID = MD.ModelID
GROUP BY    MakeName, Color WITH ROLLUP;


-- 5

WITH GroupedSource_CTE
AS
(
SELECT 
MakeName
,Color
,Count(*) AS NumberOfCarsBought

FROM        make MK 
            JOIN model MD ON MK.MakeID = MD.MakeID
            JOIN stock ST ON ST.ModelID = MD.ModelID
WHERE       MakeName IS NOT NULL OR Color IS NOT NULL
GROUP BY    MakeName, Color WITH ROLLUP
)

SELECT AggregationType
,Category
,NumberOfCarsBought

FROM
(
SELECT   'GrandTotal' AS AggregationType, NULL AS Category
         ,NumberOfCarsBought, 1 AS SortOrder
FROM     GroupedSource_CTE
WHERE    MakeName IS NULL and Color IS NULL
UNION
SELECT   'make Subtotals', MakeName, NumberOfCarsBought , 2
FROM     GroupedSource_CTE
WHERE    MakeName IS NOT NULL and Color IS NULL 
) SQ
ORDER BY SortOrder, NumberOfCarsBought DESC;


-- 6

WITH RECURSIVE HierarchyList_CTE
AS
(
SELECT    StaffID, StaffName, Department, ManagerID, 1 AS StaffLevel
FROM      staff
WHERE     ManagerID IS NULL
UNION ALL
SELECT    ST.StaffID, ST.StaffName
          ,ST.Department, ST.ManagerID, StaffLevel + 1
FROM      staff ST
JOIN      HierarchyList_CTE CTE
          ON ST.ManagerID = CTE.StaffID
)

SELECT         STF.Department
              ,STF.StaffName
              ,CTE.StaffName AS ManagerName
              ,CTE.StaffLevel 
FROM          HierarchyList_CTE CTE
JOIN          staff STF
              ON STF.ManagerID = CTE.StaffID;


-- 7

WITH RECURSIVE HierarchyList_CTE
AS
(
SELECT    StaffID, StaffName, Department, ManagerID, 1 AS StaffLevel
FROM      staff
WHERE     ManagerID IS NULL
UNION ALL
SELECT         ST.StaffID, ST.StaffName
              ,ST.Department, ST.ManagerID, StaffLevel + 1
FROM          staff ST
JOIN          HierarchyList_CTE CTE
              ON ST.ManagerID = CTE.StaffID
)

SELECT         STF.Department
              ,CONCAT(SPACE(StaffLevel * 2)
                   ,STF.StaffName)
              AS StaffMember
              ,CTE.StaffName AS ManagerName
              ,CTE.StaffLevel 
FROM          HierarchyList_CTE CTE
JOIN          staff STF
              ON STF.ManagerID = CTE.StaffID
ORDER BY      Department, StaffLevel, CTE.StaffName;


-- 8

SELECT     REPLACE(CustomerName, 'Ltd', 'Limited') 
                  AS NoAcronymName
FROM       customer
WHERE      LOWER(CustomerName) LIKE '%ltd%';


-- 9

SELECT 
INSERT(StockCode,1,23,'PrestigeCars-') AS NewStockCode
,Cost
,RepairsCost
,PartsCost
,TransportInCost  
FROM stock;


-- 10

WITH ConcatenateSource_CTE (MakeModel, Color)
AS
(
SELECT DISTINCT  CONCAT(MakeName, ' ', ModelName), Color
FROM             make MK 
JOIN             model AS MD USING(MakeID)
JOIN             stock AS ST USING(ModelID)
JOIN              salesdetails SD ON SD.SalesDetailsID = ST.StockCode)

SELECT   MakeModel, GROUP_CONCAT(DISTINCT Color) AS ColorList
FROM     ConcatenateSource_CTE
GROUP BY MakeModel;


-- 11

SELECT       MK.MakeName, MD.ModelName
             ,TRUNCATE(ST.Cost, 0), DATE(SA.SaleDate)
INTO OUTFILE 'C:\\MariaDBQueriesSampleData\\SalesList.txt'
             FIELDS TERMINATED BY ','
             LINES TERMINATED BY '\r\n'
FROM         make AS MK 
JOIN         model AS MD USING(MakeID)
JOIN         stock AS ST USING(ModelID)
JOIN         salesdetails SD ON ST.StockCode = SD.StockID
JOIN         sales AS SA USING(SalesID)
ORDER BY     MK.MakeName, MD.ModelName;


-- 12

SELECT       'MakeName', 'ModelName', 'Cost', 'SaleDate'
UNION ALL
SELECT       MK.MakeName, MD.ModelName
             ,TRUNCATE(ST.Cost, 0), DATE(SA.SaleDate)
INTO OUTFILE 'C:\\MariaDBQueriesSampleData\\SalesList.txt'
             FIELDS TERMINATED BY ','
             LINES TERMINATED BY '\r\n'
FROM         make AS MK 
JOIN         model AS MD USING(MakeID)
JOIN         stock AS ST USING(ModelID)
JOIN         salesdetails SD ON ST.StockCode = SD.StockID
JOIN         sales AS SA USING(SalesID)
WHERE        MK.MakeName = 'Bentley';


-- 13

SELECT       RPAD('MakeName', 35, ' ')
             ,RPAD('ModelName', 35, ' ')
             ,RPAD('Cost', 15, ' ')
             ,RPAD('SaleDate', 15, ' ')
UNION ALL
SELECT       RPAD(MK.MakeName, 35, ' ')
             ,RPAD(MD.ModelName, 35, ' ')
             ,LPAD(TRUNCATE(ST.Cost, 0), 15, ' ')
             ,LPAD(DATE(SA.SaleDate), 15, ' ')
INTO OUTFILE 'C:\\MariaDBQueriesSampleData\\SalesListFixed.txt'
             LINES TERMINATED BY '\r\n'
FROM         make AS MK 
JOIN         model AS MD USING(MakeID)
JOIN         stock AS ST USING(ModelID)
JOIN         salesdetails SD ON ST.StockCode = SD.StockID
JOIN         Sales AS SA USING(SalesID);  


-- 14

SELECT       TRIM(MK.MakeName), TRIM(MD.ModelName)
             ,TRIM(TRUNCATE(ST.Cost, 0)), TRIM(DATE(SA.SaleDate))
INTO OUTFILE 'C:\\MariaDBQueriesSampleData\\SalesList.txt'
             FIELDS TERMINATED BY ','
             LINES TERMINATED BY '\r\n'
FROM         make AS MK 
JOIN         model AS MD USING(MakeID)
JOIN         stock AS ST USING(ModelID)
JOIN         salesdetails SD ON ST.StockCode = SD.StockID
JOIN         sales AS SA USING(SalesID)
ORDER BY     MK.MakeName, MD.ModelName;




