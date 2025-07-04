import pandas as pd
import numpy as np

def roundmid_any(x, to=6):
    x = np.asarray(x) 
    return np.ceil(x / to) * to - (np.floor(to / 2) * (x != 0))

tests = [
    'alt', 'chol', 
    #'rbc' 'sodium', 'hba1c'
    ]
summary_dict = {}

for test in tests:
    df = pd.read_csv(f"output/{test}/proxy_null/numeric_value_dataset_{test}.csv")
    df = df[['numeric_value', 'codelist_event_count']].agg(['sum', 'mean', 'median', 'var', 'std', 'count'])
    breakpoint()
    df["test_name"] = test  # Add a column to identify the source
    summary_dict[test] = df
    
# Combine all into a single dataframe
summary_df = pd.concat(summary_dict.values(), ignore_index=True)
summary_df.to_csv("output/summary.csv")



