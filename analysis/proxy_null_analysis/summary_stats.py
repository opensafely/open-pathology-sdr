# This script produces summary stats for test value and reference range measures
# USAGE: python analysis/proxy_null_analysis/summary_stats.py (no options)

import os
import pandas as pd

# Define lower and upper quartile functions
def q25(x): return x.quantile(0.25)
def q75(x): return x.quantile(0.75)

tests = ['alt', 'chol', 'hba1c', 'rbc', 'sodium', 'hba1c_numeric', 'alt_numeric']

# Iterate over each test
for test in tests:

    path = f'output/{test}/proxy_null/value_dataset_{test}.csv'
    df = pd.read_csv(path)
    # Filter to only descirbe 'real' tests
    df = df[(df['numeric_value'] > 0) & (df['numeric_value'].notnull())]

    # Summarise each of the following fields:
    cols = ['numeric_value', 'upper_bound', 'lower_bound']

    # Summarise test and reference range measures
    summary = df[cols].agg(['sum','mean','median','var','std','count','nunique', q25, q75])
    summary.to_csv(f'output/{test}/proxy_null/value_summary_{test}.csv')

