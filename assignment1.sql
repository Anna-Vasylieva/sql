--set search_path to shop;
--
--CREATE TABLE Customers (
--    CustomerID SERIAL PRIMARY KEY,
--    FullName VARCHAR(100),
--    Email VARCHAR(100),
--    Phone VARCHAR(20)
--);
--
--CREATE TABLE Flowers (
--    FlowerID SERIAL PRIMARY KEY,
--    FlowerName VARCHAR(100),
--    Price DECIMAL(10,2)
--);
--
--CREATE TABLE Bouquets (
--    BouquetID SERIAL PRIMARY KEY,
--    BouquetName VARCHAR(100),
--    Price DECIMAL(10,2),
--    FlowerID INT,
--    FOREIGN KEY (FlowerID) REFERENCES Flowers(FlowerID)
--);
--
--CREATE TABLE Orders (
--    OrderID SERIAL PRIMARY KEY,
--    CustomerID INT,
--    BouquetID INT,
--    OrderDate DATE,
--    Quantity INT,
--    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
--    FOREIGN KEY (BouquetID) REFERENCES Bouquets(BouquetID)
--);
--
--CREATE TABLE Payments (
--    PaymentID SERIAL PRIMARY KEY,
--    OrderID INT,
--    PaymentMethod VARCHAR(50),
--    PaymentStatus VARCHAR(50),
--    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
--);
--
--INSERT INTO Customers (FullName, Email, Phone) VALUES
--('Anna Petrova', 'anna@gmail.com', '111-111'),
--('Ivan Shevchenko', 'ivan@gmail.com', '222-222'),
--('Maria Bondar', 'maria@gmail.com', '333-333'),
--('Oleh Koval', 'oleh@gmail.com', '444-444'),
--('Iryna Melnyk', 'iryna@gmail.com', '555-555'),
--('Dmytro Tkachenko', 'dmytro@gmail.com', '666-666'),
--('Sofia Shevchuk', 'sofia@gmail.com', '777-777'),
--('Andrii Boyko', 'andrii@gmail.com', '888-888'),
--('Kateryna Lysenko', 'kate@gmail.com', '999-999'),
--('Volodymyr Petrenko', 'vova@gmail.com', '000-000');
--
--INSERT INTO Flowers (FlowerName, Price) VALUES
--('Rose', 50.00),
--('Tulip', 30.00),
--('Lily', 70.00),
--('Orchid', 120.00),
--('Peony', 90.00),
--('Sunflower', 25.00),
--('Daisy', 20.00),
--('Lavender', 40.00);
--
--INSERT INTO Bouquets (BouquetName, Price, FlowerID) VALUES
--('Romantic Roses', 150.00, 1),
--('Spring Mix', 120.00, 2),
--('Luxury White', 200.00, 4),
--('Sunny Day', 80.00, 6),
--('Lavender Dream', 110.00, 8),
--('Bright Mood', 95.00, 5),
--('Gentle Kiss', 130.00, 3),
--('Floral Heaven', 180.00, 1);
--
--INSERT INTO Orders (CustomerID, BouquetID, OrderDate, Quantity) VALUES
--(1, 1, '2026-06-10', 1),
--(1, 2, '2026-06-12', 2),
--(1, 3, '2026-06-15', 1),
--(2, 2, '2026-06-11', 1),
--(2, 4, '2026-06-14', 1),
--(3, 3, '2026-06-12', 1),
--(3, 5, '2026-06-16', 2),
--(4, 1, '2026-06-10', 1),
--(4, 2, '2026-06-17', 1),
--(5, 6, '2026-06-11', 1),
--(5, 3, '2026-06-18', 2),
--(6, 7, '2026-06-12', 1),
--(6, 1, '2026-06-19', 1),
--(7, 2, '2026-06-13', 2),
--(8, 8, '2026-06-14', 1),
--(9, 4, '2026-06-15', 1),
--(10, 5, '2026-06-16', 3);
--
--INSERT INTO Payments (OrderID, PaymentMethod, PaymentStatus) VALUES
--(1, 'Visa', 'Paid'),
--(2, 'MasterCard', 'Paid'),
--(3, 'Apple Pay', 'Paid'),
--(4, 'Visa', 'Pending'),
--(5, 'MasterCard', 'Paid'),
--(6, 'Apple Pay', 'Paid'),
--(7, 'Visa', 'Paid'),
--(8, 'MasterCard', 'Paid'),
--(9, 'Apple Pay', 'Paid'),
--(10, 'Visa', 'Pending'),
--(11, 'MasterCard', 'Paid'),
--(12, 'Apple Pay', 'Paid'),
--(13, 'Visa', 'Paid'),
--(14, 'MasterCard', 'Paid'),
--(15, 'Apple Pay', 'Paid');

with customer_spending as (
    select
        o.customerid,
        SUM(o.quantity * b.price) AS spent_for_all_time
    from shop.orders o
    left join shop.bouquets b 
        on o.bouquetid = b.bouquetid
    group by o.customerid
)
select 
c.fullname ,
b.bouquetname ,
cs.spent_for_all_time,
o.orderdate,
p.paymentmethod ,
p.paymentstatus
from shop.customers c 
left join shop.orders o 
on c.customerid = o.customerid 
left join shop.bouquets b 
on o.bouquetid = b.bouquetid 
left join shop.flowers f 
on b.flowerid = f.flowerid 
left join shop.payments p 
on o.orderid = p.orderid
left join customer_spending cs
on o.customerid = cs.customerid 
where o.orderdate >= '2026-06-13' and p.paymentstatus = 'Paid' 
group by c.fullname,
b.bouquetname,
o.orderdate,
p.paymentmethod ,
p.paymentstatus ,
cs.spent_for_all_time  
order by cs.spent_for_all_time desc;










