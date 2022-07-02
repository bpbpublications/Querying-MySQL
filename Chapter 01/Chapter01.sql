/* Chapter 1 */


-- 7

SELECT  *
FROM    make;


-- 8

SELECT CustomerName
FROM   customer;


-- 10

SELECT CountryName, SalesRegion
FROM   country;


-- 12

SELECT CountryName, CountryISO3 AS IsoCode FROM country;


-- 13

SELECT    * 
FROM      SalesByCountry 
ORDER BY  SalePrice;


-- 14

SELECT    CountryISO3 AS IsoCode, CountryName  
FROM      Country 
ORDER BY  IsoCode DESC;


-- 15

SELECT    CountryName, MakeName, ModelName
FROM      SalesByCountry	
ORDER BY  CountryName, MakeName, ModelName;


-- 16

SELECT   *
FROM     make
         LIMIT 10;






