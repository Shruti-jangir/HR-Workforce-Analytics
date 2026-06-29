"""
hr_dataset.py
Generates synthetic HR workforce dataset of 1,240 employees.
Run: python scripts/01_generate_dataset.py
Output: data/raw/hr_employees.csv
"""
import pandas as pd, numpy as np, random, os
from faker import Faker
from datetime import date, timedelta

fake = Faker("en_IN")
np.random.seed(42); random.seed(42)

N        = 1240
DEPTS    = {"Engineering":0.30,"Sales":0.22,"Operations":0.18,
            "Finance":0.12,"HR":0.08,"Marketing":0.06,"Legal":0.04}
LEVELS   = ["Junior","Mid","Senior","Lead","Manager","Director"]
EDUCATION= ["Bachelor's","Master's","PhD","Diploma","High School"]
CITIES   = ["Bengaluru","Mumbai","Delhi","Hyderabad","Pune","Chennai","Kolkata"]
REASONS  = ["Better compensation","Limited growth","Work-life balance",
            "Manager issues","Relocation","Personal reasons","Retirement"]
SAL      = {"Engineering":(700000,1800000),"Sales":(450000,1100000),
            "Operations":(380000,950000),"Finance":(600000,1400000),
            "HR":(400000,900000),"Marketing":(500000,1200000),"Legal":(800000,2000000)}
LMULT    = {"Junior":0.7,"Mid":1.0,"Senior":1.3,"Lead":1.5,"Manager":1.8,"Director":2.4}

def rdate(sy=2015, ey=2023):
    s, e = date(sy,1,1), date(ey,12,31)
    return s + timedelta(days=random.randint(0,(e-s).days))

rows = []
for i, dept in enumerate(random.choices(list(DEPTS), weights=list(DEPTS.values()), k=N)):
    lv   = random.choices(LEVELS, weights=[25,30,20,12,10,3], k=1)[0]
    hd   = rdate()
    ten  = round((date(2024,12,31)-hd).days/365, 2)
    sal  = int(random.randint(*SAL[dept]) * LMULT[lv] * random.uniform(0.9,1.1))
    perf = round(float(np.clip(np.random.normal(3.4, 0.8), 1, 5)), 1)
    sat  = round(float(np.clip(np.random.normal(3.6, 0.9), 1, 5)), 1)

    prob = 0.10
    if dept in ("Sales","Operations"): prob += 0.08
    if perf  < 2.5:  prob += 0.12
    if ten   < 1.5:  prob += 0.10

    att = random.random() < prob
    ed = er = None
    if att:
        d  = random.randint(90, max(90, int(ten*365)))
        ed = hd + timedelta(days=d)
        if ed > date(2024,12,31): ed = date(2024,12,31) - timedelta(days=random.randint(1,60))
        er  = random.choices(REASONS, weights=[31,24,19,14,6,4,2], k=1)[0]
        sat = round(float(np.clip(np.random.normal(2.8, 0.9), 1, 5)), 1)

    rows.append({
        "employee_id":       f"EMP{1001+i}",
        "full_name":         fake.name(),
        "gender":            random.choices(["Male","Female","Non-binary"], weights=[52,45,3], k=1)[0],
        "age":               random.randint(22, 52),
        "education":         random.choices(EDUCATION, weights=[45,35,8,8,4], k=1)[0],
        "city":              random.choice(CITIES),
        "department":        dept,
        "job_title":         f"{lv} {dept} Specialist",
        "job_level":         lv,
        "employment_type":   random.choices(["Full-time","Part-time","Contract"], weights=[72,15,13], k=1)[0],
        "hire_date":         hd.isoformat(),
        "exit_date":         ed.isoformat() if ed else None,
        "tenure_years":      ten,
        "annual_salary_inr": sal,
        "performance_score": perf,
        "satisfaction_score":sat,
        "training_hours":    random.randint(4, 80),
        "promotions":        random.choices([0,1,2,3], weights=[55,30,12,3], k=1)[0],
        "manager_id":        f"EMP{random.randint(1001,1100)}",
        "attrition":         "Yes" if att else "No",
        "exit_reason":       er,
    })

out = os.path.join(os.path.dirname(__file__), "..", "data", "raw", "hr_employees.csv")
os.makedirs(os.path.dirname(out), exist_ok=True)
df = pd.DataFrame(rows)
df.to_csv(out, index=False)
print(f"Saved {df.shape} -> {out}")
print(f"Attrition rate: {(df.attrition=='Yes').mean():.1%}")
