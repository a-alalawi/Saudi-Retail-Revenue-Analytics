# DAX Measures Reference

All measures reside in the **Measures** table. Time-intelligence measures require DimDate to be marked as the date table in the model.

---

## Revenue

**Total Revenue**
Top-line figure inclusive of VAT. Base for all revenue-relative calculations.
```dax
Total Revenue = SUM(FactSales[Total Amount])
```
Format: Currency, 2 decimal places

---

**Total VAT**
Aggregate VAT collected across all transactions.
```dax
Total VAT = SUM(FactSales[VAT Amount])
```
Format: Currency, 2 decimal places

---

**Net Revenue**
Revenue after VAT. Denominator for all margin calculations — using Total Revenue as the base would overstate margin.
```dax
Net Revenue = [Total Revenue] - [Total VAT]
```
Format: Currency, 2 decimal places

---

**Total Discount**
Aggregate discount applied across transactions. 30% of transactions carry a discount between 1–19%; the remaining 70% transact at full price.
```dax
Total Discount = SUM(FactSales[Discount Amount])
```
Format: Currency, 2 decimal places

---

## Profitability

**Total Cost**
Sum of cost of goods sold. Category-level markup rates are embedded in DimProduct and applied during data generation — not computed here.
```dax
Total Cost = SUM(FactSales[Cost Amount])
```
Format: Currency, 2 decimal places

---

**Total Profit**
Net revenue less cost. Equivalent to gross profit after VAT deduction.
```dax
Total Profit = [Net Revenue] - [Total Cost]
```
Format: Currency, 2 decimal places

---

**Gross Margin %**
Profit as a proportion of net revenue. Conditional formatting on the Category Performance matrix is anchored to this measure: above 20% green, 12–20% amber, below 12% red.
```dax
Gross Margin % = DIVIDE([Total Profit], [Net Revenue], 0)
```
Format: Percentage, 1 decimal place

---

## Time Intelligence

**PY Revenue**
Prior-year revenue for the equivalent period. Shifts filter context back 12 months using the marked date table.
```dax
PY Revenue =
CALCULATE(
    [Total Revenue],
    SAMEPERIODLASTYEAR(DimDate[Date])
)
```
Format: Currency, 2 decimal places

---

**YoY Growth %**
Year-over-year revenue growth. Returns BLANK when prior-year data does not exist — prevents the trend line from anchoring to zero at the start of the series.
```dax
YoY Growth % =
VAR CurrentRev = [Total Revenue]
VAR PriorRev   = [PY Revenue]
RETURN
    DIVIDE(
        CurrentRev - PriorRev,
        PriorRev,
        BLANK()
    )
```
Format: Percentage, 1 decimal place

---

**PY Profit**
Prior-year profit for the equivalent period. Parallel construct to PY Revenue.
```dax
PY Profit =
CALCULATE(
    [Total Profit],
    SAMEPERIODLASTYEAR(DimDate[Date])
)
```
Format: Currency, 2 decimal places

---

**Profit YoY %**
Year-over-year profit growth. A divergence between this and YoY Growth % in any period signals margin compression or expansion.
```dax
Profit YoY % =
VAR CurrentProfit = [Total Profit]
VAR PriorProfit   = [PY Profit]
RETURN
    DIVIDE(
        CurrentProfit - PriorProfit,
        PriorProfit,
        BLANK()
    )
```
Format: Percentage, 1 decimal place

---

## Transaction Metrics

**Transaction Count**
Row count of FactSales under the current filter context.
```dax
Transaction Count = COUNTROWS(FactSales)
```
Format: Whole Number

---

**Avg Order Value**
Mean revenue per transaction.
```dax
Avg Order Value = DIVIDE([Total Revenue], [Transaction Count], 0)
```
Format: Currency, 2 decimal places

---

**Revenue % of Total**
Each store's share of total revenue independent of any active store or region filter. ALL(DimStore) removes the store filter context before calculating the denominator — without it the measure returns 100% for every row.
```dax
Revenue % of Total =
DIVIDE(
    [Total Revenue],
    CALCULATE([Total Revenue], ALL(DimStore)),
    0
)
```
Format: Percentage, 1 decimal place

---

## Payment Analysis

**Digital Payment %**
Share of revenue transacted through non-cash methods. Plotted monthly against an 80% constant line on the Digital Payment trend chart to benchmark against the Vision 2030 cashless target.
```dax
Digital Payment % =
DIVIDE(
    CALCULATE(
        [Total Revenue],
        DimPayment[Payment Type] <> "Cash"
    ),
    [Total Revenue],
    0
)
```
Format: Percentage, 1 decimal place

---

## Waterfall Support

**Waterfall Value**
Switch measure that feeds the "Where Every SAR Goes" waterfall chart on Page 2. VAT and Cost are returned as negative values so Power BI renders them as decrease bars.
```dax
Waterfall Value =
SWITCH(
    SELECTEDVALUE('Revenue Flow'[Step]),
    "Total Revenue",  [Total Revenue],
    "VAT",           -[Total VAT],
    "Cost",          -[Total Cost],
    BLANK()
)
```
