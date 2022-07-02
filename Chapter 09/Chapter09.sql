/* CHAPTER 9 */


-- 1

SELECT CONCAT('Customer: ', CustomerName) AS Customer
FROM   customer;


-- 2

SELECT     CONCAT('Sales: ', TotalSalePrice ,' GBP') 
              AS SalePriceInPounds
FROM       sales;


-- 3

SELECT CustomerName, CONCAT(Address1, ' ', Town, ' - ', PostCode) 
                     AS FullAddress 
FROM   customer;


-- 4

SELECT CustomerName, CONCAT(IFNULL(Address1, '')
                            , ' ', IFNULL(Town, '')
                            , ' - ' 
                            , IFNULL(PostCode, '')) 
                              AS FullAddress 
FROM   customer;


-- 5

SELECT     CONCAT(MakeName, ', ', ModelName) AS MakeAndModel
           ,SUM(SalePrice) As TotalSold 
FROM       stock ST 
JOIN       model MD USING(ModelID) 
JOIN       make MK USING(MakeID) 
JOIN       salesdetails SD 
           ON ST.StockCode = SD.StockID 
JOIN       sales SA USING(SalesID)
GROUP BY   CONCAT(MakeName, ', ', ModelName);


-- 6

SELECT CustomerName, CONCAT_WS(' ', Address1,  Town, PostCode) 
                     AS FullAddress 
FROM   customer;


-- 7

SELECT     UPPER(CustomerName) AS Customer
FROM       customer;


-- 8

SELECT     LOWER(ModelName) AS Model
FROM       model;


-- 9

SELECT     CONCAT(ModelName, ' (', LEFT(MakeName, 3), ')') 
              AS MakeAndModel
FROM       make
JOIN       model USING(MakeID);


-- 10

SELECT     RIGHT(InvoiceNumber, 3) AS InvoiceSequenceNumber 
FROM       sales
ORDER BY   InvoiceSequenceNumber;


-- 11

SELECT     SUBSTRING(InvoiceNumber, 4, 2) AS DestinationCountry 
FROM       sales;


-- 12

SELECT     InvoiceNumber, TotalSalePrice
FROM       sales
WHERE      LEFT(InvoiceNumber, 3) = 'EUR';


-- 13

SELECT     SA.InvoiceNumber, SA.TotalSalePrice
FROM       make AS MK JOIN model AS MD 
           ON MK.MakeID = MD.MakeID
           JOIN stock AS ST ON ST.ModelID = MD.ModelID
           JOIN salesdetails SD ON ST.StockCode = SD.StockID
           JOIN sales AS SA ON SA.SalesID = SD.SalesID
WHERE      SUBSTRING(SA.InvoiceNumber, 4, 2)  = 'FR'
           AND MK.MakeCountry = 'ITA';


-- 14

SELECT      SA.CustomerID, SA.TotalSalePrice, CO.CountryName
FROM        sales AS SA
JOIN        country CO
            ON CO.CountryISO2 = SUBSTRING(SA.InvoiceNumber, 4, 2)
ORDER BY    CO.CountryName, SA.CustomerID;




