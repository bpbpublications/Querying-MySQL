/* CHAPTER 10 */


-- 1

SELECT     TotalSalePrice, FLOOR(TotalSalePrice) AS SalePriceRoundedDown
FROM       sales
ORDER BY   SalesID;


-- 2

SELECT     TotalSalePrice, CEILING(TotalSalePrice) AS SalePriceRoundedUp
FROM       sales
ORDER BY   SalesID;


-- 3

SELECT     TotalSalePrice, ROUND(TotalSalePrice, 0) AS SalePriceRounded
FROM       sales
ORDER BY   SalesID;


-- 4

SELECT     TotalSalePrice, ROUND(TotalSalePrice, -3) 
              AS SalePriceRoundedToThousand
FROM       sales;


-- 5

SELECT     FORMAT(cost, 2) AS UKSalePrice
FROM       stock
ORDER BY   stockcode;


-- 6

SELECT     MakeName, ModelName
           ,CONCAT("£ ", FORMAT(SalePrice, 2)) AS SterlingSalePrice
FROM       salesbycountry
ORDER BY   MakeName, ModelName, SterlingSalePrice DESC;


-- 7

SELECT     FORMAT(TotalSalePrice, 2, 'de_DE') AS GermanSalePrice
FROM       sales
ORDER BY   TotalSalePrice DESC;


-- 8

SELECT     InvoiceNumber
           ,DATE_FORMAT(SaleDate, '%c %b %Y') AS SaleDate
FROM       sales;


-- 9

SELECT     InvoiceNumber
           ,DATE_FORMAT(SaleDate, GET_FORMAT(DATE, 'ISO'))
              AS SaleDate
FROM       Sales;


-- 10

SELECT     InvoiceNumber
           ,DATE_FORMAT(SaleDate, '%r') AS SaleTime
FROM       Sales;







