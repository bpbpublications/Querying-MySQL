/* CHAPTER 5 */


-- 1

SELECT     DISTINCT MK.MakeName, ST.Color
FROM       make AS MK
JOIN       model AS MD USING (MakeID)
JOIN       stock AS ST USING (ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
WHERE      ST.Color = 'Red' OR MakeName = 'Ferrari'
ORDER BY   MK.MakeName;


-- 2

SELECT DISTINCT  MK.MakeName, ST.Color
FROM             make AS MK
JOIN             model AS MD USING (MakeID)
JOIN             stock AS ST USING (ModelID)
JOIN             salesdetails SD ON ST.StockCode = SD.StockID
WHERE            ST.Color = 'Red' AND MK.MakeName = 'Ferrari';


-- 3

SELECT     DISTINCT MK.MakeName, ST.Color
FROM       make AS MK
JOIN       model AS MD USING (MakeID)
JOIN       stock AS ST USING (ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
WHERE      ST.Color IN ('Red', 'Green', 'Blue')
           AND MK.MakeName != 'Bentley'
ORDER BY   MK.MakeName, ST.Color;


-- 4

SELECT     MD.ModelName, ST.Color, ST.PartsCost
           ,ST.RepairsCost
FROM       stock AS ST 
JOIN       model AS MD
           USING (ModelID)
WHERE      ST.Color = 'Red' AND (ST.PartsCost > 1000
           OR ST.RepairsCost > 1000)
ORDER BY   MD.ModelName;


-- 5

SELECT DISTINCT  MD.ModelName, ST.Color, ST.PartsCost
                 ,ST.RepairsCost
FROM             stock AS ST 
JOIN             model AS MD USING (ModelID)
WHERE            (ST.Color IN ('Red', 'Green', 'Blue') 
                   AND 	
                   MD.ModelName = 'Phantom') 
                   OR 
                 (ST.PartsCost > 5500 AND ST.RepairsCost > 5500);


-- 6

SELECT * 
FROM   stock 
WHERE  BINARY color = 'Dark purple';


-- 7

SELECT     MD.ModelName, ST.Color, ST.PartsCost
           ,ST.RepairsCost
FROM       stock AS ST 
JOIN       model AS MD	
           USING (ModelID)
WHERE      UPPER(ST.Color) = 'DARK PURPLE'
ORDER BY   MD.ModelName;


-- 8

SELECT     CustomerName 
FROM       customer	
WHERE      CustomerName LIKE '%pete%';


-- 9

SELECT     CustomerName 
FROM       customer
WHERE      CustomerName NOT LIKE '%pete%'
ORDER BY   CustomerName;


-- 10

SELECT * 
FROM make 
WHERE BINARY MakeName LIKE '%L%';



-- 11

SELECT DISTINCT   MD.ModelName, SA. InvoiceNumber
FROM              make AS MK 
JOIN        model AS MD 
                  USING (MakeID)
JOIN        stock ST	
                  USING (ModelID)
JOIN        salesdetails AS SD 
                  ON SD.StockID = ST.StockCode
JOIN        sales AS SA
                  ON SA.SalesID = SD.SalesID
WHERE             SA.InvoiceNumber LIKE '___FR%'
ORDER BY   SA. InvoiceNumber;


-- 12

SELECT   CustomerName, PostCode
FROM     customer
WHERE    PostCode IS NULL
ORDER BY  CustomerName;


-- 13

SELECT   CustomerName
FROM     customer
WHERE    CustomerName REGEXP '^Pe.*g$';

