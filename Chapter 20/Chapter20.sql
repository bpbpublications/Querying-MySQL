/* Chapter 20 */


-- 1

SELECT     MK.MakeName, SUM(SD.SalePrice) AS CumulativeSalesYTD
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA USING(SalesID)
WHERE      SA.SaleDate BETWEEN 
                STR_TO_DATE(YEAR(CURDATE())-1-1, '%Y-%d-%m')
                AND CURDATE()
GROUP BY   MK.MakeName
ORDER BY   MK.MakeName ASC;


-- 2

SELECT     MakeName, SUM(SD.SalePrice) AS CumulativeSalesMTD
FROM       make AS MK JOIN model AS MD 
           ON MK.MakeID = MD.MakeID
JOIN       stock AS ST ON ST.ModelID = MD.ModelID
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA ON SA.SalesID = SD.SalesID
WHERE      SA.SaleDate 
           BETWEEN 
           DATE_SUB(CURDATE(), INTERVAL DAYOFMONTH(CURDATE()) -1 DAY)
           AND CURDATE() 
GROUP BY   MakeName
ORDER BY   MakeName ASC;


-- 3

SELECT     MakeName, SUM(SD.SalePrice) AS CumulativeSalesQTD
FROM       make AS MK JOIN model AS MD 
           ON MK.MakeID = MD.MakeID
JOIN       stock AS ST ON ST.ModelID = MD.ModelID
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA ON SA.SalesID = SD.SalesID
WHERE      QUARTER(SA.SaleDate) = QUARTER(CURDATE()) 
           AND YEAR(SA.SaleDate) = YEAR(CURDATE())
GROUP BY   MakeName
ORDER BY   MakeName ASC;


-- 4

SELECT     MakeName, SUM(Cost) AS TotalCost
FROM       make AS MK JOIN model AS MD 
           ON MK.MakeID = MD.MakeID
JOIN       stock AS ST ON ST.ModelID = MD.ModelID
WHERE      YEAR(DateBought) = YEAR(CURDATE() - INTERVAL 1 MONTH)
           AND
           MONTH(DateBought) = MONTH(CURDATE() - INTERVAL 1 MONTH)
GROUP BY   MakeName;


-- 5

SELECT     ST.Color, AVG(SA.TotalSalePrice) AS AverageMonthSales
           ,AveragePreviousMonthSales
FROM       make AS MK 
JOIN       model AS MD ON MK.MakeID = MD.MakeID
JOIN       stock AS ST ON ST.ModelID = MD.ModelID
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
JOIN       sales AS SA ON SA.SalesID = SD.SalesID
LEFT OUTER JOIN 
           (
            SELECT     Color, AVG(SA.TotalSalePrice) 
                       AS AveragePreviousMonthSales
            FROM       make AS MK 
            JOIN       model AS MD 
                       ON MK.MakeID = MD.MakeID
            JOIN       stock AS ST 
                       ON ST.ModelID = MD.ModelID
            JOIN       salesdetails SD 
                       ON ST.StockCode = SD.StockID
            JOIN       sales AS SA 
                       ON SA.SalesID = SD.SalesID
            WHERE      YEAR(SA.SaleDate) = YEAR(CURDATE()) - 1
                       AND MONTH(SA.SaleDate) = MONTH(CURDATE())
            GROUP BY   Color
           ) SQ   
           ON SQ.Color = ST.Color
WHERE      YEAR(SA.SaleDate) = YEAR(CURDATE())
           AND MONTH(SA.SaleDate) = MONTH(CURDATE())
GROUP BY   St.Color;


-- 6

WITH TallyTable_CTE
AS
(
SELECT     ROW_NUMBER() OVER (ORDER BY StockCode) AS ID
FROM       stock
ORDER BY   ID
LIMIT      366
)
,DateList_CTE
AS
(
SELECT       DATE_ADD(STR_TO_DATE('2016-12-31', '%Y-%m-%d')
               ,INTERVAL ID DAY)
             AS WeekdayDate
             ,DAYNAME(DATE_ADD(STR_TO_DATE('2016-12-31', '%Y-%m-%d')
               ,INTERVAL ID DAY)) 
             AS WeekdayName
FROM         TallyTable_CTE
WHERE        DAYOFWEEK(DATE_ADD(STR_TO_DATE('2016-12-31', '%Y-%m-%d')
               ,INTERVAL ID DAY))
             BETWEEN 2 AND 6
             AND 
             DATE_ADD(STR_TO_DATE('2016-12-31', '%Y-%m-%d')
                ,INTERVAL ID DAY) 
             <= '20171231'
)
SELECT        CTE.WeekdayDate
             ,CTE.WeekdayName
             ,SUM(SLS.SalePrice) AS TotalDailySales
FROM         salesbycountry SLS
JOIN         DateList_CTE CTE
             ON CTE.WeekdayDate = DATE(SLS.SaleDate)
GROUP BY      CTE.WeekdayDate
ORDER BY     CTE.WeekdayDate;


-- 7

WITH TallyTable_CTE
AS
(
SELECT     ROW_NUMBER() OVER (ORDER BY StockCode) AS ID
FROM       stock
ORDER BY   ID
LIMIT      90
)
,WeekendList_CTE
AS
(
SELECT       DATE_ADD('20180301', INTERVAL ID - 1 DAY) AS WeekdayDate
FROM         TallyTable_CTE
WHERE        DAYOFWEEK(DATE_ADD('20180301', INTERVAL ID - 1 DAY))
                  IN (1,7)
             AND ID <= DATEDIFF('20180430', '20180301')
)

SELECT    COUNT(*) AS WeekendDays FROM WeekendList_CTE;


-- 8


WITH TallyTable_CTE
AS
(
SELECT     ROW_NUMBER() OVER (ORDER BY StockCode) AS ID
FROM       stock
ORDER BY   ID
LIMIT      12
)
,LastDayOfMonth_CTE
AS
(
SELECT       LAST_DAY(CONCAT('2016-', ID, '-01')) AS LastDayDate
FROM         TallyTable_CTE
)

SELECT        CTE.LastDayDate
             ,SUM(SLS.SalePrice) AS TotalDailySales
FROM         salesbycountry SLS
JOIN         LastDayOfMonth_CTE CTE
             ON CTE.LastDayDate = DATE(SLS.SaleDate)
GROUP BY     CTE.LastDayDate
ORDER BY     CTE.LastDayDate;



-- 9

WITH TallyTable_CTE
AS
(
SELECT     ROW_NUMBER() OVER (ORDER BY StockCode) AS ID
FROM       stock
ORDER BY   ID
LIMIT      12
)
,LastDayOfMonth_CTE
AS
(
SELECT       LAST_DAY(CONCAT('2018-', ID, '-01')) AS MonthEndDate
             ,WEEKDAY(LAST_DAY(CONCAT('2018-', ID, '-01'))) + 1
             AS MonthEndDay
FROM         TallyTable_CTE
)

SELECT       MonthEndDate
             ,CASE
                 WHEN MonthEndDay >= 5 THEN DATE_ADD(MonthEndDate
                      ,INTERVAL 5 - MonthEndDay DAY) 
                 ELSE DATE_SUB(MonthEndDate
             ,INTERVAL (2 + MonthEndDay) DAY)
             END AS LastFridayOfMonth
FROM         LastDayOfMonth_CTE;


-- 10

SELECT       ST.StockCode
            ,ST.DateBought
            ,SLS.SaleDate
            ,TIMESTAMPDIFF(YEAR, ST.DateBought
              ,IFNULL(SLS.SaleDate, CURDATE())) AS Years
            ,TIMESTAMPDIFF(MONTH, ST.DateBought
              ,IFNULL(SLS.SaleDate, CURDATE())) AS Months
            ,TIMESTAMPDIFF(DAY, ST.DateBought
              ,IFNULL(SLS.SaleDate, CURDATE())) AS Days
FROM        stock ST
LEFT JOIN   (
            SELECT SA.SaleDate
                   ,SD.StockID                   
            FROM   salesdetails SD
            JOIN   sales SA USING(SalesID)
            ) SLS
            ON ST.StockCode = SLS.StockID 
ORDER BY    Years DESC, Months DESC, Days DESC; 


-- 11

SELECT       ST.DateBought
            ,SA.SaleDate
            ,CONCAT(MK.MakeName, '-', MD.ModelName) 
                      AS MakeAndModel
            ,TIMEDIFF(SA.SaleDate, CAST(ST.DateBought 
                        AS DATETIME)) 
               AS TimeDifference
            ,HOUR(TIMEDIFF(SA.SaleDate, CAST(ST.DateBought 
               AS DATETIME))) AS Hours
            ,MINUTE(TIMEDIFF(SA.SaleDate, CAST(ST.DateBought 
               AS DATETIME))) AS Minutes
            ,SECOND(TIMEDIFF(SA.SaleDate, CAST(ST.DateBought 
               AS DATETIME))) AS Seconds
            ,CONCAT(FLOOR(HOUR(TIMEDIFF(SA.SaleDate
                    ,CAST(ST.DateBought AS DATETIME))) / 24) 
                    ,' Days - '
                    ,HOUR(TIMEDIFF(SA.SaleDate, CAST(ST.DateBought 
                AS DATETIME))) MOD 24
                    ,' Hours')
                 AS DaysAndHours
FROM         stock ST
JOIN         model MD
             ON ST.ModelID = MD.ModelID 
JOIN         make MK
             ON MD.MakeID = MK.MakeID 
JOIN         salesdetails SD
             ON ST.StockCode = SD.StockID 
JOIN         sales SA
             ON SD.SalesID = SA.SalesID 
WHERE        YEAR(SA.SaleDate) = 2017
ORDER BY     Hours DESC, Minutes DESC, Seconds DESC;


-- 12

SELECT     MakeName, ModelName, SalePrice
          ,DATE_FORMAT(SaleDate, '%H:%i') AS TimeOfDaySold
FROM      salesbycountry
WHERE     YEAR(SaleDate) = 2017
ORDER BY  TimeOfDaySold;


-- 13

SELECT
            CONCAT(HourOfDay, '-', HourOfDay + 1) AS HourBand
            ,SUM(SalePrice) AS SalesByHourBand
FROM
    (
     SELECT     SalePrice
               ,HOUR(SaleDate) AS HourOfDay
     FROM      salesbycountry
     WHERE     YEAR(SaleDate) = 2017
    ) A
GROUP BY   HourOfDay
ORDER BY   HourOfDay;

-- 14


SELECT      QuarterOfHour 
           ,SUM(SalePrice) AS SalesByQuarterHourBand
FROM
    (
     SELECT     SalePrice
               ,FLOOR((MINUTE(SaleDate) / 15) + 1) AS QuarterOfHour
     FROM      salesbycountry
     WHERE     YEAR(SaleDate) = 2017
    ) A
GROUP BY   QuarterOfHour
ORDER BY   QuarterOfHour;



