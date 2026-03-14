CREATE TABLE dbo.FactSales (
    SaleKey       INT           IDENTITY(1,1) NOT NULL PRIMARY KEY,
    DateKey       INT           NOT NULL,
    StoreKey      INT           NOT NULL,
    ProductKey    INT           NOT NULL,
    CustomerKey   INT           NOT NULL,
    PaymentKey    INT           NOT NULL,
    Quantity      INT           NOT NULL,
    UnitPrice     DECIMAL(10,2) NOT NULL,
    TotalAmount   DECIMAL(10,2) NOT NULL,
    DiscountAmt   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CostAmount    DECIMAL(10,2) NOT NULL,
    Profit        DECIMAL(10,2) NOT NULL,
    VATAmount     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
 
    CONSTRAINT FK_Sales_Date     FOREIGN KEY (DateKey)
        REFERENCES dbo.DimDate(DateKey),
    CONSTRAINT FK_Sales_Store    FOREIGN KEY (StoreKey)
        REFERENCES dbo.DimStore(StoreKey),
    CONSTRAINT FK_Sales_Product  FOREIGN KEY (ProductKey)
        REFERENCES dbo.DimProduct(ProductKey),
    CONSTRAINT FK_Sales_Customer FOREIGN KEY (CustomerKey)
        REFERENCES dbo.DimCustomer(CustomerKey),
    CONSTRAINT FK_Sales_Payment  FOREIGN KEY (PaymentKey)
        REFERENCES dbo.DimPayment(PaymentKey)
);


CREATE NONCLUSTERED INDEX IX_FactSales_DateKey
    ON dbo.FactSales(DateKey);
CREATE NONCLUSTERED INDEX IX_FactSales_StoreKey
    ON dbo.FactSales(StoreKey);
CREATE NONCLUSTERED INDEX IX_FactSales_ProductKey
    ON dbo.FactSales(ProductKey);
CREATE NONCLUSTERED INDEX IX_FactSales_PaymentKey
    ON dbo.FactSales(PaymentKey);
CREATE NONCLUSTERED INDEX IX_FactSales_CustomerKey
    ON dbo.FactSales(CustomerKey);