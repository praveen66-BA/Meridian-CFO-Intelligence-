# Meridian-CFO-Intelligence-
CFO Intelligence Platform — Financial Close &amp; Variance Analysis
#  Meridian Group — CFO Intelligence Platform

> End-to-end financial analytics platform built with Python, SQL Server, and Power BI — featuring automated anomaly detection, variance analysis, and intercompany reconciliation across a synthetic 4-division conglomerate.


 Project Overview

The Meridian CFO Intelligence Platform is a full-stack financial analytics solution that simulates a real-world corporate finance environment. It covers the complete data pipeline from synthetic data generation through to an executive-grade Power BI dashboard — designed to give a CFO a 30-second overview of the entire business.

 Key Highlights
1)47,515 rows** of synthetic financial data across 6 tables
2)6-page Power BI dashboard with 40+ DAX measures
3)15 anomalies auto-detected using statistical and rule-based methods
4)Star schema data model with fact and dimension tables
5)Intercompany reconciliation engine with mismatch detection
6)Rolling 12-month EBITDA and time intelligence measures

 Tech Stack

| Layer | Technology |

| Data Generation | Python 3, Pandas, NumPy, Faker |
| Database | SQL Server Express (MeridianCFO DB) |
| Analytics | SQL — 6 analytical queries |
| Visualisation | Power BI Desktop |
| DAX Measures | 40+ measures across 8 measure groups |
| Version Control | Git + GitHub |


## Architecture

```
Python (generate_data.py)
        ↓
CSV Files (6 tables, 47,515 rows)
        ↓
SQL Server — MeridianCFO Database
        ↓
Power Query — Star Schema Transform
        ↓
Power BI — 6 Page CFO Dashboard
```

---

##  Project Structure

```
Meridian-CFO-Intelligence-/
├── data/
│   ├── dim_account.csv
│   ├── dim_business_unit.csv
│   ├── dim_date.csv
│   ├── dim_scenario.csv
│   ├── fact_financials.csv
│   └── fact_intercompany.csv
├── python/
│   ├── generate_data.py
│   └── load_to_sql.py
├── sql/
│   └── queries.sql
├── powerbi/
│   └── CFO_Dashboard.pbix
├── consulting_output/
│   ├── Meridian_DAX_Measures_Guide.docx
│   └── Meridian_DAX_Studio_Guide.docx
└── README.md
```



##  Data Model — Star Schema

| Table | Type | Rows | Description |
| fact_financials | Fact | 46,784 | Daily P&L entries  Actual & Budget |
| fact_intercompany | Fact | 731 | IC transactions North  East Division |
| dim_date | Dimension | 731 | Full date table Jan 2023 – Dec 2024 |
| dim_business_unit | Dimension | 4 | North, South, East, West Divisions |
| dim_account | Dimension | 8 | P&L account lines with sort order |
| dim_scenario | Dimension | 3 | Actual, Budget, Prior Year |


##  Business Units

| Division | Industry | Region | Head of Unit | Headcount |
| North Division | Industrial Equipment | North India | Rajesh Sharma | 245 |
| South Division | Consumer Products | South India | Priya Mehta | 312 |
| East Division | Raw Materials | East India | Arun Krishnan | 198 |
| West Division | Logistics & Distribution | West India | Sunita Patel | 276 |


##  Anomaly Detection — 5 Planted Anomalies

The platform automatically detects all 5 planted anomalies using statistical and rule-based methods:

| # | Anomaly | Division | Period | Method | Impact |
| 1 | Revenue Spike | West Division | Oct 2023 | 2σ Statistical Rule | 3.4× normal revenue |
| 2 | G&A Cost Overrun | South Division | Q3 2024 | Budget Breach Flag | 1.67× normal cost |
| 3 | Missing Depreciation Accrual | East Division | Dec 2023 | Missing Accrual Detection | ₹0 posted vs ₹490 expected |
| 4 | COGS Breach | North Division | Jun 2024 | COGS % Threshold | 1.45× normal COGS |
| 5 | Intercompany Mismatch | North → East | Apr/Sep 2023, Mar 2024 | IC Reconciliation | 91 transactions unmatched |


##  Dashboard Pages

### Page 1 — Executive Summary
CFO 30-second overview of the entire business
- Total Revenue Actual vs Budget vs Variance %
- EBITDA and EBITDA Margin %
- Revenue by Division (4 cards)
- Division RAG Status table
- Monthly Revenue Trend 2023 vs 2024
- Total Anomalies Detected counter

### Page 2 — P&L Statement
Full income statement every account line every division
- All 8 account lines — Revenue, COGS, OPEX
- Actual vs Budget vs Variance vs Variance %
- Conditional formatting — Red unfavorable, Green favorable
- Slicers for Division and Fiscal Period

### Page 3 — Variance Analysis
Why did the numbers move?
- Revenue Bridge waterfall — Budget to Actual
- EBITDA Bridge by Account Type
- Budget Accuracy scatter plot by Division
- Top Variances table by Account and Division
- Biggest Favorable and Unfavorable variance cards

### Page 4 — Business Unit Deep Dive
Division-level detail with RLS
- 24-month revenue trend line chart
- Monthly Actual vs Budget bar chart
- Full P&L summary per division
- KPIs: YoY Growth, MoM Growth, COGS %, Gross Margin, EBITDA, OPEX Ratio
- Division head info cards

### Page 5 — Anomaly Intelligence
Automated financial risk detection
- All 5 anomalies listed with risk levels
- Intercompany reconciliation status table
- Anomaly count by division
- IC variance by month
- Missing accrual detection

### Page 6 — Data Governance
Methodology and data lineage
- Pipeline architecture diagram
- Dataset inventory with row counts
- Anomaly detection methodology table
- Data quality score 98.2%
- Last refresh timestamp



##  DAX Measures — 40+ Measures

### Revenue Measures
- Revenue Actual, Revenue Budget, Revenue Variance, Revenue Variance %
- Revenue Prior Year, Revenue Growth YoY %, Revenue Growth MoM %
- Revenue YTD, Rolling 3 Month Revenue

### Profitability Measures
- Gross Profit, Gross Margin %
- EBITDA, EBITDA Budget, EBITDA Variance, EBITDA Margin %

### Cost Measures
- Total COGS Actual, COGS as % of Revenue
- Total OPEX Actual, OPEX Ratio %

### Anomaly Measures
- Total Anomalies Detected
- IC Mismatch Count, IC Total Variance
- Missing Accrual Count
- Budget Breach Flag, Budget Breach Count

### Time Intelligence
- Revenue YTD, Rolling 12 Month EBITDA
- YoY Growth %, MoM Growth %



##  SQL Queries

6 analytical queries covering:
1. Revenue Variance by Business Unit
2. Full Budget vs Actual Analysis
3. Rolling 12 Month EBITDA Trend
4. Intercompany Reconciliation Check
5. Statistical Anomaly Detection (2σ rule)
6. Missing Accrual Detection



##  How to Run

### 1. Generate Data
```bash
cd python
pip install pandas numpy faker
python generate_data.py


### 2. Load to SQL Server
```bash
pip install sqlalchemy pyodbc
python load_to_sql.py


### 3. Open Power BI
- Open `powerbi/CFO_Dashboard.pbix`
- Refresh data connection to your SQL Server
- All 6 pages and 40+ measures load automatically
```


##  Key Financial Metrics

| Metric | Value |
| Total Revenue Actual | ₹8.06 Cr |
| Total Revenue Budget | ₹8.26 Cr |
| Revenue Variance | -2.4% |
| EBITDA | ₹2.59 Cr |
| EBITDA Margin | 32.1% |
| Gross Margin | 46.4% |
| Budget Achievement Rate | 97.6% |



##  Author

Praveen Kumar Nutakki
Data Analyst | Power BI | SQL | Python  



## License

This project is for portfolio and educational purposes.  
Synthetic data generated using Python Faker library — no real financial data used.
