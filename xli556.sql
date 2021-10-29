--Q1
-- Full name: Xiaolin Li
-- AUID: 455398598
-- Username: xli556

--Q2
SELECT ProductID AS 'Product ID', ProductName AS 'Product name', SupplierID AS 'Supplier ID', CategoryID AS 'Category ID', QuantityPerUnit AS 'Quantity Per Unit', UnitPrice AS 'Unit Price', UnitsInStock AS 'Units In Stock', UnitsOnOrder AS 'Units On Order', ReorderLevel AS 'Reorder Level', Discontinued
FROM Product;

--Q3
SELECT ProductName, UnitPrice, UnitsInStock
FROM Product
ORDER BY UnitPrice DESC;

--Q4
SELECT Phone
FROM Shipper
WHERE CompanyName LIKE 'United Package';

--Q5
SELECT *
FROM Customer
WHERE FAX IS NOT NULL;

--Q6
SELECT *
FROM [Order]
WHERE OrderDate LIKE '1996-07%';

--Q7
SELECT DISTINCT Country
FROM Customer;

--Q8
SELECT COUNT(*) AS 'Numbers of Order'
FROM [Order];

--Q9
-- without functions
SELECT ProductName
FROM Product
WHERE ProductName LIKE '_____';
-- with functions
SELECT ProductName
FROM Product
WHERE LENGTH(ProductName) = 5;

--Q10
SELECT ProductName, UnitsInStock
FROM Product
ORDER BY UnitsInStock DESC
LIMIT 10;

--Q11
SELECT UPPER(LastName)||', '||FirstName AS 'Full name', Address||', '||City||' '||PostalCode||', '||Country AS 'Full Address'
FROM Employee;

--Q12
SELECT OrderID, ProductID, '$'||UnitPrice AS 'UnitPrice', Quantity, (Discount*100)||'%' AS 'Discount', '$'||(UnitPrice * Quantity * (1 - Discount)) AS 'Subtotal'
FROM OrderDetail
WHERE OrderID = 10250;

--Q13
SELECT ProductName, CategoryID, UnitPrice, Discontinued
FROM Product
WHERE ProductName LIKE 'C%' 
AND CategoryID IN (1,2)
AND UnitPrice > 20
AND Discontinued = 0;

--Q14
INSERT INTO Shipper(CompanyName, Phone)VALUES('Trustworthy Delivery', '(503) 555-1122');
INSERT INTO Shipper(CompanyName, Phone)VALUES('Amazing Pace', '(503) 555-3421');
INSERT INTO Shipper(CompanyName, Phone)VALUES('Xiaolin Li', '(503) 455-3985');

--Q15
SELECT LastName, FirstName, CAST(STRFTIME('%Y.%m%d', 'now') - STRFTIME('%Y.%m%d', BirthDate) AS INT) AS 'Age'
FROM Employee;

--Q16
UPDATE Employee
SET LastName = 'Fuller', TitleOfCourtesy = 'Mrs.'
WHERE FirstName LIKE 'Nancy' AND LastName LIKE 'Davolio';

--Q17
UPDATE Employee
SET Address = (SELECT Address
			   From Employee
			   Where FirstName LIKE 'Andrew' AND LastName LIKE 'Fuller'), 
	City = (SELECT City
			From Employee
			Where FirstName LIKE 'Andrew' AND LastName LIKE 'Fuller'), 
	[Region] = (SELECT [Region]
				From Employee
				Where FirstName LIKE 'Andrew' AND LastName LIKE 'Fuller'), 
	PostalCode = (SELECT PostalCode
				  From Employee
				  Where FirstName LIKE 'Andrew' AND LastName LIKE 'Fuller'), 
	HomePhone = (SELECT HomePhone
				 From Employee
				 Where FirstName LIKE 'Andrew' AND LastName LIKE 'Fuller')
WHERE FirstName LIKE 'Nancy' AND LastName LIKE 'Fuller';

--Q18
CREATE TABLE ProductHistory
(ProductID INTEGER NOT NULL,
 EntryDate DATE NOT NULL,
 UnitPrice REAL,
 UnitsInStock INTEGER,
 UnitsOnOrder INTEGER,
 ReorderLevel INTEGER,
 Discontinued INTEGER NOT NULL,
 PRIMARY KEY(ProductID,EntryDate),
 FOREIGN KEY(ProductID)REFERENCES Product(ProductID)
 ON UPDATE NO ACTION ON DELETE NO ACTION
);

--Q19
INSERT INTO ProductHistory(ProductID, EntryDate, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued)
SELECT ProductID, DATETIME('now','localtime'),UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued
FROM Product;

--Q20
SELECT CASE 
WHEN STRFTIME('%w',HireDate) == '0' THEN 'Sunday'
WHEN STRFTIME('%w',HireDate) == '1' THEN 'Monday'
WHEN STRFTIME('%w',HireDate) == '2' THEN 'Tuesday'
WHEN STRFTIME('%w',HireDate) == '3' THEN 'Wednesday'
WHEN STRFTIME('%w',HireDate) == '4' THEN 'Thursday'
WHEN STRFTIME('%w',HireDate) == '5' THEN 'Friday'
WHEN STRFTIME('%w',HireDate) == '6' THEN 'Saturday'
END AS 'Day of Week', COUNT(STRFTIME('%w',HireDate)) AS 'Hired'
FROM Employee
GROUP BY [Day of Week];

--Q21
SELECT e.LastName, e.FirstName, '$'||MAX(oo.TotalNumber) AS 'Total'
FROM Employee e
LEFT OUTER JOIN (SELECT o.EmployeeID, o.OrderID, SUM((od.UnitPrice * od.Quantity)  * (1 - od.Discount)) AS 'TotalNumber'
			     FROM [ORDER] o
			     LEFT JOIN OrderDetail od
			     ON o.OrderID = od.OrderID
			     GROUP BY o.EmployeeID
			     ORDER BY o.EmployeeID) oo
ON e.EmployeeID = oo.EmployeeID;

--Q22
SELECT e.FirstName AS 'Employee', IFNULL(em.FirstName, 'No manager') AS 'Manager'
FROM Employee e
LEFT OUTER JOIN Employee em
ON e.ReportsTo = em.EmployeeID;

--Q23
SELECT c.CompanyName AS 'Company', '$'||ROUND(SUM(p.UnitPrice * od.Quantity),2) AS 'Recommended', 
'$'||ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)),2) AS 'Ordered', 
'$'||ROUND(ABS(SUM(p.UnitPrice * od.Quantity) - SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))),2) AS 'Discount', 
ROUND(100 * (ABS(SUM(p.UnitPrice * od.Quantity) - SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)))/SUM(p.UnitPrice * od.Quantity)),2)||'%' AS 'Percentage'
FROM Customer c, Product p, OrderDetail od, [Order] o
WHERE c.CustomerID = o.CustomerID AND o.OrderID = od.OrderID AND od.ProductID = p.ProductID
GROUP BY c.CompanyName
ORDER BY ROUND(100 * (ABS(SUM(p.UnitPrice * od.Quantity) - SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)))/SUM(p.UnitPrice * od.Quantity)),2) DESC;

--Q24
SELECT oos.ShipCountry, s.CompanyName
FROM Shipper s
LEFT OUTER JOIN (

SELECT o.ShipCountry, oo.ShipCountry, o.ShipVia, oo.ShipVia, max(oo.Fs)as MaxFs
FROM [Order] o
INNER JOIN (

SELECT ShipCountry, ShipVia, sum(Freight)as fs
FROM [Order] 
GROUP BY ShipCountry, ShipVia)oo

ON o.ShipVia = oo.ShipVia and o.ShipCountry = oo.ShipCountry
GROUP BY oo.ShipCountry) oos

ON s.ShipperID = oos.ShipVia 
WHERE oos.ShipCountry IS NOT NULL
ORDER BY CompanyName;