USE SampleDB
GO
--1.Tạo bảng customer_new có cấu trúc giống bảng customer
SELECT * 
INTO Customer_new
FROM Customer

--2.Insert customer vào customer_new, chỉ lấy những customer nào thuộc các quốc gia sau: Argentina,Austria,Belgium,Brazil,Canada,Denmark,Finland,France,Germany,Ireland
SELECT FirstName, LastName, City, Country, Phone
FROM Customer
WHERE Country IN ('Argentina','Austria','Belgium','Brazil','Canada','Denmark','Finland','France','Germany','Ireland')


--3.Xóa những khách hàng trong customer_new thuộc quốc gia Canada,Denmark,Finland
DELETE FROM Customer
WHERE Country = 'CANADA' OR Country = 'DENMARK' OR Country='FINLAND'

--4.Cập nhật số điện thoại của các khách hàng trong table customer_new thuộc thành phố Austria,Belgium thành 111222333
UPDATE Customer_new
SET Phone = '111222333'
WHERE Country = 'Austria' or Country = 'Belgium'

--5.Xóa những khách hàng không thuộc Argentina và có hóa đơn xuất sau ngày 15/6/2013
DELETE Customer
FROM Customer INNER JOIN [Order] ON Customer.Id = [Order].Id
WHERE Country <> 'Argentina' AND OrderDate > '2013-06-15'

--6.  + copy cấu trúc/data supplier thành supplier_100
	
SELECT *
INTO supplier_100
FROM supplier
	--+ xóa những supplier trong table supplier_100 với dk là những product mà họ cũng cấp bị discountinue (IsContinue=1)
DELETE FROM Supplier_100
FROM Supplier_100 INNER JOIN Product 
ON Supplier_100.Id=Product.SupplierId
WHERE IsDiscontinued=1

--7.+ tạo mới product_100 từ product
SELECT * 
INTO product_100
FROM Product

--8.+ cập nhật product.ProductName = 'Name: '
--productName đối với nhựng product nào có số lượng bán lớn hơn 5 (quantity>5)
select * from product_100
UPDATE product_100
SET [NAME] = 'Name'
FROM product_100  INNER JOIN OrderItem ON product_100.Id = OrderItem.ProductId
WHERE Quantity > 5

--9.Update supplier có country = USA thành America và có sản phẩm bị discontinue
UPDATE Supplier
SET Country = 'America' 
FROM Supplier S INNER JOIN Product ON S.Id = Product.SupplierId
WHERE Country='USA' AND IsDiscontinued=1

---------------------------------------------------------------------------------------------------
select * from Customer_new
--1.Thống kê số thành phố theo từng quốc gia của khách hàng
SELECT Country,COUNT(City) as city_by_country
FROM Customer
GROUP BY Country

--2.       Thống kê số khách hàng theo từng thành phố và theo từng quốc gia
SELECT COUNT(Id),Country,City
FROM Customer
GROUP BY Country,City

--3.       Liệt kê danh sách QUỐC GIA, nếu khách hàng thuộc về quốc gia có 3 thành phố thì thuộc loại Level1, có 2 thành phố thì thuộc loại level 2, còn lại là level 3
SELECT COUNT(City) AS TOTAL_CITY, Country,
	IIF(COUNT(City)=3,'LEVEL 1',IIF(COUNT(CITY)=2,'LEVEL 2','LEVEL 3')) AS COUNTRY_TYPE
FROM Customer 
GROUP BY Country
ORDER BY Country

--4. Nếu hóa đơn nào mua từ 10 sản phẩm trở lên, cập nhập LoaiHoaDon = “Premium”, từ 6 đến 10 là “Gold”, từ 4 đến 5 là “Sliver”, còn lại là “Normal”

SELECT	OrderId,
		IIF(COUNT(ProductId)>10,'LOAI HOA DON',IIF(COUNT(ProductId) BETWEEN 6 AND 10,'GOLD',IIF(COUNT(ProductId) BETWEEN 4 AND 5,'SLIVER','NORMAL'))) AS ORDER_TYPE
INTO ORDER_ITEM_SUMUP
FROM OrderItem
GROUP BY OrderId

UPDATE O
	SET LoaiHoaDon=OS.OrderType
FROM [Order] O INNER JOIN ORDER_ITEM_SUMUP OS ON O.Id=OS.OrderId

--5. Thêm column “ChietKhau” vào table [ItemDetail]. Cập nhật giá trị như sau, đối với sản phẩm nào có giá trên 50$ thì chiết khẩu 15%, từ 25 đến 50 thì 10% và 10 đến 25 thì 5% và còn lại giữ nguyên
ALTER TABLE ORDERITEM ADD ChietKhau FLOAT
UPDATE OrderItem
SET ChietKhau = IIF(UnitPrice > 50,0.85,IIF(UnitPrice BETWEEN 25 AND 50,0.9,IIF(UnitPrice BETWEEN 10 AND 24,0.95,1)))

--6.       Thêm column “GiaSauChietKhau”, cap nhật giá trị GiaSauChietKhau = UnitPrice x ChietKhau
SELECT * FROM OrderItem
ALTER TABLE ORDERITEMP ADD GiaSauChietKhau FLOAT
UPDATE OrderItem
	SET GiaSauChietKhau = UnitPrice*ChietKhau

--7.       Đếm tổng số sản phẩm bán được theo từng loại của từng nhà cung cấp
SELECT SupplierId ,COUNT(Product.Id) AS 'SUM' 
FROM Product
GROUP BY SupplierId

--9.Cho biết danh sách những nhà cũng cấp nào không có bán sản phẩm
SELECT * FROM Product WHERE Id NOT IN (SELECT DISTINCT ProductId FROM OrderItem)  

--10.   Tạo bảng customer_backup và chuyển dữ liệu từ customer vào. Xóa dữ liệu trên customer_backup những khách hàng nào thuộc Germany, Agrentina không có mua hàng trong năm 2013
SELECT * INTO customer_backup FROM Customer
DELETE customer_backup
FROM customer_backup INNER JOIN [Order] ON customer_backup.Id=[Order].CustomerId
WHERE COUNTRY IN ('GERMANY','Agrentina') AND YEAR(OrderDate)=2013

select * from customer_backup
--11.   Cho biết doanh số bán được theo tháng năm và theo từng quốc gia
SELECT * FROM [Order]
--
SELECT
	YEAR(OrderDate)*100+MONTH(OrderDate) AS Month_Year,
	country,
	SUM(TotalAmount) AS TOTAL_AMOUNT
FROM [Order]
	INNER JOIN Customer ON [Order].CustomerId=Customer.Id
GROUP BY Country,YEAR(OrderDate)*100+MONTH(OrderDate)

--12.   Cho biết quốc gia nao mua hàng nhiều nhất trong 6 tháng đầu năm 2013
;WITH CTE 
AS 
(
	SELECT Country,SUM(TotalAmount) TOTAL_AMOUNT
	FROM [Order] O INNER JOIN Customer C ON O.CustomerId=C.Id 
	WHERE YEAR(OrderDate)=2013 AND MONTH(OrderDate)<=6
	GROUP BY Country
)
SELECT TOP 1 * 
FROM CTE
ORDER BY TOTAL_AMOUNT DESC

--13.   Cho biết thành phố nào thuộc các quốc gia không phải Germany có doanh số cao nhất trong năm 2012
;WITH NOT_GERMANY
AS
(
	SELECT City,Country,SUM(TotalAmount) DOANH_SO_CAO_NHAT 
	FROM [Order] O INNER JOIN Customer C ON O.CustomerId=C.Id
	WHERE City <>'Germany' AND YEAR(OrderDate)=2012
	GROUP BY City,Country
)
SELECT TOP 1 * FROM NOT_GERMANY
ORDER BY DOANH_SO_CAO_NHAT 
--14.   Tạo thêm column “LoaiNhaCungCap”, với giá trị như sau: “Nhà Cung Cấp Sỉ” nếu có số mặt hàng bán được trên 10, ngược lại là “Nhỏ Lẻ”
CREATE VIEW LOAI_NHA_CUNG_CAP AS 
SELECT Supplier.Id, SUM(ORDERITEM.QUANTITY) AS TONG_SP_BAN_DUOC,
CASE WHEN SUM(ORDERITEM.QUANTITY) >1000 THEN 'NHA CUNG CAP SI' ELSE 'NHO LE' END AS LOAI_NHA_CUNG_CAP
FROM ORDERITEM JOIN PRODUCT ON ORDERITEM.PRODUCTID = PRODUCT.ID
JOIN Supplier ON Product.SupplierId=Supplier.Id
GROUP BY Supplier.Id

ALTER TABLE SUPPLIER ADD LOAI_NHA_CUNG_CAP NVARCHAR (100)

UPDATE Supplier 
SET SUPPLIER.LOAI_NHA_CUNG_CAP = LOAI_NHA_CUNG_CAP.LOAI_NHA_CUNG_CAP
FROM Supplier JOIN LOAI_NHA_CUNG_CAP ON Supplier.Id=LOAI_NHA_CUNG_CAP.ID

SELECT * FROM LOAI_NHA_CUNG_CAP
--15.   Them column “TotalNetAmount” trên Hóa Đơn, và tính tổng tiền với giá trị như sau: đơn giá x chiết khẩu x số lượng
SELECT * FROM [OrderItem]
SELECT * FROM [Order]

ALTER TABLE [ORDER] ADD TotalNetAmount FLOAT
;WITH CTE
AS
(
	SELECT SUM(UnitPrice*ChietKhau*Quantity) AS SUM_MONEY
	FROM [OrderItem]
)
SELECT SUM(SUM_MONEY) FROM [CTE]
--16.   Cho biết những đơn hàng nào có tổng số lượng sản phẩm lớn 10
SELECT * FROM OrderItem
SELECT SUM(Quantity) SUMOFQUANTITY,OrderId
FROM [OrderItem]
GROUP BY OrderId
HAVING SUM(Quantity) >10
ORDER BY OrderId

--17.  Cho biết những đơn hàng nào có tổng mặt hàng lớn hơn 5 hoặc có giá trị trung bình hơn 50$
SELECT	OrderId,
		COUNT(Quantity) NUMBER_OF_PRODUCT,
		AVG(UnitPrice*Quantity) AVG_OF_ORDER
FROM OrderItem
GROUP BY OrderId
HAVING COUNT(ProductId)>5 OR AVG(UnitPrice*Quantity)>50
ORDER BY OrderId