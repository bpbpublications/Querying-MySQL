/* CHAPTER 3 */


-- 1

SELECT DISTINCT    MK.MakeName, MD.ModelName
FROM               make MK LEFT JOIN model MD USING(MakeID);


-- 2

SELECT DISTINCT    MK.MakeName, MD.ModelName
FROM               model MD 
RIGHT JOIN         make MK USING (MakeID);


-- 3

SELECT     CO.CountryName, SA.TotalSalePrice
FROM       sales SA
JOIN       customer CS USING (CustomerID)
JOIN       country CO
           ON CS.Country = CO.CountryISO2
ORDER BY   CO.CountryName;


-- 4

SELECT      CS.CustomerName, MI.SpendCapacity
FROM        customer CS
JOIN        marketinginformation MI
            ON CS.CustomerName = MI.Cust
            AND CS.Country = MI.Country
ORDER BY    CS.CustomerName;


-- 5

SELECT       ST1.StaffName, ST1.Department, ST2.StaffName
                 AS ManagerName
FROM         staff ST1	
JOIN         staff ST2
             ON ST1.ManagerID = ST2.StaffID
ORDER BY    ST1.Department, ST1.StaffName;


-- 6

SELECT
 MK.MakeName
,MD.ModelName
,SD.SalePrice
,CAT.CategoryDescription
FROM        stock ST 
JOIN        model MD USING (ModelID)
JOIN        make MK  USING (MakeID)
JOIN        salesdetails SD 
            ON ST.StockCode = SD.StockID 
JOIN        salescategory CAT
            ON SD.SalePrice BETWEEN 
                            CAT.LowerThreshold 
                            AND CAT.UpperThreshold
ORDER BY    MK.MakeName, MD.ModelName;


-- 7

SELECT        CountryName, MakeName
FROM          country
CROSS JOIN    make
ORDER BY      CountryName, MakeName;

