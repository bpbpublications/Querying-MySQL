/* CHAPTER 2 */

-- 1

SELECT     ModelName, Cost
FROM       model
JOIN       stock USING(modelID)
ORDER BY   ModelName;


-- 2

SELECT           CountryName
FROM             customer	
JOIN             country
                 ON customer.Country = country.CountryISO2;


-- 3

SELECT DISTINCT  CountryName
FROM             customer	
JOIN             country
                 ON customer.Country = country.CountryISO2
ORDER BY         CountryName;


-- 4

SELECT     make.MakeName, Model.modelName, stock.Cost
FROM       stock 
JOIN       model USING(ModelID)
JOIN       make USING(MakeID)
ORDER BY   make.MakeName, Model.modelName;


-- 5

SELECT     S.InvoiceNumber, D.LineItemNumber, D.SalePrice
           ,D.LineItemDiscount
FROM       sales AS S
JOIN       salesdetails AS D USING (SalesID)
ORDER BY   S.InvoiceNumber, D.LineItemNumber;


-- 6

SELECT      CY.CountryName
           ,MK.MakeName
           ,MD.modelName
           ,ST.Cost
           ,ST.RepairsCost
           ,ST.PartsCost
           ,ST.TransportInCost
           ,ST.Color
           ,SD.SalePrice
           ,SD.LineItemDiscount
           ,SA.InvoiceNumber
           ,SA.SaleDate
           ,CS.CustomerName
FROM       stock ST 
JOIN       model MD USING (modelID)
JOIN       make MK  USING (MakeID)
JOIN       salesdetails SD 
           ON ST.StockCode = SD.StockID 
JOIN       sales SA  USING (SalesID)
JOIN       customer CS  USING (CustomerID)
JOIN       country CY 
           ON CS.country = CY.CountryISO2
ORDER BY    CY.CountryName
           ,MK.MakeName
           ,MD.ModelName;
           
-- 8

SELECT      CountryName
           ,MakeName
           ,modelName
           ,Cost
           ,RepairsCost
           ,PartsCost
           ,TransportInCost
           ,Color
           ,SalePrice
           ,LineItemDiscount
           ,InvoiceNumber
           ,SaleDate
           ,CustomerName
FROM       salesbycountry
ORDER BY    CountryName
           ,MakeName
           ,ModelName;



