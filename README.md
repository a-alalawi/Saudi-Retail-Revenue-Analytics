# Saudi Retail Revenue Analytics Dashboard

**SQL Server · Power BI · DAX · Power Query · FY 2023–2025**

> 80,000 transactions · 5 regions · 3-page dashboard · 15 DAX measures

![download](https://github.com/user-attachments/assets/eacfc3fe-1dea-4207-8e36-406850be6514)

---

## Why This Project Exists

Most BI portfolio projects start with a CSV from Kaggle and end with a bar chart. This one starts with a question and works backward to the schema.
I built the dashboard around seven questions I wanted the data to actually answer:

1. How is the business performing right now?
2. Are we growing or declining compared to last year?
3. Which regions drive the most revenue?
4. Which product categories are most profitable — and which just look profitable?
5. Where does the money actually go after a transaction?
6. Are we meeting Vision 2030's cashless payment goals?
7. Which seasons drive peak sales, and which underperform relative to their potential?

The dataset is synthetic — generated from scratch in SQL Server to mirror documented Saudi market distributions: city-level population weights, SAMA-reported payment method penetration, and category margin benchmarks from public Saudi retail filings. The point was not to find real data. It was to design a data model that could answer real questions.

---
## Data Model

<img width="1045" height="869" alt="Untitled" src="https://github.com/user-attachments/assets/90867f3c-8537-4649-ae37-f12ae6845132" />

Star schema. One fact table, five dimensions, all relationships many-to-one.

**FactSales** — 80,000 rows, one per transaction. DateKey, StoreKey, ProductKey, CustomerKey, and PaymentKey are stored as integer foreign keys. VAT, cost, discount, and profit each have their own column — computed in SQL during data generation, not downstream in DAX. This keeps every measure simple and the numbers auditable.

**DimDate** — 2023-01-01 through 2025-12-31, populated via recursive CTE. Friday and Saturday are flagged as weekend days. A Season column tags every date into one of five retail periods: Regular, Summer Holidays, Ramadan Season, White Friday & Year End, and Back to School.

**DimProduct** — 24 products across five categories. Markup rates are set at the category level: Fashion 1.55×, Beauty 1.45×, Home & Kitchen 1.40×, Electronics 1.35×, Groceries 1.25×. After applying the VAT extraction, this produces a gross margin spread of 8.5% (Groceries) to 28.1% (Fashion) — wide enough to make the category profitability analysis meaningful.

**DimPayment** — six methods: mada, Visa, Mastercard, Cash, Apple Pay, STC Pay. Transaction distribution was calibrated to SAMA's reported payment penetration data: mada 40%, Visa 20%, Cash 17%, Mastercard 13%, Apple Pay 6%, STC Pay 4%. A PaymentType column groups each method into Cash, Card, or Digital Wallet.

**DimStore** — 8 stores across 5 cities: Riyadh (2), Jeddah (2), Dammam (2), Mecca (1), Medina (1). Transaction weighting routes roughly 40% of volume through Riyadh.

**DimCustomer** — 200 customers, city-weighted, segmented into Bronze (50%), Silver (30%), and Gold (20%) loyalty tiers.


---
## Dashboard

### Page 1 — Executive Overview

<img width="1937" height="1094" alt="page1-executive" src="https://github.com/user-attachments/assets/9fdeb667-fb64-48a1-9c6d-c26ee034a96f" />

The page opens with five KPI cards: Total Revenue (237.64M SAR), YoY Growth (49.0%), Gross Margin (18.0%), Transaction Count (80K), and Avg Order Value (2.97K SAR). Four slicers — Year, Quarter, Region, Category — sit below and filter everything on the page together.

The revenue trend plots 36 months of current-year revenue against the prior year as a dashed line. It's a second series on the same chart, not a separate visual — the point is to make acceleration and deceleration readable in one glance without asking the reader to switch views.

The Category Performance matrix is where the most analytical work is visible. Gross Margin % has conditional background coloring, YoY Growth % has conditional font color, and each row has a sparkline showing trend direction. Those three columns answer the category question — which ones are growing and which ones are dragging margin — without requiring any interaction.

The Payment Distribution donut uses a different color per payment method. The color isn't decorative: a reader who recognizes mada blue or Visa navy can read the chart without touching the legend.

---

### Page 2 — Profitability and VAT

<img width="1932" height="1092" alt="Screenshot 2026-03-11 102321" src="https://github.com/user-attachments/assets/1c46678f-549e-40c3-9955-55c263e9eb39" />

The KPI cards shift from revenue to profit: Net Revenue (206.64M SAR), Profit YoY % (49.2%), Total Profit (37.17M SAR), Total VAT (31.00M SAR). The page is built for the "where does the money go" question.

The waterfall chart — "Where Every SAR Goes" — is the anchor visual. It starts at 237.64M SAR, removes VAT (−31.00M) and Cost (−169.47M), and lands at Profit (37.17M). The 15.6% profit conversion rate becomes impossible to avoid. Color logic is deliberate: cyan for the opening bar, red for what gets taken out, green for what remains.

The scatter plot maps all eight stores on Revenue vs Gross Margin axes with bubble size for transaction volume. Two dashed reference lines — portfolio average revenue and portfolio average margin — divide the chart into quadrants. Riyadh stores sit in the high-revenue quadrant. The margin range across all eight stores is 17.9% to 18.2% — a 0.3 percentage point spread. That's not a data point to describe, it's a finding: location has essentially no effect on profitability.

The Digital Payment trend tracks monthly cashless penetration against a constant red dashed line at 80% — the Vision 2030 target. Every month in the dataset clears it.


---

### Page 3 — Seasonal Analysis

<img width="1932" height="1093" alt="page3-seasonal" src="https://github.com/user-attachments/assets/87abedd4-871b-4df6-9cc8-07ee023cacf8" />

A season filter bar runs across the top of the page. Each button isolates one retail season and all three visuals update together — the bar chart, the sub-category ranking, and the heatmap all respond to the same selection. The bars in the chart match the button colors so the reader always knows which filter is active without checking the slicer state.

Revenue by retail season: Regular (79M SAR) leads by duration, Summer Holidays (59M) second, White Friday & Year End (40M) third, Ramadan Season (39M) fourth. The gap between Summer Holidays and Ramadan is the headline question on this page — Ramadan is the highest consumer-intent period in the calendar, but it ranks fourth.

The sub-category bar chart begins to answer that. Smartphones alone account for 72M SAR — more than Fashion, Beauty, and Groceries combined. Electronics volume is doing most of the work.

The season × category heatmap makes the concentration concrete. The gradient runs from the background color at zero to full cyan at the maximum value, so low cells visually disappear. The Electronics–Regular cell at 47.20M SAR is the brightest point in the matrix. Every other cell is a shade of that. Groceries is nearly invisible across all seasons — which is both a finding and an open question.

---

## Key Findings

**Electronics is carrying the business on thin margins.** At 15.1% gross margin, it accounts for 59% of total revenue (140.77M SAR) on 16,590 transactions. The portfolio's headline 18% margin is suppressed by Electronics' weight in the mix — not by underperformance elsewhere.

**Fashion is the untapped lever.** 28.1% margin on 27.90M SAR revenue. A 10-point shift in revenue mix from Electronics to Fashion — holding total revenue constant — adds roughly 3.8M SAR in annual gross profit with no new customers and no new stores.

**Ramadan underperforms its intent.** Ramadan Season revenue (39.28M SAR) runs 33% below Summer Holidays (58.93M SAR) despite being the highest consumer-intent period in the retail calendar. Electronics spend in Ramadan (22.96M SAR) is nearly identical to White Friday (23.92M SAR) — the promotional calendar is not differentiated toward the categories where it would have the most financial impact.

**Digital payments already clear the Vision 2030 target.** Cashless share averages 82.8% across FY 2023–2025, above the 80% benchmark. mada alone accounts for 39.8% of transactions. The remaining 17.2% in cash is concentrated in Groceries and low-ticket items — the segment least likely to shift regardless of policy.

**Store margins do not vary by location.** The scatter plot shows a 0.3 percentage point spread across all eight stores (17.9% to 18.2%). Riyadh's advantage is volume, not efficiency — two stores account for over 60M SAR combined while Mecca and Medina contribute under 15M.

---

## DAX

Fifteen measures across five groups, all in the FactSales table. Full formulas in [`dax/measures.md`](dax/measures.md).

| # | Measure | Group |
|---|---------|-------|
| 1 | Total Revenue | Revenue |
| 2 | Total Cost | Revenue |
| 3 | Total VAT | Revenue |
| 4 | Net Revenue | Revenue |
| 5 | Total Discount | Revenue |
| 6 | Total Profit | Profitability |
| 7 | Gross Margin % | Profitability |
| 8 | PY Revenue | Time Intelligence |
| 9 | YoY Growth % | Time Intelligence |
| 10 | PY Profit | Time Intelligence |
| 11 | Profit YoY % | Time Intelligence |
| 12 | Transaction Count | Transactions |
| 13 | Avg Order Value | Transactions |
| 14 | Digital Payment % | Payments |
| 15 | Revenue % of Total | Payments |

Three decisions worth explaining:

```dax
-- Margin is calculated on Net Revenue, not Total Revenue.
-- Total Revenue includes VAT, which passes through to the government.
-- Dividing by it understates the true margin on revenue the business keeps.
Gross Margin % = DIVIDE([Total Profit], [Net Revenue], 0)

-- BLANK() instead of 0 matters on the trend line.
-- When prior-year data doesn't exist (start of FY2023), returning 0
-- anchors the line to zero and makes the chart unreadable.
YoY Growth % =
DIVIDE([Total Revenue] - [PY Revenue], [PY Revenue], BLANK())

-- ALL(DimStore) removes the store filter before calculating the denominator,
-- so each store's percentage reflects its share of total revenue,
-- not just the filtered subset.
Revenue % of Total =
DIVIDE([Total Revenue], CALCULATE([Total Revenue], ALL(DimStore)), 0)
```

---


## Tech Stack

| Layer | Tool | Decisions |
|---|---|---|
| Data modeling | SQL Server 2022 | Star schema, 6 tables, indexed FK columns on FactSales |
| Data generation | T-SQL | Recursive CTE + NEWID, set-based — 80,000 rows in ~90 seconds |
| ETL | Power Query (M) | Type standardization, column renames, season tagging |
| Measures | DAX | VAR/RETURN, DIVIDE, SAMEPERIODLASTYEAR |
| Report | Power BI Desktop | Custom dark JSON theme, conditional formatting, sparklines |

---

## How to Run

Requirements: SQL Server 2022, SQL Server Management Studio, Power BI Desktop.

In SSMS, run the three scripts in `/sql` in order: `01-create-dimensions.sql`, then `02-create-fact-table.sql`, then `03-generate-data.sql`. The generation script uses `OPTION(MAXRECURSION 0)` and takes roughly 90 seconds.
Open `Saudi_Retail_Dashboard.pbix` in Power BI Desktop.
Go to Transform Data → Data Source Settings and update the server name to your local instance.
Click Home → Refresh All.

---

## Repository Structure

```
saudi-retail-dashboard/
├── sql/
│   ├── 01-create-dimensions.sql
│   ├── 02-create-fact-table.sql
│   └── 03-generate-data.sql
├── dax/
│   └── measures.md
├── pbix/
│   └── Saudi_Retail_Dashboard.pbix
├── screenshots/
│   ├── erd.png
│   ├── page1-executive.png
│   ├── page2-profitability.png
│   └── page3-seasonal.png
└── README.md
```

---















