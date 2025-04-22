import pandas as pd

df = pd.read_csv("output/numeric_value_dataset.csv")

df[['codelist_event_count', 'numeric_value']].agg(['sum', 'mean', 'median', 'var', 'std', 'min', 'max', 'count']).to_csv('output/numeric_value_summary.csv')
