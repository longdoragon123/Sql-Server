
USE SampleDB
GO

--1.Tìm những sản phẩm (product) có tên bắt đầu bằng “Chef”
SELECT * FROM Product
WHERE ProductName like 'Chef%'

--2.Tìm những sản phẩm (product) có quy cách (package) là “bottles”
SELECT * FROM Product
WHERE Package LIKE '%bottle%'

--3.Tìm những nhà cung cấp có sản phẩm đã bị discontinued
SELECT distinct supplierid FROM product 
WHERE IsDiscontinued=1

--4.Tìm những nhà cung cấp mà số điện thoại có chứa số 444 
SELECT * FROM  Supplier 
WHERE Phone liKe '%444%'

--5.Tìm những khách hàng nào có hóa đơn xuất trước ngày 15/6/2013
SELECT distinct * FROM [Order]
WHERE OrderDate <'2013-06-15'

------------------//----------------------

--1.tìm danh sách khách hàng và hóa đơn tương ứng (customer join order)
SELECT distinct Customer.LastName,[ORDER].CustomerId,[Order].OrderDate
FROM Customer 
JOIN [Order] ON [Order].Id=Customer.Id

--2.liệt kê hóa đơn với đầy đủ chi tiết (order join  orderitem)
SELECT [Order].*,OrderItem.ProductId,OrderItem.UnitPrice,OrderItem.Quantity
FROM [Order]
JOIN OrderItem ON [Order].Id = OrderItem.OrderId

--3.liệt kệ hóa đơn chi tiết và thông tin sản phâm tương ứng (product và orderitem) 
SELECT OrderItem.*,Product.IsDiscontinued,Product.Package,Product.ProductName,Product.SupplierId,Product.UnitPrice
FROM Product
JOIN OrderItem ON OrderItem.ProductId=Product.Id

--4.liệt kê chi tiết hóa đơn cùng với thông tin nhà cung cấp và khách hàng(supplier,customer,orderitem
SELECT [Order].*,Customer.LastName,Customer.FirstName,Customer.City,Customer.Phone,Supplier.CompanyName,Supplier.ContactName,Supplier.Country,Supplier.Phone
FROM(((OrderItem 
JOIN [Order] ON OrderItem.OrderId=[Order].Id) 
JOIN Supplier ON OrderItem.ProductId=Supplier.Id)
JOIN Customer ON [Order].CustomerId=Customer.Id)
