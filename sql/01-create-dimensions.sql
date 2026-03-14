CREATE TABLE dbo.DimDate (
    DateKey      INT          NOT NULL PRIMARY KEY,
    FullDate     DATE         NOT NULL,
    DayName      NVARCHAR(10) NOT NULL,
    DayOfMonth   INT          NOT NULL,
    MonthNumber  INT          NOT NULL,
    MonthName    NVARCHAR(10) NOT NULL,
    [Quarter]    INT          NOT NULL,
    [Year]       INT          NOT NULL,
    IsWeekend    BIT          NOT NULL,
    IsHoliday    BIT          NOT NULL DEFAULT 0
);


;WITH DateCTE AS (
    SELECT CAST('2023-01-01' AS DATE) AS dt
    UNION ALL
    SELECT DATEADD(DAY, 1, dt)
    FROM DateCTE
    WHERE dt < '2025-12-31'
)
INSERT INTO dbo.DimDate
    (DateKey, FullDate, DayName, DayOfMonth, MonthNumber,
     MonthName, [Quarter], [Year], IsWeekend, IsHoliday)
SELECT
    CONVERT(INT, FORMAT(dt, 'yyyyMMdd'))   AS DateKey,
    dt                                      AS FullDate,
    DATENAME(WEEKDAY, dt)                   AS DayName,
    DAY(dt)                                 AS DayOfMonth,
    MONTH(dt)                               AS MonthNumber,
    DATENAME(MONTH, dt)                     AS MonthName,
    DATEPART(QUARTER, dt)                   AS [Quarter],
    YEAR(dt)                                AS [Year],
    CASE WHEN DATENAME(WEEKDAY, dt)
              IN ('Friday','Saturday')
         THEN 1 ELSE 0 END                 AS IsWeekend,
    0                                       AS IsHoliday
FROM DateCTE
OPTION (MAXRECURSION 0);


CREATE TABLE dbo.DimStore (
    StoreKey     INT           IDENTITY(1,1) NOT NULL PRIMARY KEY,
    StoreName    NVARCHAR(100) NOT NULL,
    City         NVARCHAR(50)  NOT NULL,
    Region       NVARCHAR(50)  NOT NULL,
    StoreType    NVARCHAR(30)  NOT NULL
);


INSERT INTO dbo.DimStore (StoreName, City, Region, StoreType) VALUES
(N'Riyadh Mall Central',    N'Riyadh',  N'Central',  N'Mall'),
(N'Riyadh Hypermarket',     N'Riyadh',  N'Central',  N'Hypermarket'),
(N'Jeddah Corniche Store',  N'Jeddah',  N'Western',  N'Mall'),
(N'Jeddah Supermarket',     N'Jeddah',  N'Western',  N'Supermarket'),
(N'Dammam City Centre',     N'Dammam',  N'Eastern',  N'Mall'),
(N'Dammam Express',         N'Dammam',  N'Eastern',  N'Standalone'),
(N'Mecca Grand Store',      N'Mecca',   N'Western',  N'Hypermarket'),
(N'Medina Central',         N'Medina',  N'Western',  N'Mall');


CREATE TABLE dbo.DimProduct (
    ProductKey   INT           IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProductName  NVARCHAR(100) NOT NULL,
    Category     NVARCHAR(50)  NOT NULL,
    SubCategory  NVARCHAR(50)  NOT NULL,
    UnitCost     DECIMAL(10,2) NOT NULL
);



INSERT INTO dbo.DimProduct
    (ProductName, Category, SubCategory, UnitCost) VALUES
-- Electronics
(N'Samsung Galaxy S24',       N'Electronics',     N'Smartphones',    2100.00),
(N'iPhone 15 Pro',            N'Electronics',     N'Smartphones',    3200.00),
(N'iPad Air',                 N'Electronics',     N'Tablets',        1800.00),
(N'Sony WH-1000XM5',         N'Electronics',     N'Audio',           850.00),
(N'Samsung 55" Smart TV',     N'Electronics',     N'TVs',            2400.00),

-- Fashion
(N'Thobe Classic White',      N'Fashion',         N'Menswear',        250.00),
(N'Abaya Embroidered',        N'Fashion',         N'Womenswear',      400.00),
(N'Nike Air Max 90',          N'Fashion',         N'Footwear',        450.00),
(N'Ray-Ban Aviator',          N'Fashion',         N'Accessories',     550.00),
(N'Shimagh Premium',          N'Fashion',         N'Menswear',        120.00),

-- Groceries
(N'Al Marai Fresh Milk 2L',   N'Groceries',       N'Dairy',            12.00),
(N'Basmati Rice 5kg',         N'Groceries',       N'Grains',           45.00),
(N'Almarai Chicken 1kg',      N'Groceries',       N'Meat',             35.00),
(N'Nescafe Gold 200g',        N'Groceries',       N'Beverages',        42.00),
(N'Dates Sukkari 1kg',        N'Groceries',       N'Snacks',           65.00),

-- Home & Kitchen
(N'Dyson V15 Vacuum',         N'Home & Kitchen',  N'Appliances',     2200.00),
(N'Philips Air Fryer XXL',    N'Home & Kitchen',  N'Appliances',      650.00),
(N'IKEA Kallax Shelf',        N'Home & Kitchen',  N'Furniture',       280.00),
(N'Tefal Cookware Set',       N'Home & Kitchen',  N'Cookware',        350.00),

-- Beauty
(N'Oud Perfume 100ml',        N'Beauty',          N'Fragrances',      750.00),
(N'Bakhoor Assorted Box',     N'Beauty',          N'Fragrances',      180.00),
(N'Nivea Men Cream 150ml',    N'Beauty',          N'Skincare',         28.00),
(N'MAC Lipstick',             N'Beauty',          N'Makeup',          130.00),
(N'Dove Shampoo 400ml',       N'Beauty',          N'Haircare',         22.00);



CREATE TABLE dbo.DimCustomer (
    CustomerKey  INT           IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    Gender       NVARCHAR(10)  NOT NULL,
    AgeGroup     NVARCHAR(20)  NOT NULL,
    City         NVARCHAR(50)  NOT NULL,
    LoyaltyTier  NVARCHAR(20)  NOT NULL
);



;WITH
n1 AS (SELECT 1 AS n FROM (VALUES(1),(1),(1),(1),(1),
                                  (1),(1),(1),(1),(1)) x(n)),
n2 AS (SELECT 1 AS n FROM n1 a CROSS JOIN n1 b),
Tally AS (
    SELECT TOP(200)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM n2 a CROSS JOIN n1 b
)
INSERT INTO dbo.DimCustomer
    (CustomerName, Gender, AgeGroup, City, LoyaltyTier)
SELECT
    CASE WHEN t.rn % 2 = 1
        THEN
            CASE (ABS(CHECKSUM(NEWID()) % 15))
                WHEN 0  THEN N'Mohammed'
                WHEN 1  THEN N'Abdullah'
                WHEN 2  THEN N'Khalid'
                WHEN 3  THEN N'Omar'
                WHEN 4  THEN N'Faisal'
                WHEN 5  THEN N'Sultan'
                WHEN 6  THEN N'Turki'
                WHEN 7  THEN N'Saud'
                WHEN 8  THEN N'Bandar'
                WHEN 9  THEN N'Naif'
                WHEN 10 THEN N'Fahad'
                WHEN 11 THEN N'Majed'
                WHEN 12 THEN N'Yousef'
                WHEN 13 THEN N'Ibrahim'
                WHEN 14 THEN N'Ali'
                ELSE N'Mohammed'
            END
        ELSE
            CASE (ABS(CHECKSUM(NEWID()) % 15))
                WHEN 0  THEN N'Noura'
                WHEN 1  THEN N'Fatimah'
                WHEN 2  THEN N'Sara'
                WHEN 3  THEN N'Haya'
                WHEN 4  THEN N'Lama'
                WHEN 5  THEN N'Reema'
                WHEN 6  THEN N'Maha'
                WHEN 7  THEN N'Alanoud'
                WHEN 8  THEN N'Dalal'
                WHEN 9  THEN N'Haifa'
                WHEN 10 THEN N'Reem'
                WHEN 11 THEN N'Atheer'
                WHEN 12 THEN N'Joud'
                WHEN 13 THEN N'Ghada'
                WHEN 14 THEN N'Mashael'
                ELSE N'Noura'
            END
    END
    + N' '
    + CASE (ABS(CHECKSUM(NEWID()) % 15))
        WHEN 0  THEN N'Al-Qahtani'
        WHEN 1  THEN N'Al-Otaibi'
        WHEN 2  THEN N'Al-Dosari'
        WHEN 3  THEN N'Al-Harbi'
        WHEN 4  THEN N'Al-Ghamdi'
        WHEN 5  THEN N'Al-Shehri'
        WHEN 6  THEN N'Al-Mutairi'
        WHEN 7  THEN N'Al-Zahrani'
        WHEN 8  THEN N'Al-Rashidi'
        WHEN 9  THEN N'Al-Shamari'
        WHEN 10 THEN N'Al-Anazi'
        WHEN 11 THEN N'Al-Subai'
        WHEN 12 THEN N'Al-Tamimi'
        WHEN 13 THEN N'Al-Sulaiman'
        WHEN 14 THEN N'Al-Alawi'
        ELSE N'Al-Qahtani'
    END                                    AS CustomerName,
    CASE WHEN t.rn % 2 = 1
         THEN N'Male' ELSE N'Female'
    END                                    AS Gender,
    CASE (ABS(CHECKSUM(NEWID()) % 5))
        WHEN 0 THEN N'18-25'
        WHEN 1 THEN N'26-35'
        WHEN 2 THEN N'36-45'
        WHEN 3 THEN N'46-55'
        WHEN 4 THEN N'56+'
        ELSE N'26-35'
    END                                    AS AgeGroup,
    CASE (ABS(CHECKSUM(NEWID()) % 10))
        WHEN 0 THEN N'Riyadh'
        WHEN 1 THEN N'Riyadh'
        WHEN 2 THEN N'Riyadh'
        WHEN 3 THEN N'Jeddah'
        WHEN 4 THEN N'Jeddah'
        WHEN 5 THEN N'Dammam'
        WHEN 6 THEN N'Dammam'
        WHEN 7 THEN N'Mecca'
        WHEN 8 THEN N'Medina'
        WHEN 9 THEN N'Riyadh'
        ELSE N'Riyadh'
    END                                    AS City,
    CASE (ABS(CHECKSUM(NEWID()) % 10))
        WHEN 0 THEN N'Gold'
        WHEN 1 THEN N'Gold'
        WHEN 2 THEN N'Silver'
        WHEN 3 THEN N'Silver'
        WHEN 4 THEN N'Silver'
        ELSE N'Bronze'
    END                                    AS LoyaltyTier
FROM Tally t;



CREATE TABLE dbo.DimPayment (
    PaymentKey    INT          IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PaymentMethod NVARCHAR(30) NOT NULL,
    PaymentType   NVARCHAR(20) NOT NULL,
    Provider      NVARCHAR(50) NOT NULL
);

INSERT INTO dbo.DimPayment
    (PaymentMethod, PaymentType, Provider) VALUES
(N'Cash',        N'Cash',           N'N/A'),
(N'mada',        N'Card',           N'Saudi Payments (SAMA)'),
(N'Visa',        N'Card',           N'Visa Inc.'),
(N'Mastercard',  N'Card',           N'Mastercard Inc.'),
(N'Apple Pay',   N'Digital Wallet', N'Apple Inc.'),
(N'STC Pay',     N'Digital Wallet', N'STC Group');




