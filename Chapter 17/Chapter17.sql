/* Chapter 17 */


-- 1

SELECT       CustomerName
             ,CONCAT(FORMAT(  
                     COUNT(CustomerName) 
                     / (SELECT COUNT(*)  
                        FROM sales) * 100, 2), ' %')
             AS PercentageSalesPerCustomer
FROM        sales SA
JOIN        customer CU USING(CustomerID)
GROUP BY    CustomerName
ORDER BY    CustomerName;


-- 2

SELECT       SC.MakeName, SC.ModelName, SC.SalePrice
             ,(SC.SalePrice / CRX.TotalSales) * 100 
                  AS PercentOfSales
             ,SC.SalePrice - CRX.AverageSales 
                  AS DifferenceToAverage
FROM         salesbycountry AS SC
CROSS JOIN   (SELECT SUM(SalePrice) AS TotalSales
                     ,AVG(SalePrice) AS AverageSales 
              FROM   salesbycountry 
              WHERE  YEAR(SaleDate) = 2017) AS CRX
WHERE        YEAR(SC.SaleDate) = 2017;


-- 3

SELECT       MakeName
            ,ModelName
            ,CAST(Cost AS INT) AS Cost
            ,CAST(RepairsCost AS INT) AS RepairsCost
            ,CAST(PartsCost AS INT) AS PartsCost
            ,CAST(SalePrice AS INT) AS SalePrice
FROM        SalesByCountry;


-- 5

SELECT       MakeName
            ,ModelName
            ,CAST(REPLACE(RIGHT(VehicleCost, 
             LENGTH(VehicleCost) -1), ',', '') AS DECIMAL(12,2)) 
               AS VehicleCost
FROM        SalesInPounds;


-- 6


SELECT       MakeName
            ,ModelName
            ,CASE
                 WHEN CAST(REPLACE(RIGHT(VehicleCost
                 ,LENGTH(VehicleCost) -1), ',', '') 
                        AS DECIMAL(12,2)) <> 0 
                 THEN CAST(REPLACE(RIGHT(VehicleCost
                 ,LENGTH(VehicleCost) -1), ',', '') 
                        AS DECIMAL(12,2))
                 ELSE 'Manual Intervention'
             END AS VehicleCostUnformatted
FROM        SalesInPounds;


-- 7

SELECT      CountryName, CountrySales
FROM        CountrySales
WHERE       CountrySales NOT REGEXP '^[0-9\.]+$';


-- 8

SELECT    CustomerID
FROM
     (
     SELECT      CustomerID
                 ,CustomerID MOD 3 AS ModuloOutput
                 ,CASE
                       WHEN CustomerID MOD 3 = 1 THEN 'Winner'
                           ELSE NULL
                   END AS LuckyWinner
     FROM        Customer
     ) Rnd
WHERE       LuckyWinner IS NOT NULL
ORDER BY    CustomerID;


-- 9

SELECT
 InitialCost
,MonthsSincePurchase
,(InitialCost * POWER(1 + (0.75 / 100), MonthsSincePurchase)) 
- InitialCost AS InterestCharge
,InitialCost * POWER(1 + (0.75 / 100), MonthsSincePurchase) 
 AS TotalWithInterest

FROM
(
   SELECT
    DATEDIFF(SA.SaleDate, ST.DateBought) / 30 AS MonthsSincePurchase
   ,(ST.Cost + ST.PartsCost + ST.RepairsCost) AS InitialCost
    FROM   stock ST
    JOIN   salesdetails SD
           ON ST.StockCode = SD.StockID
    JOIN   sales SA USING(SalesID)
    WHERE  DATEDIFF(SA.SaleDate, ST.DateBought) > 60
) SRC;


-- 10

SELECT                  RowNo AS PeriodNumber
                        ,Cost
                        ,Cost / 5 AS StraightLineDepreciation
                        ,Cost - ((Cost / 5) * RowNo) 
                                AS RemainingValue

FROM                  stock
CROSS JOIN
(
SELECT 1 AS RowNo
UNION 
SELECT 2
UNION 
SELECT 3
UNION 
SELECT 4
UNION 
SELECT 5
) Tally
WHERE                  StockCode = 
                        'A2C3B95E-3005-4840-8CE3-A7BC5F9CFB5F';

-- 11

SELECT       *
FROM         salesbycountry
ORDER BY     RAND()
LIMIT        50;






