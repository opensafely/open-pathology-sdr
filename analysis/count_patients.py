import pandas as pd
import math


def roundmid_any(x, to=6):
    return math.ceil(x / to) * to - (math.floor(to / 2) * (x != 0))


# Count patients in alt dataset, but this will represent all tests
one_pp_df = pd.read_csv("output/alt/proxy_null/value_dataset_alt.csv")

# Count number of rows (patients) in each
n_patients_in_dataset = one_pp_df.shape[0]

# Create df
count_df = pd.DataFrame(
    {"dataset": ["n_patients_in_dataset"], "patient_count": [n_patients_in_dataset]}
)

# Midpoint 6 rounding
count_df["patient_count"] = count_df["patient_count"].apply(
    lambda x: roundmid_any(x, to=6)
)

# Save output
count_df.to_csv("output/alt/proxy_null/patient_counts.csv", index=False)
