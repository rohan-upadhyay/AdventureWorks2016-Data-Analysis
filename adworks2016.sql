-- Display all columns from the Person.Person table.

select * from person.person


-- Display the first name, middle name, and last name of all people.

select concat_ws(' ', firstname, middlename, lastname) as FullName from person.Person

-- Find all people whose first name is John.

select firstname, middlename, lastname from person.person
where firstname = 'John'


-- Find all products with a list price greater than 1000.

select Name, ListPrice from production.Product
where listprice > 1000


-- Display products whose color is Black.

select name, color from production.Product
where color = 'black'


-- Find all employees hired after January 1, 2012.

select BusinessEntityID, hiredate from HumanResources.Employee
where hiredate > '2012-01-01'


-- Display products with a list price between 500 and 1000.

select Name, listprice from Production.Product
where listprice between 500 and 1000


-- Find people whose last name starts with S

select BusinessEntityID, firstname, lastname from person.Person
where lastname like 'S%'


-- Find products where the color is either Red or Blue

select Name, color from production.product
where color in ('red','blue')


-- Display the top 10 most expensive products.

select top 10 Name, listprice from production.product
order by listprice desc


-- Find the average product list price.

select name, avg(listprice) as Avg_Listprice from production.product
group by name


-- Find the minimum and maximum product list price.

select min(listprice) as Lowest_price,
max(listprice) as Highest_price
from Production.product

-- Count the total number of products.

select count(*) as Total_products
from production.product


-- Count how many products belong to each product category.

select pc.name, count(pp.ProductID) as product_count from production.product as pp
join production.ProductSubcategory as psc
on pp.ProductSubcategoryID = psc.ProductSubcategoryID
join production.ProductCategory as pc
on psc.ProductCategoryID = pc.ProductCategoryID
group by pc.name


-- Find the average list price for each product category.

select pc.name, avg(pp.listprice) as avg_listprice from production.product as pp
join production.ProductSubcategory as psc
on pp.ProductSubcategoryID = psc.ProductSubcategoryID
join production.ProductCategory as pc
on psc.ProductCategoryID = pc.ProductCategoryID
group by pc.name


-- Find the number of employees in each department.

select hd.groupname, count(hdh.departmentid) as total_employee
from HumanResources.Department as hd
join HumanResources.EmployeeDepartmentHistory as hdh
on hd.DepartmentID = hdh.DepartmentID
group by hd.groupname


-- Find customers who have placed more than 5 orders.

select sc.customerid, count(so.customerid) as Total_order
from sales.customer as sc
join sales.salesorderheader as so
on sc.customerid = so.customerid
group by sc.customerid
having count(so.customerid) > 5
order by total_order


-- Find the total quantity of products sold for each product.

select pp.productid, sum(orderqty) as total_order_sold from production.product as pp
join sales.salesorderdetail as sod
on pp.ProductID = sod.ProductID
group by pp.productid


-- Display product name along with its product category name.

 select psc.Name as ProductName, pc.name as Category  from production.product as pp
join production.ProductSubcategory as psc
on pp.ProductSubcategoryID = psc.ProductSubcategoryID
join production.ProductCategory as pc
on psc.ProductCategoryID = pc.ProductCategoryID
order by pc.name asc


-- Display product name, subcategory name, and category name.

select psc.Name as ProductName, pc.name as Category, psc.Name as Sub_Category
from production.product as pp
join production.ProductSubcategory as psc
on pp.ProductSubcategoryID = psc.ProductSubcategoryID
join production.ProductCategory as pc
on psc.ProductCategoryID = pc.ProductCategoryID
order by Category asc


-- Display sales order ID along with the customer's first and last name.

select soh.salesorderid, soh.orderdate, pp.FirstName, pp.lastName
from sales.SalesOrderHeader as soh
join sales.Customer as sc
on soh.CustomerID = sc.CustomerID
join person.person as pp
on sc.PersonID = pp.BusinessEntityID

-- Display each sales order with the salesperson's name.

select soh.salesorderid, concat_ws(' ', pp.Firstname, pp.Lastname) as SalesPersonName
from sales.salesorderheader as soh
left join sales.salesperson as sp
on soh.SalesPersonID = sp.BusinessEntityID
left join person.Person as pp
on sp.BusinessEntityID = pp.BusinessEntityID
order by soh.SalesOrderID


-- Find all products that have never been sold.

Select pp.productid , count(sod.productid) as Zero_sales
from production.product as pp
left join sales.SalesOrderDetail as Sod
on pp.productid = sod.productid
group by pp.productid
having count(sod.productid) = 0


-- Display employees along with their department names.

select hre.businessentityid, Name as Department_Name from HumanResources.Employee as hre
join HumanResources.EmployeeDepartmentHistory as hred
on hre.BusinessEntityID = hred.BusinessEntityID
join HumanResources.Department as hrd
on hred.DepartmentID = hrd.DepartmentID
order by hre.BusinessEntityID asc


-- Display customers and their corresponding sales territories.

select sc.CustomerID,
sst.[name] as Sales_territory
from sales.customer as sc
join sales.salesterritory as sst
on sc.territoryid = sst.TerritoryID


-- Find the top 10 customers based on total sales amount.

select top 10 sc.customerid, sum(so.TotalDue) as total_amt
from sales.customer as sc
join sales.salesorderheader as so
on sc.customerid = so.customerid
group by sc.customerid
order by total_amt desc


-- Display each order detail with product name, quantity, and unit price.

select sod.SalesOrderID,pp.Name, sod.orderqty, sod.unitprice from Production.product as pp
join sales.SalesOrderDetail as sod
on pp.ProductID = sod.ProductID


-- Find the total sales amount for each product category.

select ppc.name as Category, sum(sod.linetotal) as totalsales
from production.product as pp
join sales.SalesOrderDetail as Sod
on sod.ProductID = pp.ProductID
join production.ProductSubcategory as psc
on pp.ProductSubcategoryID = psc.ProductSubcategoryID
join production.ProductCategory as ppc
on psc.ProductCategoryID = ppc.ProductCategoryID
group by ppc.name
order by totalsales desc


-- Find products whose list price is greater than the average product list price.
-- With (SubQuery & CTE)

select productid, name, listprice
from production.product
where listprice > (select avg(listprice) from production.product)


with cte_avg as
(select avg(listprice) as avg_listprice from production.product)
select p.productid, p.name, p.listprice
from production.product p
cross join cte_avg c
where p.listprice > c.avg_listprice


-- Find the second-highest product list price.
-- With (SubQuery & CTE)

select max(listprice) from production.product
where listprice <
( select max(listprice) from production.product)


with cte_2nd
as
( select listprice,
dense_rank() over (order by listprice desc) as ranks
from production.product)
select top 1 listprice, ranks from cte_2nd
where ranks = 2


-- Find employees whose salary/rate is greater than the average rate for all employees.
select pp.businessentityid,
concat_ws(' ', pp.firstname, pp.middlename, pp.lastname) as Emp_name,
hp.rate from
HumanResources.EmployeePayHistory as hp
join person.Person as pp
on hp.BusinessEntityID = pp.BusinessEntityID
where hp.rate >
(select avg(rate) from HumanResources.EmployeePayHistory)

-- Find customers who have never placed an order.
-- With Normal Query & SubQuery

select sc.customerid, count(sso.salesorderid) as Orders_Never_placed from sales.Customer as sc
left join sales.SalesOrderHeader as sso
on sc.CustomerID = sso.CustomerID
group by sc.CustomerID
having count(sso.salesorderid) = 0


select
    sc.customerid
from sales.customer as sc
where not exists (select 0
    from sales.salesorderheader as sso
    where sso.customerid = sc.customerid)


-- Find the most expensive product in each product category.

with cte_exp
as
( select ppc.name as category,
ppsc.name as subcat,
pp.name as product,
pp.listprice,
rank() over (partition by ppc.productcategoryid order by pp.listprice desc) as PriceRank
from production.Product as pp
join Production.ProductSubcategory as ppsc
on pp.ProductSubcategoryID = ppsc.ProductSubcategoryID
join Production.ProductCategory as ppc
on ppsc.ProductCategoryID = ppc.ProductCategoryID)
select category, subcat, product, listprice from cte_exp
where PriceRank = 1
order by ListPrice desc


-- Find the customer who has spent the most money.

select top 1 customerid, sum(totaldue) as totalspent from sales.SalesOrderHeader
group by CustomerID
order by totalspent desc


-- Find the product with the highest total quantity sold.

select top 1 productid, sum(orderqty) as totalqty from sales.SalesOrderDetail
group by productid
order by totalqty desc


-- Calculate each product's percentage contribution to total sales.

select pp.name, sum(sso.linetotal) as total_price,
cast ( sum(sso.linetotal) * 100 / sum(sum(sso.linetotal)) over() as decimal (10,5)) as percentage_total
from sales.salesorderdetail as sso
join production.product as pp
on sso.productid = pp.productid
group by pp.name
order by percentage_total desc


-- Assign a row number to products ordered by list price from highest to lowest.
-- choosing dense rank over row_number as listprices are same in some cases.

select name, listprice, dense_rank() over (order by listprice desc) as High_to_low
from Production.Product
order by ListPrice desc


-- Rank products based on their list price within each product category.

select ppc.name as category,
pp.name as product,
pp.listprice,
rank() over (partition by ppc.productcategoryid order by pp.listprice desc) as PriceRank
from production.Product as pp
join Production.ProductSubcategory as ppsc
on pp.ProductSubcategoryID = ppsc.ProductSubcategoryID
join Production.ProductCategory as ppc
on ppsc.ProductCategoryID = ppc.ProductCategoryID
order by ppc.name, PriceRank


-- Find the top 3 products by sales within each category.

with cte_3 as (
select sod.productid, sum(sod.linetotal) as tsales,  ppc.name as category,
pp.name as product,
dense_rank() over
(partition by ppc.name order by Sum(sod.linetotal) desc) as Top3_eachCategory
from sales.salesorderheader as soh
join sales.SalesOrderDetail as sod
on soh.SalesOrderID = sod.SalesOrderID
join Production.Product as pp
on sod.ProductID = pp.ProductID
join Production.ProductSubcategory as ppsc
on pp.ProductSubcategoryID = ppsc.ProductSubcategoryID
join Production.ProductCategory as ppc
on ppsc.ProductCategoryID = ppc.ProductCategoryID
group by sod.productid,ppc.name, pp.name
)
select productid,category ,Product,Tsales,Top3_eachCategory
FROM  cte_3
WHERE Top3_eachCategory <= 3


-- Calculate a running total of sales by order date.

with cte_runningtotal
as
( select orderdate, sum(totaldue) as totalsales from sales.SalesOrderHeader
group by orderdate)
select orderdate, totalsales, sum(totalsales) over (order by orderdate) as runningtotal
from cte_runningtotal


-- Compare each product's price with the previous product's price.

with cte_previous as
(select productid, name, sum(listprice) as ProductPrice from production.product
group by productid, name)
select productid, name, productprice, lag(productprice,1)
over (order by productid) as previous_price
from cte_previous


-- Find the highest-selling product for each month.

with cte_hs as
( select pp.name, year(orderdate) as yr, month(orderdate) as mo, sum(totaldue) as totalsales,
dense_rank() over (partition by year(orderdate), month(orderdate) order by sum(totaldue) desc) as rnk
from production.Product as pp
join sales.SalesOrderDetail as sso
on pp.ProductID = sso.ProductID
join sales.SalesOrderHeader as soh
on sso.SalesOrderID = soh.SalesOrderID
group by pp.name, year(orderdate), month(orderdate)
)
select name, yr, mo, totalsales
from cte_hs 
where rnk = 1
order by yr, mo


-- Calculate the percentage of total sales contributed by each sales territory.

select sst.Name, sum(soh.totaldue) as totalsales,
(sum(soh.totaldue) * 100.0) / sum(sum(soh.totaldue)) OVER() as Percentage_Contribution
from sales.SalesOrderHeader as soh
join sales.SalesTerritory as sst
on soh.TerritoryID = sst.TerritoryID
group by sst.name
order by Percentage_Contribution desc

-- Find the difference between each customer's current order amount and their previous order amount.

select customerid, orderdate, totaldue,
lag(totaldue) over ( partition by customerid order by orderdate) as prev_amount,
totaldue - lag(totaldue) over (partition by customerid order by orderdate) as difference_
from sales.SalesOrderHeader
order by customerid, orderdate


-- Which product category generates the most revenue?

select top 1 ppc.name as category,sum(sod.linetotal) as tsales 
from sales.salesorderheader as soh
join sales.SalesOrderDetail as sod
on soh.SalesOrderID = sod.SalesOrderID
join Production.Product as pp
on sod.ProductID = pp.ProductID
join Production.ProductSubcategory as ppsc
on pp.ProductSubcategoryID = ppsc.ProductSubcategoryID
join Production.ProductCategory as ppc
on ppsc.ProductCategoryID = ppc.ProductCategoryID
group by ppc.name
order by tsales desc


-- Which salesperson has generated the highest sales?

select top 1 pp.businessentityid,
concat_ws(' ', pp.Firstname, pp.Middlename, pp.Lastname) as SalesPersonName,
sum(totaldue) as Totalsales from Person.person as pp
join sales.SalesOrderHeader as soh
on pp.BusinessEntityID = soh.SalesPersonID
group by BusinessEntityID, concat_ws(' ', Firstname, Middlename, Lastname)
order by totalsales desc

-- Which month had the highest total sales?

select top 1
month(orderdate) as [month],
sum(totaldue) as Totalsales
from sales.salesorderheader
group by month(orderdate)
order by totalsales desc


-- Which customers have spent more than $10,000?

select customerid, sum(totaldue) as spent
from sales.salesorderheader
group by CustomerID
having sum(totaldue) > 10000


-- Which products are selling the most units but have relatively low prices?

select pp.name, sum(sod.orderqty) as totalunits, pp.listprice as price
from sales.SalesOrderDetail as sod
join Production.Product as pp
on sod.ProductID = pp.ProductID
group by pp.name, pp.listprice
having pp.listprice < ( select avg(listprice) from Production.Product where listprice > 0)
order by totalunits desc


-- Which product categories have an average price above the overall average product price?

select ppc.name, avg(pp.listprice) as cat_avg_price from Production.Product as pp
join production.ProductSubcategory as ppsc
on pp.ProductSubcategoryID = ppsc.ProductSubcategoryID
join production.ProductCategory as ppc
on ppsc.ProductCategoryID = ppc.ProductCategoryID
group by ppc.name
having avg(pp.ListPrice) > 
( select avg(listprice) from production.product where listprice > 0)
order by cat_avg_price

-- Which sales territories have increased sales compared with the previous year?
--(With Cte & SubQuery)

with cte_ipsy
as
( select sst.name as Territory_name,year(soh.orderdate) order_yr, sum(soh.totaldue) as total_sales
from sales.SalesTerritory as sst
join sales.SalesOrderHeader as soh
on sst.TerritoryID = soh.TerritoryID
group by sst.name,year(soh.orderdate)
), comparision
as 
(select Territory_name, order_yr, total_sales,
lag(total_sales) over ( partition by territory_name order by order_yr) as Prev_yr_sales
from cte_ipsy )
select territory_name, order_yr, prev_yr_sales, total_sales  from comparision
where total_sales > prev_yr_sales
order by territory_name, order_yr


select * from(
select sst.name as Territory_name,year(soh.orderdate) order_yr,
lag(sum(soh.totaldue),1) over (partition by sst.name order by year(soh.orderdate)) as prev_yr,
sum(soh.totaldue) as total_sales
from sales.SalesTerritory as sst
join sales.SalesOrderHeader as soh
on sst.TerritoryID = soh.TerritoryID
group by sst.name,year(soh.orderdate)
) as filterr
where total_sales > prev_yr
order by Territory_name , order_yr

-- Find customers who purchased products from at least 3 different categories.

select soh.customerid, count(distinct ppc.productcategoryid)
from sales.salesorderheader as soh
join sales.SalesOrderDetail as sod
on soh.SalesOrderID = sod.SalesOrderID
join production.product as pp
on sod.ProductID = pp.ProductID
join production.ProductSubcategory as ppsc
on pp.ProductSubcategoryID = ppsc.ProductSubcategoryID
join Production.ProductCategory as ppc
on ppsc.ProductCategoryID = ppc.ProductCategoryID
group by soh.customerid
having count(distinct ppc.productcategoryid) >= 3

-- Find the top 5 customers in each sales territory.
-- (With Normal Query & CTE)

select * from (select  sc.customerid, sst.territoryid, sst.name as SalesTerritory,
sum(soh.totaldue)as Total_sales,
row_number() over (partition by sst.territoryid order by sum(soh.totaldue)desc) as hs
from sales.salesorderheader as soh
join sales.Customer as sc
on soh.CustomerID = sc.CustomerID
join sales.SalesTerritory as sst
on sc.TerritoryID = sst.TerritoryID
group by sc.customerid, sst.territoryid, sst.name)
as sales
where hs <=5
order by SalesTerritory,Total_sales desc

with customer_sales as
( select sc.customerid, sst.territoryid, sst.name as territory_name,
sum(soh.totaldue) as total_sales,
row_number() over (partition by sst.territoryid order by sum(soh.totaldue)desc) as rn
from sales.salesorderheader as soh
join sales.customer as sc
on soh.customerid = sc.customerid
join sales.salesterritory as sst
on sc.territoryid = sst.territoryid
group by sc.customerid, sst.territoryid, sst.name )
select customerid, territoryid, territory_name,total_sales
from customer_sales
where rn <= 5
order by territory_name, total_sales desc

-- Identify products that have high inventory but very low sales.

select ppi.productid, pp.name,sum(ppi.quantity) as totalinventoryqty,
coalesce(sum(sso.orderqty), 0) as totalsalesqty
from production.productinventory as ppi
join production.product as pp
on ppi.productid = pp.productid
left join sales.salesorderdetail as sso
on pp.productid = sso.productid
group by ppi.productid,pp.name
having sum(ppi.quantity) >= 500 and coalesce(sum(sso.orderqty), 0) <= 10
order by totalinventoryqty desc

-- Calculate year-over-year sales growth.

with cte_yoy
as
(select year(orderdate) as OrderYear, sum(totaldue) as TotalSales
from sales.salesorderheader
group by year(orderdate)
),
cte_yoy2
as
(select orderyear, totalsales,
lag(totalsales,1)
over (order by  orderyear) as previousyearsales
from cte_yoy)
select orderyear, totalsales,previousyearsales,
format((totalsales -previousyearsales) / previousyearsales, 'P') as YoY
from cte_yoy2


--Create a report showing Category → Product → Quantity Sold → Revenue → Rank within Category.

select pp.productid, pp.name as Product_Name,ppc.name as category,
dense_rank() over (partition by ppc.name order by sum(sod.linetotal) desc) as Cat_Rank,
sum(sod.orderqty) as QtySold,
sum(sod.LineTotal) as Revenue
from sales.SalesOrderDetail as sod
join production.product as pp
on sod.ProductID = pp.ProductID
join production.ProductSubcategory as ppsc
on pp.ProductSubcategoryID = ppsc.ProductSubcategoryID
join Production.ProductCategory as ppc
on ppsc.ProductCategoryID = ppc.ProductCategoryID
group by ppc.name, pp.ProductID, pp.Name

