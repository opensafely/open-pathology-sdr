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
yaml_template = """
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

yaml_body = """
  generate_numeric_value_dataset:
    run: >
      ehrql:v1 generate-dataset
        analysis/numeric_value_dataset_definition.py
        --output output/numeric_value_dataset.csv
        --
        --codelist codelists/opensafely-alanine-aminotransferase-alt-tests.csv
    outputs:
      highly_sensitive:
        dataset: output/numeric_value_dataset.csv
  generate_numeric_value_histogram:
    run: >
      r:latest analysis/histogram.r --codelist codelists/opensafely-alanine-aminotransferase-alt-tests.csv
    needs: [generate_numeric_value_dataset]
    outputs:
      moderately_sensitive:
        dataset: output/alt_numeric_values.png
"""
needs = {}
codelists = {'alt': 'codelists/opensafely-alanine-aminotransferase-alt-tests.csv',
             'chol': 'codelists/opensafely-cholesterol-tests.csv',
             'hba1c': 'codelists/opensafely-glycated-haemoglobin-hba1c-tests.csv', 
             'rbc': 'codelists/opensafely-red-blood-cell-rbc-tests.csv', 
             'sodium': 'codelists/opensafely-sodium-tests-numerical-value.csv'}
measures = ['has_test_value', 'has_equality_comparator', 'has_differential_comparator',
            'has_lower_bound', 'has_upper_bound']

for test, path in codelists.items():

    for measure in measures:
        yaml_body += yaml_template.format(test = test, codelist_path = path, measure = measure)

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