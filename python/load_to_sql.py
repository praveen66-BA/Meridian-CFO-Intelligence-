

import pandas as pd
from sqlalchemy import create_engine, text
import os

SERVER   = "localhost\\SQLEXPRESS"
DATABASE = "MeridianCFO"
DRIVER   = "ODBC Driver 17 for SQL Server"

connection_string = (
    f"mssql+pyodbc://@{SERVER}/{DATABASE}"
    f"?driver={DRIVER}&trusted_connection=yes"
)

print("Connecting to SQL Server...")

try:
    engine = create_engine(connection_string)
    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))
    print("Connected successfully")
except Exception as e:
    print(f"Connection failed: {e}")
    exit()


def load_table(filename, table_name):
    filepath = f"data/raw/{filename}"

    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        return

    df = pd.read_csv(filepath)

    df.to_sql(
        table_name,
        engine,
        if_exists="append",
        index=False,
        chunksize=1000
    )

    print(f"  Loaded {table_name:25s} — {len(df):>8,} rows")


print("\nLoading all tables...")
print("=" * 55)

load_table("dim_date.csv",          "dim_date")
load_table("dim_business_unit.csv", "dim_business_unit")
load_table("dim_account.csv",       "dim_account")
load_table("dim_scenario.csv",      "dim_scenario")
load_table("fact_financials.csv",   "fact_financials")
load_table("fact_intercompany.csv", "fact_intercompany")

print("=" * 55)
print("All data loaded successfully into MeridianCFO")
print("Ready for SQL queries")
print("=" * 55)