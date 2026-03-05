
# MERIDIAN GROUP  Synthetic Financial Data Generator


import pandas as pd
import numpy as np
from faker import Faker
import random
import os

fake = Faker()
np.random.seed(42)
random.seed(42)

OUTPUT_DIR = "data/raw/"
os.makedirs(OUTPUT_DIR, exist_ok=True)

print("STEP 1 — Libraries loaded successfully")



def generate_dim_date():
    dates = pd.date_range(
        start="2023-01-01",
        end="2024-12-31",
        freq="D"
    )
    dim_date = pd.DataFrame({
        "date_id":        dates.strftime("%Y%m%d").astype(int),
        "full_date":      dates,
        "day":            dates.day,
        "month":          dates.month,
        "month_name":     dates.strftime("%B"),
        "quarter":        dates.quarter,
        "quarter_name":   "Q" + dates.quarter.astype(str),
        "year":           dates.year,
        "fiscal_period":  dates.strftime("%Y-%m"),
        "is_month_end":   dates.is_month_end.astype(int),
        "is_quarter_end": dates.is_quarter_end.astype(int),
        "is_year_end":    dates.is_year_end.astype(int)
    })
    dim_date.to_csv(f"{OUTPUT_DIR}dim_date.csv", index=False)
    print(f"STEP 2 of 7 — dim_date created — {len(dim_date)} rows")
    return dim_date

dim_date = generate_dim_date()




def generate_dim_business_unit():
    data = {
        "unit_id":          [1, 2, 3, 4],
        "unit_name":        ["North Division","South Division",
                             "East Division","West Division"],
        "industry":         ["Industrial Equipment","Consumer Products",
                             "Raw Materials","Logistics & Distribution"],
        "region":           ["North India","South India",
                             "East India","West India"],
        "head_of_unit":     ["Rajesh Sharma","Priya Mehta",
                             "Arun Krishnan","Sunita Patel"],
        "cost_center_code": ["CC-001","CC-002","CC-003","CC-004"],
        "headcount":        [245, 312, 198, 276],
        "established_year": [2008, 2011, 2015, 2013]
    }
    dim_bu = pd.DataFrame(data)
    dim_bu.to_csv(f"{OUTPUT_DIR}dim_business_unit.csv", index=False)
    print(f"STEP 3  — dim_business_unit created — {len(dim_bu)} rows")
    return dim_bu

dim_bu = generate_dim_business_unit()




def generate_dim_account():
    data = {
        "account_id": [101, 102, 103, 201, 202, 301, 302, 401],
        "account_name": [
            "Product Revenue",
            "Service Revenue",
            "Other Income",
            "Cost of Goods Sold",
            "Direct Labour Cost",
            "Sales & Marketing Expense",
            "General & Administrative Expense",
            "Depreciation & Amortization"
        ],
        "account_type": [
            "Revenue","Revenue","Revenue",
            "COGS","COGS",
            "OPEX","OPEX","OPEX"
        ],
        "account_category": [
            "Income","Income","Income",
            "Direct Cost","Direct Cost",
            "Indirect Cost","Indirect Cost","Non-Cash"
        ],
        "is_intercompany_flag": [0,0,1,0,0,0,0,0],
        "normal_balance": [
            "Credit","Credit","Credit",
            "Debit","Debit",
            "Debit","Debit","Debit"
        ],
        "sort_order": [1,2,3,4,5,6,7,8]
    }
    dim_account = pd.DataFrame(data)
    dim_account.to_csv(f"{OUTPUT_DIR}dim_account.csv", index=False)
    print(f"STEP 4 - dim_account created — {len(dim_account)} rows")
    return dim_account

dim_account = generate_dim_account()




def generate_dim_scenario():
    data = {
        "scenario_id":   [1, 2, 3],
        "scenario_name": ["Actual", "Budget", "Prior Year"],
        "scenario_type": ["Reported", "Planned", "Historical"],
        "is_editable":   [0, 1, 0]
    }
    dim_scenario = pd.DataFrame(data)
    dim_scenario.to_csv(f"{OUTPUT_DIR}dim_scenario.csv", index=False)
    print(f"STEP 5 - dim_scenario created — {len(dim_scenario)} rows")
    return dim_scenario

dim_scenario = generate_dim_scenario()




def generate_fact_financials():

    dates = pd.date_range(
        start="2023-01-01",
        end="2024-12-31",
        freq="D"
    )

    base_revenue = {1: 850, 2: 620, 3: 490, 4: 710}

    cogs_ratio    = 0.52
    labour_ratio  = 0.12
    sm_ratio      = 0.08
    ga_ratio      = 0.06
    depn_ratio    = 0.03
    other_ratio   = 0.02
    service_ratio = 0.15

    seasonality = {
        1:  0.88, 2:  0.85, 3:  0.92,
        4:  0.95, 5:  0.97, 6:  1.00,
        7:  0.96, 8:  0.98, 9:  1.02,
        10: 1.08, 11: 1.12, 12: 1.18
    }

    rows = []

    for date in dates:
        day         = date.day
        month       = date.month
        year        = date.year
        date_id     = int(date.strftime("%Y%m%d"))
        fiscal      = date.strftime("%Y-%m")
        season_mult = seasonality[month]
        yoy_growth  = 1.08 if year == 2024 else 1.00

        for unit_id in [1, 2, 3, 4]:
            base      = base_revenue[unit_id]
            variation = np.random.uniform(0.95, 1.05)
            daily     = 30

            product_rev  = (base * season_mult * yoy_growth * variation) / daily
            service_rev  = product_rev * service_ratio * np.random.uniform(0.92, 1.08)
            other_inc    = product_rev * other_ratio   * np.random.uniform(0.85, 1.15)
            cogs         = product_rev * cogs_ratio    * np.random.uniform(0.97, 1.03)
            labour       = product_rev * labour_ratio  * np.random.uniform(0.96, 1.04)
            sm_exp       = product_rev * sm_ratio      * np.random.uniform(0.90, 1.10)
            ga_exp       = product_rev * ga_ratio      * np.random.uniform(0.93, 1.07)
            depreciation = product_rev * depn_ratio

            budget_mult = np.random.uniform(1.02, 1.08)

            actuals = {
                101:  product_rev,
                102:  service_rev,
                103:  other_inc,
                201: -cogs,
                202: -labour,
                301: -sm_exp,
                302: -ga_exp,
                401: -depreciation
            }

            budgets = {
                101:  product_rev  * budget_mult,
                102:  service_rev  * budget_mult,
                103:  other_inc    * np.random.uniform(0.98, 1.05),
                201: -cogs         * np.random.uniform(0.95, 1.00),
                202: -labour       * np.random.uniform(0.97, 1.02),
                301: -sm_exp       * np.random.uniform(0.96, 1.04),
                302: -ga_exp       * np.random.uniform(0.95, 1.02),
                401: -depreciation * 1.00
            }

            for account_id in actuals:
                rows.append({
                    "date_id":          date_id,
                    "fiscal_period":    fiscal,
                    "year":             year,
                    "month":            month,
                    "day":              day,
                    "business_unit_id": unit_id,
                    "account_id":       account_id,
                    "scenario_id":      1,
                    "amount":           round(actuals[account_id], 2),
                    "transaction_ref":  f"TXN-{date_id}-{unit_id}-{account_id}-A"
                })
                rows.append({
                    "date_id":          date_id,
                    "fiscal_period":    fiscal,
                    "year":             year,
                    "month":            month,
                    "day":              day,
                    "business_unit_id": unit_id,
                    "account_id":       account_id,
                    "scenario_id":      2,
                    "amount":           round(budgets[account_id], 2),
                    "transaction_ref":  f"TXN-{date_id}-{unit_id}-{account_id}-B"
                })

    df = pd.DataFrame(rows)

    # ANOMALY 1 — West Division Revenue Spike Oct 2023
    mask1 = (
        (df["business_unit_id"] == 4) &
        (df["fiscal_period"]    == "2023-10") &
        (df["account_id"]       == 101) &
        (df["scenario_id"]      == 1)
    )
    df.loc[mask1, "amount"] = df.loc[mask1, "amount"] * 3.4
    print("  Anomaly 1 planted — West Division revenue spike Oct 2023")

    # ANOMALY 2 — South Division Cost Overrun Q3 2024
    mask2 = (
        (df["business_unit_id"] == 2) &
        (df["fiscal_period"].isin(["2024-07","2024-08","2024-09"])) &
        (df["account_id"]       == 302) &
        (df["scenario_id"]      == 1)
    )
    df.loc[mask2, "amount"] = df.loc[mask2, "amount"] * 1.67
    print("  Anomaly 2 planted — South Division cost overrun Q3 2024")

    # ANOMALY 3 — East Division Missing Accrual Dec 2023
    mask3 = (
        (df["business_unit_id"] == 3) &
        (df["fiscal_period"]    == "2023-12") &
        (df["account_id"]       == 401) &
        (df["scenario_id"]      == 1)
    )
    df.loc[mask3, "amount"] = 0.00
    print("  Anomaly 3 planted — East Division missing accrual Dec 2023")

    # ANOMALY 4 — North Division COGS Breach Jun 2024
    mask4 = (
        (df["business_unit_id"] == 1) &
        (df["fiscal_period"]    == "2024-06") &
        (df["account_id"]       == 201) &
        (df["scenario_id"]      == 1)
    )
    df.loc[mask4, "amount"] = df.loc[mask4, "amount"] * 1.45
    print("  Anomaly 4 planted — North Division COGS breach Jun 2024")

    df.to_csv(f"{OUTPUT_DIR}fact_financials.csv", index=False)
    print(f"STEP 6 of 7 — fact_financials created — {len(df):,} rows")
    return df

fact_financials = generate_fact_financials()




def generate_fact_intercompany():
    dates = pd.date_range(
        start="2023-01-01",
        end="2024-12-31",
        freq="D"
    )
    mismatch_months = ["2023-04", "2023-09", "2024-03"]
    rows = []

    for i, date in enumerate(dates):
        fiscal      = date.strftime("%Y-%m")
        date_id     = int(date.strftime("%Y%m%d"))
        base_amount = round(np.random.uniform(1.5, 3.5), 2)

        if fiscal in mismatch_months:
            received = round(base_amount * np.random.uniform(0.82, 0.91), 2)
            status   = "MISMATCH"
        else:
            received = base_amount
            status   = "MATCHED"

        rows.append({
            "transaction_id":    f"IC-{i+1:05d}",
            "date_id":           date_id,
            "fiscal_period":     fiscal,
            "sending_unit_id":   1,
            "receiving_unit_id": 3,
            "amount_sent":       base_amount,
            "amount_received":   received,
            "variance":          round(base_amount - received, 2),
            "status":            status,
            "description":       "Component supply — North to East"
        })

    df = pd.DataFrame(rows)
    df.to_csv(f"{OUTPUT_DIR}fact_intercompany.csv", index=False)
    mismatches = len(df[df["status"] == "MISMATCH"])
    print(f"STEP 7 of 7 — fact_intercompany created — {len(df):,} rows")
    print(f"  Mismatches planted — {mismatches} days across 3 months")
    return df

fact_intercompany = generate_fact_intercompany()



total_rows = (
    len(dim_date) +
    len(dim_bu) +
    len(dim_account) +
    len(dim_scenario) +
    len(fact_financials) +
    len(fact_intercompany)
)

print("\n")
print("=" * 55)
print("  MERIDIAN GROUP — DATA GENERATION COMPLETE")
print("=" * 55)
print(f"  dim_date              {len(dim_date):>8,} rows")
print(f"  dim_business_unit     {len(dim_bu):>8,} rows")
print(f"  dim_account           {len(dim_account):>8,} rows")
print(f"  dim_scenario          {len(dim_scenario):>8,} rows")
print(f"  fact_financials       {len(fact_financials):>8,} rows")
print(f"  fact_intercompany     {len(fact_intercompany):>8,} rows")
print("=" * 55)
print(f"  TOTAL ROWS            {total_rows:>8,} rows")
print("=" * 55)
print("  ANOMALIES PLANTED:")
print("  1  West Division revenue spike    Oct 2023")
print("  2  South Division cost overrun    Q3 2024")
print("  3  East Division missing accrual  Dec 2023")
print("  4  North Division COGS breach     Jun 2024")
print("  5  Intercompany mismatches        3 months")
print("=" * 55)
print("  All CSV files saved to data/raw/")
print("=" * 55)