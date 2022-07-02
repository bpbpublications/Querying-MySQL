/* CHAPTER 4 */


-- 2

SELECT DISTINCT     MK.MakeName, MD.ModelName
FROM                stock ST
JOIN                model MD USING(ModelID)
JOIN                make MK USING(MakeID)
ORDER BY            MK.MakeName, MD.ModelName;


-- 3

SELECT     MD.ModelName, SA.SaleDate, SA.InvoiceNumber 
FROM       model AS MD 
JOIN       stock ST USING (ModelID)
JOIN       salesdetails SD 
           ON ST.StockCode = SD.StockID
JOIN       sales SA USING (SalesID)
ORDER BY   MD.ModelName;


-- 4

SELECT DISTINCT MD.ModelName, ST.Color 
FROM            stock ST
JOIN            model MD USING (ModelID)	
WHERE           Color = 'Red'
ORDER BY        MD.ModelName;



-- 5

SELECT     MD.ModelName, ST.Color 
FROM       stock ST	
JOIN       model MD USING (ModelID)
WHERE      ST.Color IN ('Red', 'Green', 'Blue')
ORDER BY   MD.ModelName;


-- 6

SELECT     DISTINCT MK.MakeName
           FROM make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
WHERE      MK.MakeName <> 'Ferrari'
ORDER BY   MK.MakeName;


-- 7

SELECT     DISTINCT MK.MakeName
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
WHERE      MK.MakeName NOT IN ('Porsche', 'Aston Martin', 'Bentley')
ORDER BY   MK.MakeName;


-- 8

SELECT     ModelName, Cost
FROM       model
JOIN       stock USING(ModelID)
WHERE      Cost > 50000;


-- 9

SELECT     ModelName, Cost
FROM       model	
JOIN       stock USING(ModelID)
WHERE      PartsCost < 1000
ORDER BY   ModelName;


-- 10

SELECT     MD.ModelName, ST.RepairsCost
FROM       model MD
JOIN       stock ST USING(ModelID)
WHERE      ST.RepairsCost <= 500
ORDER BY   MD.ModelName;


-- 11

SELECT     DISTINCT MK.MakeName
FROM       make AS MK JOIN model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
WHERE      ST.PartsCost BETWEEN 1000 AND 2000
ORDER BY   MK.MakeName;


-- 12

SELECT     DISTINCT MK.MakeName, MD.ModelName
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD ON ST.StockCode = SD.StockID
WHERE      ST.IsRHD = 1
ORDER BY   MK.MakeName, MD.ModelName;







