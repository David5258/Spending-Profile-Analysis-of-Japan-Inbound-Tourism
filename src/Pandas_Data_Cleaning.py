import pandas as pd


df_raw = pd.read_excel("Insert_Path", sheet_name="Others & Grand Total", header=None)

region_row = df_raw.iloc[3]   # Region names
purpose_row = df_raw.iloc[4]  # Purposes under each region


region_names = region_row.ffill()

# Create column names
column_names = []
for region, purpose in zip(region_names, purpose_row):
    region = str(region).strip() if pd.notna(region) else ""
    purpose = str(purpose).strip().replace(" ", "_") if pd.notna(purpose) else ""
    combined = f"{region}_{purpose}" if region and purpose else region or purpose
    column_names.append(combined)

# Load data starting from row 5 (row where the data we want starts on the excel sheet)
data = df_raw.iloc[5:].copy()
data.columns = column_names

data["Year"] = df_raw.iloc[5:, 0].ffill().values
data["Month"] = df_raw.iloc[5:, 1].astype(str).str.replace("．", ".", regex=False).str.strip()

data = data.dropna(subset=["Month"])

purposes = ["Total", "Tourist", "Business", "Others", "Short_Excursion"]

regions = list({col.rsplit("_", 1)[0] for col in data.columns if col.endswith("_Total")})

rows = []
for region in regions:
    row_df = data[["Year", "Month"]].copy()
    row_df["Region"] = region
    for purpose in purposes:
        col_name = f"{region}_{purpose}"
        if col_name in data.columns:
            row_df[purpose] = data[col_name]
        else:
            row_df[purpose] = pd.NA
    rows.append(row_df)

df_cleaned = pd.concat(rows, ignore_index=True)

# Clean numbers where we remove commas, extract digits and convert to integers
for purpose in purposes:
    df_cleaned[purpose] = (
        df_cleaned[purpose]
        .astype(str)
        .str.replace(",", "")
        .str.extract(r"(\d+)", expand=False)
        .fillna("0")
        .astype(int)
    )

# Sort the months in calendar order
month_order = ["Jan.", "Feb.", "Mar.", "Apr.", "May.", "Jun.",
               "Jul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec."]
df_cleaned["Month"] = pd.Categorical(df_cleaned["Month"], categories=month_order, ordered=True)
df_cleaned = df_cleaned.sort_values(by=["Year", "Month", "Region"])

df_cleaned = df_cleaned[["Year", "Month", "Region", "Total", "Tourist", "Business", "Others", "Short_Excursion"]]

df_cleaned.to_csv("new_name.csv", index=False)

