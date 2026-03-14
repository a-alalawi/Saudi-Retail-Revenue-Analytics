;WITH
n1 AS (SELECT 1 AS n FROM (VALUES(1),(1),(1),(1),(1),
                                  (1),(1),(1),(1),(1)) x(n)),
n2 AS (SELECT 1 AS n FROM n1 a CROSS JOIN n1 b),
n3 AS (SELECT 1 AS n FROM n2 a CROSS JOIN n2 b),
Tally AS (
    SELECT TOP(80000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM n3 a CROSS JOIN n2 b
)
INSERT INTO dbo.FactSales
    (DateKey, StoreKey, ProductKey, CustomerKey, PaymentKey,
     Quantity, UnitPrice, TotalAmount, DiscountAmt,
     VATAmount, CostAmount, Profit)
SELECT
    d.DateKey,
    s.StoreKey,
    p.ProductKey,
    c.CustomerKey,
    CASE
        WHEN payRand.val < 40 THEN 2 
        WHEN payRand.val < 60 THEN 3 
        WHEN payRand.val < 77 THEN 1 
        WHEN payRand.val < 90 THEN 4 
        WHEN payRand.val < 96 THEN 5 
        ELSE                       6 
    END                                                   AS PaymentKey,
    qty.val                                               AS Quantity,
    price.val                                             AS UnitPrice,
    CAST(price.val * qty.val * (1 - disc.val / 100.0)
         AS DECIMAL(10,2))                                AS TotalAmount,
    CAST(price.val * qty.val * (disc.val / 100.0)
         AS DECIMAL(10,2))                                AS DiscountAmt,
    CAST(price.val * qty.val * (1 - disc.val / 100.0)
         - price.val * qty.val * (1 - disc.val / 100.0) / 1.15
         AS DECIMAL(10,2))                                AS VATAmount,
    CAST(p.UnitCost * qty.val
         AS DECIMAL(10,2))                                AS CostAmount,
    CAST((price.val * qty.val * (1 - disc.val / 100.0)) / 1.15
         - p.UnitCost * qty.val
         AS DECIMAL(10,2))                                AS Profit

FROM Tally t

-- Random date
CROSS APPLY (
    SELECT TOP 1 DateKey
    FROM dbo.DimDate
    WHERE t.rn = t.rn
    ORDER BY NEWID()
) d

-- Store weighted by city
CROSS APPLY (
    SELECT TOP 1 StoreKey
    FROM dbo.DimStore
    WHERE t.rn = t.rn
    ORDER BY
        CASE City
            WHEN N'Riyadh'  THEN ABS(CHECKSUM(NEWID()) % 100)
            WHEN N'Jeddah'  THEN ABS(CHECKSUM(NEWID()) % 160)
            WHEN N'Dammam'  THEN ABS(CHECKSUM(NEWID()) % 270)
            WHEN N'Mecca'   THEN ABS(CHECKSUM(NEWID()) % 340)
            WHEN N'Medina'  THEN ABS(CHECKSUM(NEWID()) % 500)
            ELSE                 ABS(CHECKSUM(NEWID()) % 400)
        END
) s

-- Random product
CROSS APPLY (
    SELECT TOP 1 ProductKey, UnitCost, Category
    FROM dbo.DimProduct
    WHERE t.rn = t.rn
    ORDER BY NEWID()
) p

-- Random customer
CROSS APPLY (
    SELECT TOP 1 CustomerKey
    FROM dbo.DimCustomer
    WHERE t.rn = t.rn
    ORDER BY NEWID()
) c

-- Random payment
CROSS APPLY (
    SELECT ABS(CHECKSUM(NEWID()) % 100) AS val
) payRand

-- Quantity 1–5
CROSS APPLY (
    SELECT ABS(CHECKSUM(NEWID()) % 5) + 1 AS val
) qty

-- Category margin
CROSS APPLY (
    SELECT CAST(
        p.UnitCost * CASE p.Category
            WHEN N'Electronics'    THEN 1.35 + (ABS(CHECKSUM(NEWID()) % 10)) * 0.01
            WHEN N'Groceries'      THEN 1.25 + (ABS(CHECKSUM(NEWID()) % 10)) * 0.01
            WHEN N'Fashion'        THEN 1.55 + (ABS(CHECKSUM(NEWID()) % 20)) * 0.01
            WHEN N'Beauty'         THEN 1.45 + (ABS(CHECKSUM(NEWID()) % 15)) * 0.01
            WHEN N'Home & Kitchen' THEN 1.40 + (ABS(CHECKSUM(NEWID()) % 15)) * 0.01
            ELSE 1.30
        END
    AS DECIMAL(10,2)) AS val
) price

-- Discount
CROSS APPLY (
    SELECT CASE
        WHEN ABS(CHECKSUM(NEWID()) % 10) < 7 THEN 0
        ELSE ABS(CHECKSUM(NEWID()) % 20)
    END AS val
) disc;
