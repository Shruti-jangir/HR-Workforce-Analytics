"""
02_data_cleaning.py
Cleans raw HR data and engineers analytical features.
Run: python scripts/02_data_cleaning.py
Input:  data/raw/hr_employees.csv
Output: data/processed/hr_cleaned.csv
"""
import pandas as pd, numpy as np, os

RAW = os.path.join(os.path.dirname(__file__), "..", "data", "raw",       "hr_employees.csv")
OUT = os.path.join(os.path.dirname(__file__), "..", "data", "processed", "hr_cleaned.csv")

df = pd.read_csv(RAW, parse_dates=["hire_date","exit_date"])
print(f"[load]  {df.shape[0]} rows | {df.shape[1]} columns")
print(f"[miss]  Missing values:\n{df.isnull().sum()[df.isnull().sum()>0]}")

# ── Cleaning ─────────────────────────────────────────────────
df["exit_reason"] = df["exit_reason"].fillna("Active")
df["tenure_years"] = ((pd.Timestamp("2024-12-31") - df["hire_date"]).dt.days / 365).round(2)
cap = df.groupby("department")["annual_salary_inr"].transform(lambda x: x.quantile(0.99))
df["annual_salary_inr"] = df["annual_salary_inr"].clip(upper=cap).astype(int)
str_cols = df.select_dtypes("object").columns
df[str_cols] = df[str_cols].apply(lambda c: c.str.strip())

# ── Feature Engineering ──────────────────────────────────────
df["attrition_flag"]  = (df["attrition"] == "Yes").astype(int)
df["hire_year"]       = df["hire_date"].dt.year
df["hire_month"]      = df["hire_date"].dt.month
df["exit_year"]       = df["exit_date"].dt.year
df["exit_month"]      = df["exit_date"].dt.month
df["age_band"]        = pd.cut(df["age"], [0,25,35,45,100], labels=["18-25","26-35","36-45","46+"], right=False)
df["salary_band"]     = pd.cut(df["annual_salary_inr"], [0,500000,900000,1400000,2000000,9999999],
                                labels=["<5L","5-9L","9-14L","14-20L","20L+"], right=False)
df["perf_category"]   = pd.cut(df["performance_score"], [0,2,3,4,5.1],
                                labels=["Low","Average","Good","Excellent"], right=False)
df["engagement_risk"] = ((df["satisfaction_score"] < 3) & (df["performance_score"] < 3)).astype(int)
df["salary_L"]        = (df["annual_salary_inr"] / 100000).round(2)

os.makedirs(os.path.dirname(OUT), exist_ok=True)
df.to_csv(OUT, index=False)

print(f"\n[done]  Processed data saved -> {OUT}")
print(f"        Shape           : {df.shape}")
print(f"        Attrition rate  : {df.attrition_flag.mean():.1%}")
print(f"        Avg salary      : Rs{df.salary_L.mean():.1f}L")
print(f"        Avg tenure      : {df.tenure_years.mean():.1f} yrs")
print(f"        Engagement risk : {df.engagement_risk.sum()} employees")
