import pandas as pd
from sqlalchemy import create_engine

engine = create_engine("postgresql+psycopg2://postgres:rayyan123@localhost:5432/dummy_db")

base_path = "../data/"

files = {
    "products": "products.csv",
    "reorders": "reorders.csv",
    "shipments": "shipments.csv",
    "stock_entries": "stock_entries.csv",
    "suppliers": "suppliers.csv",
}

for table, filename in files.items():
    df = pd.read_csv(base_path + filename)
    df.to_sql(table, engine, index=False, if_exists="fail")
    print(f"Imported {table}")
