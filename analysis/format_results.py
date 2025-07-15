# USAGE: python analysis/format_results.py --path_test [alt or chol or hba1c or hba1c_numeric or rbc or sodium]
# RELEASED RESULTS SHOULD BE IN "OUTPUT/OUTPUT/[alt or chol or hba1c or rbc or sodium]"
# GENERATES RESULTS TABLES

import pandas as pd
from pathlib import Path
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--path_test")
args = parser.parse_args()

# Load CSV files
measures = [
            'differential_comparator', 'equality_comparator', 
            'lower_bound', 'upper_bound', 
            'test_value'
            ]

measures_dict = {}

for measure in measures:

  measures_dict[measure] = pd.read_csv(Path(f"output/output/measures_{args.path_test}_has_{measure}.csv"))

  # Select only needed columns
  cols_to_keep = ['measure', 'interval_start', 'numerator', 'denominator', 'region']
  measures_dict[measure] = measures_dict[measure][cols_to_keep]

# Combine into long format (stacked)
processed_dict = {}
processed_dict['df_test_value'] = measures_dict['test_value']
del measures_dict['test_value']
processed_dict['df_long'] = pd.concat(measures_dict.values(), ignore_index=True)

results_dict = {}
for df in processed_dict.keys():
  # Pivot to wide format
  results_dict[f'final_{df}'] = processed_dict[df].pivot_table(
      index=['interval_start', 'denominator', 'region'],  # add other identifiers if needed
      columns='measure',
      values='numerator',
      aggfunc='first'  # or 'sum' / 'mean' depending on your needs
  )

  # Optionally flatten column names if needed
  results_dict[f'final_{df}'].columns = [f'numerator_{col}' for col in results_dict[f'final_{df}'].columns]
  results_dict[f'final_{df}'] = results_dict[f'final_{df}'].reset_index()

  # Calculate rate per 1000
  if df == 'df_test_value':
    measures =  ['test_value']
  else:
    measures = ['differential_comparator', 'equality_comparator', 'lower_bound', 'upper_bound']
  for measure in measures:
    results_dict[f'final_{df}'][f'rate_{measure}'] = ((results_dict[f'final_{df}'][f'numerator_has_{measure}'] / 
                                                       results_dict[f'final_{df}']['denominator'])*100)

  # Display final wide datacframe
  print(results_dict[f'final_{df}'].head())
  print(results_dict[f'final_{df}'].isna().sum())
  print(len(results_dict[f'final_{df}']))

results_dict['final_df_test_value'].rename(columns={"denominator": "test_val_denom"}, inplace=True)
results_df = pd.merge(results_dict[f'final_df_long'], results_dict['final_df_test_value'],
                      on = ['interval_start', 'region'])
# Columns you want at the front
front_cols = ['rate_test_value',	'rate_lower_bound',	'rate_upper_bound',	'rate_equality_comparator',	'rate_differential_comparator']
# Reorder columns: front_cols first, then the rest
new_order = front_cols + [col for col in results_df.columns if col not in front_cols]
# Reassign
results_df = results_df[new_order]

results_df.to_csv(f"output/output/{args.path_test}/results_table_{args.path_test}.csv")