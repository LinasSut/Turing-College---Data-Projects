# Basic SQL tasks using Bigquery enviroment
# Task 1 : An overview of Products
###  Task 1.1 
You’ve been asked to extract the data on products from the Product table where there exists a product subcategory. And also include the name of the ProductSubcategory.

  - Columns needed: ProductId, Name, ProductNumber, size, color, ProductSubcategoryId, Subcategory name.
  - Order results by SubCategory name.

```
-- This query brings ProductId, Name, ProductNumber, size, color, ProductSubcategoryId, Subcategory name and order by Subcategory name from adwentureworks_db, product and product subcategory tables

SELECT	
  product.productid AS Productid,	
  product.Name AS Name,	
  product.ProductNumber AS ProductNumber,	
  product.size AS Size,	
  product.Color AS Color,	
  product_subcategory.ProductSubcategoryID,	
  product_subcategory.name AS Subcategory_Name,	
FROM	
  adwentureworks_db.product AS product	
JOIN	
  adwentureworks_db.productsubcategory AS product_subcategory	
ON	
  product.ProductSubcategoryID = product_subcategory.ProductSubcategoryID	
ORDER BY	
  Subcategory_name
```

###  Task 1.2 

In 1.1 query you have a product subcategory but see that you could use the category name.

  - Find and add the product category name.
  - Afterwards order the results by Category name.

```
SELECT
  product.productid AS Productid,
  product.Name AS Name,
  product.ProductNumber AS ProductNumber,
  product.size AS Size,
  product.Color AS Color,
  product_subcategory.ProductSubcategoryID,
  product_subcategory.name AS Subcategory_Name,
  product_category.Name AS Category
FROM
  adwentureworks_db.product AS product
JOIN
  adwentureworks_db.productsubcategory AS product_subcategory
ON
  product.ProductSubcategoryID = product_subcategory.ProductSubcategoryID
JOIN
  adwentureworks_db.productcategory AS product_category
ON
  product_subcategory.ProductCategoryID = product_category.productcategoryid
ORDER BY
  Category
```
###  Task 1.3

Use the established query to select the most expensive (price listed over 2000) bikes that are still actively sold (does not have a sales end date)

  - Order the results from most to least expensive bike.

```
SELECT
  product.productid AS Productid,
  product.Name AS Name,
  product.ProductNumber AS ProductNumber,
  product.size AS Size,
  product.Color AS Color,
  product_subcategory.ProductSubcategoryID,
  product_subcategory.name AS Subcategory_Name,
  product_category.Name AS Category
FROM
  adwentureworks_db.product AS product
JOIN
  adwentureworks_db.productsubcategory AS product_subcategory
ON
  product.ProductSubcategoryID = product_subcategory.ProductSubcategoryID
JOIN
  adwentureworks_db.productcategory AS product_category
ON
  product_subcategory.ProductCategoryID = product_category.productcategoryid
WHERE
  ListPrice > 2000
    AND SellEndDate IS NULL
    AND product_category.Name = 'Bikes'
ORDER BY
  ListPrice DESC
```



