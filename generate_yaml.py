"""
Description: 
- This script generates the YAML file for the project.

Usage:
- python generate_yaml.py

Output:
- project.yaml
"""

from datetime import datetime, timedelta

# --- YAML HEADER ---

yaml_header = """
version: '4.0'

actions:
"""

# --- YAML MEASURES BODY ----


# Template for measures generation
yaml_measure_template = """
  generate_measures_{test}_{measure}:
    run: >
      ehrql:v1 generate-measures
        analysis/measure_definition.py
        --output output/measures_{test}_{measure}.csv
        --
        --codelist {codelist_path}
        --measure {measure}
    outputs:
      moderately_sensitive:
        measures: output/measures_{test}_{measure}.csv
"""

yaml_body_template = """
# ----------------- Test: {test} ---------------------------------

  generate_numeric_value_dataset_{test}:
    run: >
      ehrql:v1 generate-dataset
        analysis/proxy_null_analysis/numeric_value_dataset_definition.py
        --output output/{test}/proxy_null/numeric_value_dataset_{test}.csv
        --
        --codelist {path}
    outputs:
      highly_sensitive:
        dataset: output/{test}/proxy_null/numeric_value_dataset_{test}.csv
  generate_numeric_value_table_{test}:
    run: >
      r:latest analysis/proxy_null_analysis/generate_freq_table.r 
      --codelist {path}
    needs: [generate_numeric_value_dataset_{test}]
    outputs:
      moderately_sensitive:
        dataset: output/{test}/proxy_null/top_1000_numeric_values_{test}.csv
  generate_numeric_value_histogram_{test}:
    run: >
      r:latest analysis/proxy_null_analysis/generate_histogram.r 
      --codelist {path}
    needs: [generate_numeric_value_table_{test}]
    outputs:
      moderately_sensitive:
        pic: output/{test}/proxy_null/numeric_values_{test}.png
        pic2: output/{test}/proxy_null/numeric_values_zoomed_{test}.png
  #generate_numeric_value_summary_{test}:
  #  run: >
  #    python:latest analysis/proxy_null_analysis/summary_stats.py
  #  needs: [generate_numeric_value_dataset_{test}]
  #  outputs:
  #    moderately_sensitive:
  #      table: output/{test}/proxy_null/numeric_value_summary_{test}.csv
"""

yaml_body = ""
needs = {}
codelists = {'alt': 'codelists/opensafely-alanine-aminotransferase-alt-tests.csv',
             'chol': 'codelists/opensafely-cholesterol-tests.csv',
             'hba1c': 'codelists/opensafely-glycated-haemoglobin-hba1c-tests.csv', 
             'rbc': 'codelists/opensafely-red-blood-cell-rbc-tests.csv', 
             'sodium': 'codelists/opensafely-sodium-tests-numerical-value.csv',
             'hba1c_numeric': 'codelists/opensafely-glycated-haemoglobin-hba1c-tests-numerical-value.csv'}
measures = ['has_test_value', 'has_equality_comparator', 'has_differential_comparator',
            'has_lower_bound', 'has_upper_bound']

for test, path in codelists.items():
    yaml_body += yaml_body_template.format(test = test, path = path)
    for measure in measures:
        yaml_body += yaml_measure_template.format(test = test, codelist_path = path, measure = measure)

# ---- YAML TESTS ------
yaml_test = '''
  # Runs test to ensure correctness of measures queries
  generate_test_dataset:
    run: >
      ehrql:v1 generate-dataset
        analysis/dataset_definition.py
        --output output/test_dataset.csv
        --test-data-file analysis/test_dataset_definition.py
        --
        --codelist codelists/opensafely-alanine-aminotransferase-alt-tests.csv
    outputs:
      highly_sensitive:
        dataset: output/test_dataset.csv
'''
yaml = yaml_header + yaml_body + yaml_test
with open("project.yaml", "w") as file:
       file.write(yaml)