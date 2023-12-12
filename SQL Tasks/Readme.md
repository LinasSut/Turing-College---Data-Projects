# Basic SQL tasks using BigQuery enviroment
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
# Task 2 : Reviewing work orders
###  Task 2.1

Create an aggregated query to selec tthe:

  - Number of unique work orders.
  - Number of unique products.
  - Total actual cost.
    
For each location Id from the 'workoderrouting' table for orders in January 2004.

```
SELECT
  workorder_routing.LocationID,
  COUNT(DISTINCT workorders.WorkOrderID) AS no_work_orders,
  COUNT(DISTINCT workorders.ProductID) AS no_unique_product,
  SUM(workorder_routing.ActualCost) AS actual_costs
FROM
  `adwentureworks_db.workorder` AS workorders
JOIN
  adwentureworks_db.workorderrouting AS workorder_routing
ON
  workorders.WorkOrderID = workorder_routing.workorderid
WHERE
  DATE(workorder_routing.ActualStartDate) BETWEEN '2004-01-01' AND '2004-01-31'
GROUP BY
  locationid
ORDER BY
  actual_costs DESC
```
###  Task 2.2

Update your 2.1 query by adding the name of the location and also add the average days amount between actual start date and actual end date per each location.

```
SELECT
  workorder_routing.LocationID AS LocationId,
  location.name AS Location,
  COUNT(DISTINCT workorders.WorkOrderID) AS no_work_orders,
  COUNT(DISTINCT workorders.ProductID) AS no_unique_product,
  SUM(workorder_routing.ActualCost) AS actual_costs,
  ROUND(AVG(DATE_DIFF(ActualEndDate,ActualStartDate, day)),2) AS avg_days_diff
FROM
  `adwentureworks_db.workorder` AS workorders
JOIN
  adwentureworks_db.workorderrouting AS workorder_routing
ON
  workorders.WorkOrderID = workorder_routing.workorderid
JOIN
  `adwentureworks_db.location` AS location
ON
  workorder_routing.locationid = location.LocationID
WHERE
  DATE(workorder_routing.ActualStartDate) BETWEEN '2004-01-01' AND '2004-01-31'
GROUP BY
  LocationId,
  Location
ORDER BY
  actual_costs DESC
```
###  Task 2.3

Select all the expensive work Orders (above 300 actual cost) that happened throught January 2004.

```
SELECT
  workorder_routing.WorkOrderID AS WorkOrderID,
  SUM(workorder_routing.ActualCost) AS actual_cost
FROM
  adwentureworks_db.workorderrouting AS workorder_routing
WHERE
  DATE(workorder_routing.ActualStartDate) BETWEEN '2004-01-01' AND '2004-01-31'
GROUP BY
  WorkOrderID
HAVING
  SUM(workorder_routing.ActualCost) > 300
```

# Task 3 : Query Validation
###  Task 3.1 

Your colleague has written a query to find the highest sales connected to special offers. The query works fine but the numbers are off, investigate where the potential issue lies.

```
SELECT
  DISTINCT sales_detail.SalesOrderId,
  sales_detail.OrderQty,
  ROUND(sales_detail.UnitPrice,2) AS UnitPrice,
  ROUND(sales_detail.LineTotal,2) AS LineTotal,
  sales_detail.ProductId,
  sales_detail.SpecialOfferID,
  spec_offer.Category,
  spec_offer.Description
FROM
  tc-da-1.adwentureworks_db.salesorderdetail AS sales_detail
LEFT JOIN
  tc-da-1.adwentureworks_db.specialofferproduct AS spec_offer_product
ON
  sales_detail.productId = spec_offer_product.ProductID
LEFT JOIN
  tc-da-1.adwentureworks_db.specialoffer AS spec_offer
ON
  sales_detail.SpecialOfferID = spec_offer.SpecialOfferID
ORDER BY
  LineTotal desc
```

###  Task 3.2 

Your colleague has written this query to collect basic Vendor information. The query does not work, look into the query and find ways to fix it. Can you provide any feedback on how to make this query be easier to debug/read?

```
SELECT
  vendor.VendorID AS ID,
  vendor_contact.ContactID AS ContactID,
  vendor_contact.ContactTypeID AS Contact_type_id,
  vendor.Name AS vendor_name,
  vendor.CreditRating AS Credit_ratting,
  vendor.ActiveFlag AS Active,
  vendor_address.AddressID AS addressID,
  address.City
FROM
  `adwentureworks_db.vendor` AS vendor
LEFT JOIN
  `adwentureworks_db.vendorcontact` AS vendor_contact
ON
  vendor.VendorID = vendor_contact.VendorID
LEFT JOIN
  `adwentureworks_db.vendoraddress` AS vendor_address
ON
  vendor.VendorID = vendor_address.VendorID
LEFT JOIN
  `adwentureworks_db.address` AS address
ON
  vendor_address.AddressID = address.AddressID
```
