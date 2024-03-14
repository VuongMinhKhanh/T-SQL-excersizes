use adventureworks2019
go

-- chuong 1
-- tao csdl
create database csdl1
on primary
(
	name = 'test_db',
	filename = 'D:\test_db.mdf',
	size = 10MB,
	filegrowth = 20%,
	maxsize = 50mb

),
filegroup newFileGroup
(
	name = 'test_db1',
	filename = 'D:\test_db1.ndf',
	size = 10MB,
	filegrowth = 20%,
	maxsize = 50mb
)

-- chuong 2
-- 1
select d.SalesOrderID, OrderDate, SubTotal=SUM(OrderQty*UnitPrice)
from Sales.SalesOrderDetail d join Sales.SalesOrderHeader h 
on d.SalesOrderID = h.SalesOrderID
where year(OrderDate) = 2012 and month(OrderDate) = 6
group by d.SalesOrderID, Orderdate
having SUM(OrderQty*UnitPrice) > 70000


-- 2
select st.TerritoryID, CountOfCust = Count(c.CustomerID), SubTotal = SUM(OrderQty*UnitPrice)
from Sales.SalesTerritory st join Sales.Customer c  
on st.TerritoryID = c.TerritoryID
join Sales.SalesOrderHeader h
on st.TerritoryID = h.TerritoryID 
join Sales.SalesOrderDetail d
on d.SalesOrderID = h.SalesOrderID 
where st.CountryRegionCode = 'US'
group by st.TerritoryID

-- 3
select SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)
from Sales.SalesOrderDetail
where CarrierTrackingNumber like '4BD%'
group by SalesOrderID, CarrierTrackingNumber


-- 4
select p.ProductID, name, AverageOfQty=AVG(OrderQty)
from Production.Product p join Sales.SalesOrderDetail s
on p.ProductID = s.ProductID
where UnitPrice < 25
group by p.ProductID, name
having AVG(OrderQty) > 5


--5
select JobTitle, CountOfPerson = Count(*)
from HumanResources.Employee
group by JobTitle
having Count(*) > 20


--6
select v.BusinessEntityID, v.name, pv.ProductID, SumOfQty=SUM(OrderQty), SubTotal=SUM(OrderQty*UnitPrice)
from Purchasing.vendor v join Purchasing.ProductVendor pv
on v.BusinessEntityID = pv.BusinessEntityID
join Purchasing.PurchaseOrderDetail pd
on pv.ProductID = pd.ProductID
join Purchasing.PurchaseOrderHeader ph
on pd.PurchaseOrderID = ph.PurchaseOrderID
where v.name like '%Bicycles'
group by v.BusinessEntityID, v.name, pv.ProductID
having SUM(OrderQty*UnitPrice) > 800000


--7
select p.productID, name, CountOfOrderID = Count(sh.SalesOrderID), SubTotal=SUM(OrderQty*UnitPrice)
from Production.Product p join Sales.SalesOrderDetail sd
on p.ProductID = sd.ProductID
join Sales.SalesOrderHeader sh
on sd.SalesOrderID = sh.SalesOrderID
where Month(OrderDate) between 1 and 3 
group by p.productID, name
having Count(sh.SalesOrderID) > 500 and SUM(OrderQty*UnitPrice) > 10000


--8
use AdventureWorks2019
go
select p.BusinessEntityID, FullName = FirstName + ' ' + Lastname, 
CountOfOrders = Count(SalesOrderID)
from Person.Person p join Purchasing.ProductVendor pv
on p.BusinessEntityID = pv.BusinessEntityID
join Sales.SalesOrderDetail sd
on pv.ProductID = sd.ProductID
group by p.BusinessEntityID, FirstName, Lastname
having Count(SalesOrderID) > 25


--9 


-- subquery
--1
select ProductID, name
from Production.Product
where exists (
	Select Sum(OrderQty)
	from Sales.SalesOrderDetail sd join Sales.SalesOrderHeader sh
	on sd.SalesOrderID = sh.SalesOrderID
	where Year(OrderDate) > 2007
	having Sum(OrderQty) > 100
) 


--2
select ProductID, name
from Production.Product
where productID = (
	Select top 1 productID
	from Sales.SalesOrderDetail sd join Sales.SalesOrderHeader sh
	on sd.SalesOrderID = sh.SalesOrderID
	where Year(OrderDate) = 2012 and Month(OrderDate) = 7
	Order by OrderQty DESC
)


-- View
--1
create view dbo.vw_Products 
as
select p.ProductID, name, color, size, style, p.StandardCost, enddate, Startdate
from Production.Product p join Production.productCostHistory h
on p.ProductID = h. productID
go
select * from dbo.vw_products

--2
create view List_product_view as
select p.ProductID, name, CountOfOrderID = Count(sd.SalesOrderID), SubTotal=SUM(OrderQty*UnitPrice)
from Production.Product p join Sales.SalesOrderDetail sd
on p.ProductID = sd.ProductID
join Sales.SalesOrderHeader sh
on sd.SalesOrderID = sh.SalesOrderID
where month(OrderDate) between 1 and 3
group by p.ProductID, name
having Count(sd.SalesOrderID) > 500 and SUM(OrderQty*UnitPrice) > 10000
go
select * from List_product_view


--3
create view dbo.vw_CustomerTotals as
select c.CustomerID, Year(OrderDate) as OrderYear, orderMonth = Month(OrderDate), TotalDue = Sum(TotalDue)
from Sales.Customer c join Sales.SalesOrderHeader sh
on c.CustomerID = sh.CustomerID
join Sales.SalesOrderDetail sd
on sd.SalesOrderID = sh.SalesOrderID
group by c.customerID, Year(OrderDate), Month(OrderDate)
go
select * from dbo.vw_CustomerTotals


--4
create view TotalQuantity as
select SalesPersonID, OrderYear = Year(OrderDate), SumOfOrderQty = Sum(OrderQty)
from Sales.SalesPerson sp join Sales.SalesOrderHeader sh
on sp.BusinessEntityID = sh.SalesPersonID
join Sales.SalesOrderDetail sd
on sd.SalesOrderID = sh.SalesOrderId
group by SalesPersonID, Year(OrderDate)
go
select * from TotalQuantity


--5
create view ListCustomer_view as
select c.CustomerID, FullName = FirstName + ' ' + Lastname, CountOfOrder = Count(SalesOrderID)
from Sales.Customer c join Sales.SalesOrderHeader sh
on c.CustomerID = sh.CustomerID
join Person.Person p 
on p.BusinessEntityID = c.PersonID
where Year(OrderDate) between 2012 and 2013
group by c.CustomerID, FirstName, LastName
having Count(SalesOrderID) > 25
go 
select * from ListCustomer_view

--6
CREATE VIEW ListProduct_view as
select p.ProductID, name, SumOfOrderQty = Sum(OrderQty), OrderYear = Year(OrderDate)
from Production.Product p join Sales.SalesOrderDetail sd
on p.ProductID = sd.ProductID
join Sales.SalesOrderHeader sh
on sd.SalesOrderID = sh.SalesOrderID
where name like 'Bike%' or name like 'Sport%'
group by p.productID, name, Year(OrderDate)
having Sum(OrderQty) > 50
go
select * from ListProduct_view


--7
create view List_department_view as
select d.DepartmentID, name, AvgOfRate = AVG(rate)
from HumanResources.Department d join HumanResources.EmployeeDepartmentHistory ed
on d.DepartmentID = ed.DepartmentId
join HumanResources.EmployeePayHistory ep
on ed.BusinessEntityID = ep.BusinessEntityID
group by d.DepartmentID, name
having AVG(rate) > 30
go
select * from List_department_view


--8
create view Sales.vw_OrderSummary with encryption as
select OrderYear = Year(orderDate), OrderMonth = Month(OrderDate), OrderTotal = Sum(TotalDue)
from Sales.SalesOrderHeader
group by Year(orderDate), Month(OrderDate)
go
select * from Sales.vw_OrderSummary

--9
