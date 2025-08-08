# USAGE: python analysis/format_results.py --path_test [alt or chol or hba1c or hba1c_numeric or rbc or sodium]
# RELEASED RESULTS SHOULD BE IN "OUTPUT/OUTPUT/[alt or chol or hba1c or rbc or sodium]"
# GENERATES RESULTS TABLES

import pandas as pd
from pathlib import Path
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--path_test")
args = parser.parse_args()

# ======================
# 1. Load CSVs
# ======================
measures = [
    'differential_comparator', 'equality_comparator', 
    'lower_bound', 'upper_bound', 
    'test_value'
]

measures_dict = {}
for measure in measures:
    df = pd.read_csv(Path(f"output/output/measures_{args.path_test}_has_{measure}.csv"))
    # Select only needed columns
    cols_to_keep = ['measure', 'interval_start', 'numerator', 'denominator', 'region']
    measures_dict[measure] = df[cols_to_keep]

# ======================
# 2. Group into blocks
# ======================

df_test_value = measures_dict['test_value'].copy()
df_bounds = pd.concat([
    measures_dict['lower_bound'],
    measures_dict['upper_bound']
], ignore_index=True)
df_comparators = pd.concat([
    measures_dict['differential_comparator'],
    measures_dict['equality_comparator']
], ignore_index=True)

# ======================
# 3. Pivot each block
# ======================

def pivot_block(df, denom_name):
    """Pivot a block of measures to wide format with its own denominator column."""
    df = df.rename(columns={'denominator': denom_name})
    wide = df.pivot_table(
        index=['interval_start', 'region', denom_name],
        columns='measure',
        values='numerator'
    )
    wide.columns = [f'numerator_{col}' for col in wide.columns]
    return wide.reset_index()

final_test_value = pivot_block(df_test_value, 'denominator_test_value')
final_bounds = pivot_block(df_bounds, 'denominator_bounds')
final_comparators = pivot_block(df_comparators, 'denominator_comparators')

# ======================
# 4. Calculate rates
# ======================

for measure in ['test_value']:
    final_test_value[f'rate_{measure}'] = (
        final_test_value[f'numerator_has_{measure}'] / final_test_value['denominator_test_value'] * 100
    )

for measure in ['lower_bound', 'upper_bound']:
    final_bounds[f'rate_{measure}'] = (
        final_bounds[f'numerator_has_{measure}'] / final_bounds['denominator_bounds'] * 100
    )

for measure in ['differential_comparator', 'equality_comparator']:
    final_comparators[f'rate_{measure}'] = (
        final_comparators[f'numerator_has_{measure}'] / final_comparators['denominator_comparators'] * 100
    )

# ======================
# 5. Merge into one table
# ======================

results_df = final_test_value.merge(
    final_bounds, on=['interval_start', 'region'], how='outer'
).merge(
    final_comparators, on=['interval_start', 'region'], how='outer'
)

# ======================
# 6. Reorder columns
# ======================

front_cols = [
    'rate_test_value', 'rate_lower_bound', 'rate_upper_bound',
    'rate_equality_comparator', 'rate_differential_comparator'
]
new_order = front_cols + [col for col in results_df.columns if col not in front_cols]
results_df = results_df[new_order]

# ======================
# 7. Save output
# ======================

results_df.to_csv(f"output/output/{args.path_test}/results_table_{args.path_test}.csv", index=False)

