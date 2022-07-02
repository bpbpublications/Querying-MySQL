/* CHAPTER 11 */


-- 1

SELECT      Cost, RepairsCost, PartsCost
                           ,IF(PartsCost > RepairsCost, 'Cost Alert!', NULL) 
           AS CostAnalysis
FROM       Stock;


-- 2

SELECT     Cost, RepairsCost, PartsCost 
           ,IF(
                LENGTH(BuyerComments) < 25
                ,BuyerComments
                ,CONCAT(LEFT(BuyerComments, 20), ' ...')
               ) AS Comments
FROM       Stock
WHERE      BuyerComments IS NOT NULL;


-- 3

SELECT      ST.Cost, ST.RepairsCost, ST.PartsCost 
           ,IF(
                (SD.SalePrice - 
                  (ST.Cost + SD.LineItemDiscount
                           + ST.PartsCost
                           + IFNULL(ST.RepairsCost, 0) 
                           + ST.TransportInCost
                   )
                 ) 
                 < (SD.SalePrice * 0.1) 
                 AND (ST.RepairsCost * 2) > ST.PartsCost
              ,'Warning!!'
              ,'OK'
               ) AS CostAlert
FROM       stock ST
           JOIN salesdetails SD ON ST.StockCode 
             = SD.StockID;


-- 4

SELECT      ST.Cost, ST.RepairsCost, ST.PartsCost 
           ,IF(
                (SD.SalePrice - 
                  (ST.Cost + SD.LineItemDiscount
                           + ST.PartsCost
                           + IFNULL(ST.RepairsCost, 0) 
                           + ST.TransportInCost
                   )
                 ) 
                 < (SD.SalePrice * 0.1) 
                 AND (ST.RepairsCost * 2) > ST.PartsCost
              ,'Warning!!'
              ,IF(
                     (SD.SalePrice - 
                         (ST.Cost + SD.LineItemDiscount 
                            - IFNULL(ST.PartsCost, 0)
                          + ST.RepairsCost + ST.TransportInCost) 
                      ) < SD.SalePrice * 0.5, 'Acceptable', 'OK'
                    )
               ) AS CostAlert
FROM       stock ST
           JOIN salesdetails SD ON ST.StockCode = SD.StockID;


-- 5

SELECT     CountryName
           ,CASE CountryName
              WHEN 'Belgium' THEN 'Eurozone'
              WHEN 'France' THEN 'Eurozone'
              WHEN 'Italy' THEN 'Eurozone'
              WHEN 'Spain' THEN 'Eurozone'
              WHEN 'United Kingdom' THEN 'Pound Sterling'
              WHEN 'United States' THEN 'Dollar'
              ELSE 'Other'
           END AS CurrencyRegion
FROM       country;


-- 6

SELECT    CASE 
            WHEN MK.MakeCountry IN ('ITA', 'GER', 'FRA') 
                 THEN 'European'
            WHEN MK.MakeCountry = 'GBR' THEN 'British'
            WHEN MK.MakeCountry = 'USA' THEN 'American'
            ELSE 'Other'
          END AS SalesRegion
          ,COUNT(SD.SalesDetailsID) AS NumberOfSales
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD 
           ON ST.StockCode = SD.StockID
GROUP BY   CASE 
            WHEN MK.MakeCountry IN ('ITA', 'GER', 'FRA') 
                 THEN 'European'
            WHEN MK.MakeCountry = 'GBR' THEN 'British'
            WHEN MK.MakeCountry = 'USA' THEN 'American'
            ELSE 'Other'
          END;


-- 7

SELECT    CustomerName
          ,CASE
          WHEN IsReseller = 0 AND country IN ('IT', 'DE', 'FR'
                                              ,'ES', 'BE') 
                  THEN 'Eurozone Retail Client'
          WHEN IsReseller = 0 AND country IN ('GB') 
                  THEN 'British Retail Client'
          WHEN IsReseller = 0 AND country IN ('US') 
                  THEN 'American Retail Client'
          WHEN IsReseller = 0 AND country IN ('CH') 
                  THEN 'Swiss Retail Client'
          WHEN IsReseller = 1 AND country IN ('IT', 'DE', 'FR'
                                              ,'ES', 'BE') 
                  THEN 'Eurozone Reseller'
          WHEN IsReseller = 1 AND country IN ('GB') 
                  THEN 'British Reseller'
          WHEN IsReseller = 1 AND country IN ('US') 
                  THEN 'American Reseller'
          WHEN IsReseller = 1 AND country IN ('CH') 
                  THEN 'Swiss Reseller'
         END AS CustomerType
FROM     customer;


-- 8

SELECT     CustomerName
           ,CASE
               WHEN IsCreditRisk = 0 THEN
                        CASE 
                            WHEN country IN ('IT', 'DE', 'FR'
                                             ,'ES', 'BE') 
                                THEN 'Eurozone No Risk'
                            WHEN country IN ('GB') 
                                THEN 'British No Risk'
                            WHEN country IN ('US') 
                                THEN 'American No Risk'
                            WHEN country IN ('CH') 
                                THEN 'Swiss No Risk'
                        END
               WHEN IsCreditRisk = 1 THEN
                        CASE
                            WHEN country IN ('IT', 'DE', 'FR'
                                             ,'ES', 'BE') 
                               THEN 'Eurozone Credit Risk'
                            WHEN country IN ('GB') 
                               THEN 'British Credit Risk'
                            WHEN country IN ('US') 
                               THEN 'American Credit Risk'
                            WHEN country IN ('CH') 
                               THEN 'Swiss Credit Risk'
                  END        
            END AS RiskType
FROM       Customer;


-- 9

SELECT      'Sales By Category'
           ,SUM(CASE WHEN SD.SalePrice < 5000 THEN 1 ELSE 0 END)
                AS 'Under 5000'
           ,SUM(CASE WHEN SD.SalePrice BETWEEN 5000 AND 50000 
                     THEN 1 ELSE 0 END) AS '5000-50000'
           ,SUM(CASE WHEN SD.SalePrice BETWEEN 50001 AND 100000 
                     THEN 1 ELSE 0 END) AS '50001-100000'
           ,SUM(CASE WHEN SD.SalePrice BETWEEN 100001 AND 200000 
                     THEN 1 ELSE 0 END) AS '100001-200000'
           ,SUM(CASE WHEN SD.SalePrice > 200000 THEN 1 ELSE 0 END)
                AS 'Over 200000'
FROM       make AS MK 
JOIN       model AS MD USING(MakeID)
JOIN       stock AS ST USING(ModelID)
JOIN       salesdetails SD 
           ON ST.StockCode = SD.StockID;


-- 10

SELECT      *
FROM        salesbycountry
ORDER BY    CASE WHEN LineItemDiscount IS NULL THEN 1 ELSE 0 END ASC
            ,LineItemDiscount;


-- 11

SELECT
MONTH(SaleDate) AS MonthNumber
,SaleDate
,ELT(MONTH(SaleDate), 'Winter', 'Winter', 'Spring', 'Spring', 'Summer'
                    , 'Summer','Summer','Summer','Autumn','Autumn'
                    , 'Winter','Winter')
               AS SalesSeason
FROM       Sales;

