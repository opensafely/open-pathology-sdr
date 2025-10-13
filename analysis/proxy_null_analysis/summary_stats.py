# This script produces summary stats for test value and reference range measures
# USAGE: python analysis/proxy_null_analysis/summary_stats.py

import os
import pandas as pd


# Define lower and upper quartile functions
def q25(x):
    return x.quantile(0.25)


def q75(x):
    return x.quantile(0.75)


tests = ["alt", "chol", "hba1c", "rbc", "sodium", "hba1c_numeric", "alt_numeric"]
filtered = [False, True]

# Iterate over each test
for test in tests:

    output_path = f"output/{test}/proxy_null/value_summary_{test}"
    df = pd.read_csv(f"output/{test}/proxy_null/value_dataset_{test}.csv")

    cols = ["numeric_value", "upper_bound", "lower_bound"]
    summary_dict = {}  # store all summaries for this test

    # Loop over filter condition
    for to_filter in filtered:

        # Work on a copy to avoid filtering previous iterations
        df_sub = df.copy()

        for col in cols:

            if to_filter:

                # Filter out <=0
                df_sub = df_sub[(df_sub[col] > 0) & (df_sub[col].notnull())]
                name_suffix = "_filtered"

            else:
                df_sub = df_sub[df_sub[col].notnull()]
                name_suffix = ""

            # Summarise test and reference range measures
            summary = df_sub[col].agg(
                ["sum", "mean", "median", "var", "std", "count", "nunique", q25, q75]
            )

            # Add to dict with descriptive key
            summary_dict[f"{col}{name_suffix}"] = summary

    # Combine summaries for all cols + filter states
    summary_df = pd.concat(summary_dict.values(), axis=1)
    summary_df.columns = summary_dict.keys()  # label columns properly

    # Save output
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    summary_df.to_csv(f"{output_path}.csv")
