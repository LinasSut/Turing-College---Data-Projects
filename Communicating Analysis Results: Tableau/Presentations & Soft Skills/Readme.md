# Presentation & Soft Skills 

### Main requirements 

You are asked to provide 1 dashboard or spreadsheet which you will then use for 2 presentations for each of the departments. If you wish, you can have 2 slightly modified versions of the dashboard / spreadsheet to better suit each of the two presentations.

Keep in mind that both presentations and spreadsheet /dashboard should be prepared with your audience in mind. Make sure that you apply what you learned in this sprint and that you can provide not only data but also insights and communicate them.

For the analysis the data about orders, products, salespersons, teritories were extracted using code below

```
-- Gathering sales order data each orders order line table and creating online/offline column			
			
WITH			
  orders AS (			
  SELECT			
    DATE(OrderDate) as orderdate,			
    salesorders.SalesOrderID,			
    salesorders.CustomerID,			
    salesorders.SalesPersonID,			
    salesorders.TerritoryID,			
    salesordersdetails.productid,			
    CASE			
      WHEN SalespersonID IS NULL			
      THEN 'Online'			
      ELSE 'Offline'			
      END as Online_flag,			
    ROUND(SUM(TotalDue),2) as TotalDue,			
    SUM(salesordersdetails.unitprice) as unitprice,			
    SUM(salesordersdetails.orderqty) as Quantity,			
    SUM(salesordersdetails.linetotal) as Linetotal			
  FROM `adwentureworks_db.salesorderheader` AS salesorders			
  JOIN `adwentureworks_db.salesorderdetail` AS salesordersdetails			
    ON salesorders.SalesOrderID = salesordersdetails.SalesOrderID			
  GROUP BY orderdate,salesorders.SalesOrderID,salesorders.CustomerID,salesorders.SalesPersonID,salesorders.TerritoryID,salesordersdetails.productid,Online_flag			
),			
			
-- Product information about product categories, subcategories and product.			
			
Products AS (			
  SELECT			
    Product.ProductID,			
    Product_category.name as product_category,			
    product_subcategory.name AS product_subcategory,			
    Product.StandardCost AS standard_cost,			
    Product.ListPrice AS listprice			
  FROM `adwentureworks_db.product` AS Product			
  LEFT JOIN `adwentureworks_db.productsubcategory` as product_subcategory			
    ON Product.productsubcategoryid = product_subcategory.productsubcategoryid			
  LEFT JOIN `adwentureworks_db.productcategory` as Product_category			
    ON product_subcategory.productcategoryid = Product_category.productcategoryid			
			
),			
			
-- Salespersons information used to know with sales order assigned to each salesperson			
			
salespersons AS (			
  SELECT			
    salesperson.SalesPersonID as salespersons_id,			
    CONCAT(contact.Firstname,' ',contact.LastName) as salespersons_name			
  FROM `adwentureworks_db.salesperson` as salesperson			
  JOIN `adwentureworks_db.employee` as employee			
    ON salesperson.SalesPersonID = employee.EmployeeId			
  JOIN `adwentureworks_db.contact` as contact			
    ON employee.ContactID = contact.ContactId			
),			
			
-- Regional information about each sales order.			
			
territories AS (			
  SELECT			
    TerritoryID,			
    CountryRegionCode			
  FROM `adwentureworks_db.salesterritory`			
)			
			
-- Main Querry with joined CTE for the analysis			
			
SELECT			
  orders.orderdate as Order_date,			
  orders.salesorderid as sales_order_id,			
  Orders.online_flag,			
  orders.totaldue,			
  salespersons.salespersons_name,			
  territories.countryregioncode,			
  products.product_category,			
  products.product_subcategory,			
  orders.linetotal,			
  orders.quantity,			
  orders.unitprice,			
  products.standard_cost,			
  products.listprice,			
  ROUND((orders.quantity * products.standard_cost),2) AS orderline_standard_cost,			
  ROUND((orders.linetotal - (orders.quantity * products.standard_cost)),2) AS orderline_profit			
FROM Orders			
LEFT JOIN products			
  ON orders.productid = products.productid			
LEFT JOIN salespersons			
  ON orders.salespersonid = salespersons.salespersons_id			
LEFT JOIN territories			
  ON orders.territoryid = territories.territoryid			
```

## Tableau Report

With SQL-extracted data now seamlessly presented in Tableau, the addition of a "Know More" button empowers Sales Department managers to explore specific channels in greater detail. This interactive feature facilitates a more in-depth analysis, allowing for informed decisions and strategic optimizations in sales and revenue.

The Tableau report can be found [Here](https://public.tableau.com/app/profile/linas.sutkaitis/viz/AdwentureWorks_DashboardsM2S2/ExecutiveDashboard) 


## Presentations 
###  Executives Overview - Performance of 2004 Q2 

Providing executives with a detailed look at Q2 2004 sales, revenue, and profit compared to Q1 is crucial for smart decision-making. It helps identify what's working and what needs attention in offline and online channels. This information guides strategic choices, revealing trends and patterns that impact overall financial health. 

Understanding the dynamics between channels allows for targeted interventions and resource allocation. Comparing Q2 and Q1 highlights seasonality, market shifts, and strategy effectiveness, empowering executives to make data-driven decisions for optimized sales and profitability. This knowledge is vital in adapting strategies for growth and competitiveness in a changing business landscape.

The final presentation and the main insighrs can be found [Here](https://docs.google.com/presentation/d/12lFFN1rJ3G0yMLqp_-W3sF97WdygI30OdJoX73FcZpc/edit?usp=sharing)

###  Sales Department Overview - Performance of 2004 Q2 

For Sales department managers, understanding the Q2 2004 performance compared to Q1 is crucial. The data on sales, revenue, and profit across offline and online channels, along with insights into product categories, allows them to fine-tune strategies. 

This information helps identify successful trends, allocate resources effectively, and make real-time adjustments to meet sales targets. In essence, it equips managers with actionable intelligence to optimize sales efforts and maximize revenue, contributing to the overall success of the Sales department.

The final presentation and the main insighrs can be found [Here](https://docs.google.com/presentation/d/1trcu58GxVKJE6_FZ8zfOykXEQUgg7LyvbOhPoLBHOF8/edit?usp=sharing)






