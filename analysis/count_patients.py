import pandas as pd
import math

def roundmid_any(x, to=6):
    return math.ceil(x / to) * to - (math.floor(to / 2) * (x != 0))

# Count patients in alt dataset, but this will represent all tests
one_pp_df = pd.read_csv('output/alt/proxy_null/value_dataset_alt.csv')
mul_pp_df = pd.read_csv('output/measures_alt_has_test_value.csv')

# Count number of rows (patients) in each
one_pp_count = one_pp_df.shape[0]
mul_pp_count = mul_pp_df.shape[0]

# Create df
count_df = pd.DataFrame({
    'dataset': ['one_pp_data', 'multi_pp_data'],
    'patient_count': [one_pp_count, mul_pp_count]
})

# Midpoint 6 rounding
count_df['patient_count'] = count_df['patient_count'].apply(lambda x: roundmid_any(x, to=6))

# Save output
count_df.to_csv('output/patient_counts.csv', index=False)

