# Advance SQL tasks using BigQuery enviroment
# Task 1 : An overview of Products
###  Task 1.1 
You’ve been tasked to create a detailed overview of all individual customers (these are defined by customerType = ‘I’ and/or stored in an individual table). 

Write a query that provides:

  - Identity information : CustomerId, Firstname, Last Name, FullName (First Name & Last Name).
  - An Extra column called addressing_title i.e. (Mr. Achong), if the title is missing - Dear Achong.
  - Contact information : Email, phone, account number, CustomerType.
  - Location information : City, State & Country, address.
  - Sales: number of orders, total amount (with Tax), date of the last order.
    
Copy only the top 200 rows from your written select ordered by total amount (with tax).

```
-- 1.1 gather required fields from different tables using CTE 

-- Customer Data
WITH 
  customers AS (
    SELECT 
      CustomerID,
      AccountNumber,
      CustomerType 
    FROM `adwentureworks_db.customer`
  ),

-- Contact information with concatinated fields

  contacts AS (
    SELECT 
      CustomerID,
      contact.Firstname,
      contact.LastName,
      CONCAT(contact.firstname,' ',contact.lastname) AS Fullname,
      CONCAT((CASE WHEN contact.title IS NULL THEN 'Dear' ELSE contact.title END),' ',contact.lastname) AS Addressing_title,
      contact.emailaddress,
      contact.phone,
    FROM `adwentureworks_db.contact` AS contact
    JOIN `adwentureworks_db.individual` AS individual
    ON contact.ContactId = individual.ContactID
  ),

  -- customers addres information

  addresses AS (
    SELECT
      customeraddress.CustomerID,
      address.AddressLine1,
      address.AddressLine2,
      address.city,
      state_province.name AS State,
      country_region.Name AS Country
    FROM `adwentureworks_db.address` AS address
    JOIN `adwentureworks_db.customeraddress` AS customeraddress
      ON customeraddress.AddressID = address.AddressID
    JOIN `adwentureworks_db.stateprovince`AS state_province
      ON address.StateProvinceID = state_province.StateProvinceID
    JOIN `adwentureworks_db.countryregion` AS country_region
      ON state_province.CountryRegionCode = country_region.CountryRegionCode
  ),

-- Orders Data with number of orders, total amount, latest orders fields

  orders AS (
    SELECT
      CustomerID,
      COUNT(SalesOrderID) AS number_orders,
      ROUND(SUM(SubTotal) + SUM(TaxAmt) + SUM(Freight)) AS total_amount,
      MAX(OrderDate) AS latest_orders
    FROM `adwentureworks_db.salesorderheader`
    GROUP BY CustomerID
  )

-- Main query

SELECT
  customers.customerid,
  contacts.firstname,
  contacts.lastname,
  contacts.Fullname,
  contacts.Addressing_title,
  contacts.emailaddress,
  contacts.phone,
  customers.accountnumber,
  customers.customertype,
  addresses.city,
  addresses.addressline1,
  addresses.addressline2,
  addresses.State,
  addresses.Country,
  orders.number_orders,
  orders.total_amount,
  orders.latest_orders
  FROM customers
  JOIN contacts
    ON customers.customerid = contacts.customerid
  JOIN addresses
    ON addresses.customerid = customers.customerid
  JOIN orders
    ON customers.CustomerID = orders.CustomerID
  WHERE customers.customertype = 'I'
  ORDER BY orders.total_amount DESC
  LIMIT 200
```

###  Task 1.2 

Business finds the original query valuable to analyze customers and now want to get the data from the first query for the top 200 customers with the highest total amount (with tax) who have not ordered for the last 365 days. 
How would you identify this segment?

Hints:
  - You can use temp table, cte and/or subquery of the 1.1 select.
  - Note that the database is old and the current date should be defined by finding the latest order date in the orders table.

```
WITH
customers as (
  SELECT
    CustomerID,
    AccountNumber,
    CustomerType
FROM `adwentureworks_db.customer`
),

contacts as (
  SELECT
    CustomerID,
    contact.Firstname,
    contact.LastName,
  CONCAT(contact.firstname,' ',contact.lastname) as Fullname,
  CONCAT((CASE
    WHEN contact.title IS NULL
    THEN 'Dear'
    ELSE contact.title
    END),' ',contact.lastname) as Addressing_title,
  contact.emailaddress,
  contact.phone,
FROM `adwentureworks_db.contact` as contact
JOIN `adwentureworks_db.individual` AS individual
  ON contact.ContactId = individual.ContactID
),

addresses as (
  SELECT
  customeraddress.CustomerID,
  address.AddressLine1,
  address.AddressLine2,
  address.city,
  state_province.name as State,
  country_region.Name as Country
FROM `adwentureworks_db.address` as address
JOIN `adwentureworks_db.customeraddress` as customeraddress
  ON customeraddress.AddressID = address.AddressID
JOIN `adwentureworks_db.stateprovince`as state_province
  ON address.StateProvinceID = state_province.StateProvinceID
JOIN `adwentureworks_db.countryregion` as country_region
  ON state_province.CountryRegionCode = country_region.CountryRegionCode
),

orders as (
  SELECT
    CustomerID,
    COUNT(SalesOrderID) as number_orders,
    ROUND(SUM(SubTotal) + SUM(TaxAmt) + SUM(Freight)) as total_amount,
    MAX(OrderDate) as latest_orders_date
FROM `adwentureworks_db.salesorderheader`
GROUP BY CustomerID
)

SELECT
  customers.customerid,
  contacts.firstname,
  contacts.lastname,
  contacts.Fullname,
  contacts.Addressing_title,
  contacts.emailaddress,
  contacts.phone,
  customers.accountnumber,
  customers.customertype,
  addresses.city,
  addresses.addressline1,
  addresses.addressline2,
  addresses.State,
  addresses.Country,
  orders.number_orders,
  orders.total_amount,
  orders.latest_orders_date
FROM customers
JOIN contacts
  ON customers.customerid = contacts.customerid
JOIN addresses
  ON addresses.customerid = customers.customerid
JOIN orders
  ON customers.CustomerID = orders.CustomerID
WHERE customers.customertype = 'I'
  AND orders.latest_orders_date < DATE_SUB((SELECT MAX(orders.latest_orders_date) FROM orders), INTERVAL 365 day)
ORDER BY orders.total_amount DESC
LIMIT 200
```
###  Task 1.3

Enrich your original 1.1 SELECT by creating a new column in the view that marks active & inactive customers based on whether they have ordered anything during the last 365 days.

  - Copy only the top 500 rows from your written select ordered by CustomerId desc.

```
WITH
customers as (
  SELECT
    CustomerID,
    AccountNumber,
    CustomerType
  FROM `adwentureworks_db.customer`
),

contacts as (
  SELECT
    CustomerID,
    contact.Firstname,
    contact.LastName,
    CONCAT(contact.firstname,' ',contact.lastname) as Fullname,
    CONCAT((CASE WHEN contact.title IS NULL THEN 'Dear' ELSE contact.title END),' ',contact.lastname) as Addressing_title,
    contact.emailaddress,
    contact.phone,
  FROM `adwentureworks_db.contact` as contact
  JOIN `adwentureworks_db.individual` AS individual
    ON contact.ContactId = individual.ContactID
),

addresses as (
  SELECT
    customeraddress.CustomerID,
    address.AddressLine1,
    address.AddressLine2,
    address.city,
    state_province.name as State,
    country_region.Name as Country
  FROM `adwentureworks_db.address` as address
  JOIN `adwentureworks_db.customeraddress` as customeraddress
    ON customeraddress.AddressID = address.AddressID
  JOIN `adwentureworks_db.stateprovince`as state_province
    ON address.StateProvinceID = state_province.StateProvinceID
  JOIN `adwentureworks_db.countryregion` as country_region
    ON state_province.CountryRegionCode = country_region.CountryRegionCode
),

orders as (
  SELECT
    CustomerID,
    COUNT(SalesOrderID) as number_orders,
    ROUND(SUM(SubTotal) + SUM(TaxAmt) + SUM(Freight),2) as total_amount,
    MAX(OrderDate) as latest_orders_date,
    CASE
      WHEN MAX(OrderDate) > DATE_SUB( (SELECT MAX(OrderDate) FROM `adwentureworks_db.salesorderheader`), INTERVAL 365 day)
      THEN 'Active'
      ELSE 'Inactive'
    END AS Order_status
  FROM `adwentureworks_db.salesorderheader`
  GROUP BY CustomerID
)

SELECT
  customers.customerid,
  contacts.firstname,
  contacts.lastname,
  contacts.Fullname,
  contacts.Addressing_title,
  contacts.emailaddress,
  contacts.phone,
  customers.accountnumber,
  customers.customertype,
  addresses.city,
  addresses.addressline1,
  addresses.addressline2,
  addresses.State,
  addresses.Country,
  orders.number_orders,
  orders.total_amount,
  orders.latest_orders_date,
  orders.order_status
FROM customers
JOIN contacts
  ON customers.customerid = contacts.customerid
JOIN addresses
  ON addresses.customerid = customers.customerid
JOIN orders
  ON customers.CustomerID = orders.CustomerID
WHERE customers.customertype = 'I'
ORDER BY 1 DESC
LIMIT 500
```
###  Task 1.4
Business would like to extract data on all active customers from North America. Only customers that have either ordered 2500 in total amount (with Tax) or ordered 5 + times should be presented.

In the output for these customers divide their address line into two columns, i.e.:

AddressLine1	address_no	Address_st
'8603 Elmhurst Lane'	8603	Elmhurst Lane
Order the output by country, state and date_last_order.

```

-- 1.4 gather required fields from different tables using CTE 

-- Customer Data

WITH 
  customers AS (
    SELECT
      CustomerID,
      AccountNumber,
      CustomerType
    FROM `adwentureworks_db.customer`
  ),

-- Customer contact information

  contacts AS (
    SELECT 
      CustomerID,
      contact.Firstname,
      contact.LastName,
      CONCAT(contact.firstname,' ',contact.lastname) AS Fullname,
      CONCAT((CASE WHEN contact.title IS NULL THEN 'Dear' ELSE contact.title END),' ',contact.lastname) AS Addressing_title,
      contact.emailaddress,
      contact.phone,
    FROM `adwentureworks_db.contact` AS contact
    JOIN `adwentureworks_db.individual` AS individual
      ON contact.ContactId = individual.ContactID
  ),

-- Customer address information
  addresses AS (
    SELECT
      customeraddress.CustomerID,
      address.AddressLine1,
      address.AddressLine2,
      address.city,
      state_province.name AS State,
      country_region.Name AS Country
    FROM `adwentureworks_db.address` AS address
    JOIN `adwentureworks_db.customeraddress` AS customeraddress
      ON customeraddress.AddressID = address.AddressID
    JOIN `adwentureworks_db.stateprovince`AS state_province
      ON address.StateProvinceID = state_province.StateProvinceID
    JOIN `adwentureworks_db.countryregion` AS country_region
      ON state_province.CountryRegionCode = country_region.CountryRegionCode
  ),
-- Orders Data with number of orders, total amount, latest orders fields and order status, which shows inactive and active by if they ordered something in the last 365 days
 
  orders as (
    SELECT
      CustomerID,
      COUNT(SalesOrderID) AS number_orders,
      ROUND(SUM(SubTotal) + SUM(TaxAmt) + SUM(Freight)) AS total_amount,
      MAX(OrderDate) AS latest_orders_date,
      CASE
        WHEN MAX(OrderDate) > DATE_SUB( (SELECT MAX(OrderDate) FROM `adwentureworks_db.salesorderheader`), INTERVAL 365 day)
        THEN 'Active'
        ELSE 'Inactive'
        END AS Order_status
    FROM `adwentureworks_db.salesorderheader`
    GROUP BY 1

  )
  
-- Main querry which shows Active customers for North America (Canada and USA) which had orders 2500+ in total amount or had 5+ orders

SELECT customers.customerid,
  contacts.firstname,
  contacts.lastname,
  contacts.Fullname,
  contacts.Addressing_title,
  contacts.emailaddress,
  contacts.phone,
  customers.accountnumber,
  customers.customertype,
  addresses.city,
  addresses.addressline1,
  addresses.addressline2,
  LEFT(addresses.addressline1,STRPOS(addresses.addressline1,' ')) AS address_no,
  RIGHT(addresses.addressline1,LENGTH(addresses.addressline1) - STRPOS(addresses.addressline1,' ')) AS address_st,
  addresses.State,
  addresses.Country,
  orders.number_orders,
  orders.total_amount,
  orders.latest_orders_date,
  orders.order_status
FROM customers
JOIN contacts
  ON customers.customerid = contacts.customerid
JOIN addresses
  ON addresses.customerid = customers.customerid
JOIN orders
  ON customers.CustomerID = orders.CustomerID
WHERE customers.customertype = 'I'
    AND order_status = 'Active'
    AND addresses.Country IN ('United States','Canada')
    AND (orders.total_amount >= 2500 OR orders.number_orders >= 5)
ORDER BY 
  addresses.Country,
  addresses.State,
  orders.latest_orders_date
LIMIT 500 
```


# Task 2 : Reporting Sales’ numbers
###  Task 2.1

Create a query of monthly sales numbers in each Country & region. 

  - Include in the query: number of orders, customers and sales persons in each month with a total amount with tax earned
  - Sales numbers from all types of customers are required.

```
-- Gather required fields from different tables using CTE
-- teritories information
WITH
  territories AS (
    SELECT
      TerritoryID,
      Name AS Region,
      CountryRegionCode
    FROM `adwentureworks_db.salesterritory`
  ),

-- Orders information with order data, number of customers, orders and salespersons, total amount with tax

  orders AS (
    SELECT
      TerritoryID,
      LAST_DAY(CAST(OrderDate AS date)) AS order_month,
      COUNT(DISTINCT CustomerID) AS number_customers,
      COUNT(DISTINCT SalesOrderID) AS num_orders,
      COUNT(DISTINCT SalesPersonID) AS no_salesPersons,
      ROUND((SUM(SubTotal) + SUM(TaxAmt) + SUM(Freight)))  AS total_w_tax
    FROM `adwentureworks_db.salesorderheader`
    GROUP BY 1,2
  )

-- Main querry to show required information using CTE.

SELECT 
  orders.order_month,
  territories.CountryRegionCode,
  territories.region,
  orders.num_orders,
  orders.number_customers,
  orders.no_salesPersons,
  orders.total_w_tax
FROM territories
JOIN orders
  ON territories.TerritoryID = orders.TerritoryID
ORDER BY 2 DESC
```
###  Task 2.2

Enrich 2.1 query with the cumulative_sum of the total amount with tax earned per country & region.

```
-- Gather required fields from different tables using CTE

-- teritories information
WITH
  territories AS (
    SELECT
      TerritoryID,
      Name AS Region,
      CountryRegionCode
    FROM `adwentureworks_db.salesterritory`
  ),

-- Orders information with order data, number of customers, orders and salespersons, total amount with tax

  orders AS (
    SELECT
      TerritoryID,
      LAST_DAY(CAST(OrderDate AS date)) AS order_month,
      COUNT(DISTINCT CustomerID) AS number_customers,
      COUNT(DISTINCT SalesOrderID) AS number_orders,
      COUNT(DISTINCT SalesPersonID) AS no_salesPersons,
      ROUND((SUM(SubTotal) + SUM(TaxAmt) + SUM(Freight)))  AS total_w_tax
    FROM `adwentureworks_db.salesorderheader`
    GROUP BY 1,2
  )

-- Main querry to show required information using CTE with cummulative_sums using window function.

SELECT 
  orders.order_month,
  territories.CountryRegionCode,
  territories.region,
  orders.number_orders,
  orders.number_customers,
  orders.no_salesPersons,
  orders.total_w_tax,
  SUM(orders.total_w_tax) OVER (PARTITION BY territories.CountryRegionCode ORDER BY orders.order_month) AS cummulative_sum
FROM territories
JOIN orders
  ON territories.TerritoryID = orders.TerritoryID

```
###  Task 2.3

Enrich 2.2 query by adding ‘sales_rank’ column that ranks rows from best to worst for each country based on total amount with tax earned each month.
I.e. the month where the (US, Southwest) region made the highest total amount with tax earned will be ranked 1 for that region and vice versa.

```
-- Gather required fields from different tables using CTE

-- teritories information
WITH
  territories AS (
    SELECT
      TerritoryID,
      Name AS Region,
      CountryRegionCode
    FROM `adwentureworks_db.salesterritory`
  ),

-- Orders information with order data, number of customers, orders and salespersons, total amount with tax

  orders AS (
    SELECT
      TerritoryID,
      LAST_DAY(CAST(OrderDate AS date)) AS order_month,
      COUNT(DISTINCT CustomerID) AS number_customers,
      COUNT(DISTINCT SalesOrderID) AS number_orders,
      COUNT(DISTINCT SalesPersonID) AS no_salesPersons,
      ROUND((SUM(SubTotal) + SUM(TaxAmt) + SUM(Freight))) AS total_w_tax
    FROM `adwentureworks_db.salesorderheader`
    GROUP BY 1,2
  )

--Main querry to show on France customers, with cumulative sums and they ranks

SELECT 
  orders.order_month,
  territories.CountryRegionCode,
  territories.region,
  orders.number_orders,
  orders.number_customers,
  orders.no_salesPersons,
  orders.total_w_tax,
  RANK() OVER (ORDER BY orders.total_w_tax DESC) AS country_sales_ranks,
  SUM(orders.total_w_tax) OVER (PARTITION BY territories.CountryRegionCode ORDER BY orders.order_month) AS cummulative_sum
FROM territories
JOIN orders
  ON territories.TerritoryID = orders.TerritoryID
WHERE territories.CountryRegionCode = 'FR'
ORDER BY orders.total_w_tax DESC
```

###  Task 2.4 

Enrich 2.3 query by adding taxes on a country level:

  - As taxes can vary in country based on province, the needed column is ‘mean_tax_rate’ -> average tax rate in a country.
  - Also, as not all regions have data on taxes, you also want to be transparent and show the ‘perc_provinces_w_tax’ -> a column representing the percentage of provinces with available tax rates for each country (i.e. If US has 53 provinces, and 10 of them have tax rates, then for US it should show 0,19)

```
-- 2.4 gather required fields from different tables using CTE

-- teritories information

WITH 
  territories AS (
    SELECT
      TerritoryID,
      Name AS Region,
      CountryRegionCode
    FROM `adwentureworks_db.salesterritory`
  ),

-- Orders information with order data, number of customers, orders and salespersons, total amount with tax

  orders as (
    SELECT
      TerritoryID,
      LAST_DAY(CAST(OrderDate AS date)) AS order_month,
      COUNT(DISTINCT CustomerID) AS number_customers,
      COUNT(DISTINCT SalesOrderID) AS number_orders,
      COUNT(DISTINCT SalesPersonID) AS no_salesPersons,
      ROUND((SUM(SubTotal) + SUM(TaxAmt) + SUM(Freight)))  AS total_w_tax
    FROM `adwentureworks_db.salesorderheader`
    GROUP BY 1,2
  ),

-- Tax information, mean tax rate and perentage of privinces with tax information
  tax_rate AS (
    SELECT
      state.CountryRegionCode,
      ROUND(AVG(TaxRate),1) AS mean_tax_rate,
      ROUND((COUNT(tax_rate.TaxRate)/Count (state.StateProvinceID)),2) AS perc_provinces_w_tax
    FROM `adwentureworks_db.stateprovince` AS state
    LEFT JOIN  `adwentureworks_db.salestaxrate` AS tax_rate
      ON state.StateProvinceID = tax_rate.StateProvinceID
    GROUP BY 1
  )

-- Main querry with nessasary fields, ranks and cummulative sums, 
SELECT
  orders.order_month,
  territories.CountryRegionCode,
  territories.region,
  orders.number_orders,
  orders.number_customers,
  orders.no_salesPersons,
  orders.total_w_tax,
  RANK() OVER (PARTITION BY territories.CountryRegionCode,territories.region ORDER BY total_w_tax) AS country_sales_rank,
  ROUND(SUM(total_w_tax) OVER (PARTITION BY territories.CountryRegionCode,territories.region ORDER BY order_month )) AS cummulative_sum,
  tax_rate.mean_tax_rate,
  tax_rate.perc_provinces_w_tax
FROM orders
JOIN territories
  ON territories.TerritoryID = orders.TerritoryID
JOIN tax_rate
  ON territories.CountryRegionCode = tax_rate.CountryRegionCode
WHERE territories.CountryRegionCode = 'US'
ORDER BY orders.total_w_tax DESC

```
