# open-pathology-sdr

# Pipeline

- There are two pipelines for distinct sets of data:
   1. Completeness measures
   2. Proxy null analysis dataset

**Completeness measures**
1. Extract measures using `generate_measures_{test}_{measure}` (runs `measure_definition.py`), where test = {alt, cholesterol, hba1c etc.} and measure = {has_test_value, has_lower_bound etc.}

**Proxy null analysis dataset**
1. Extract dataset using `generate_value_dataset_{test}` (runs `proxy_null_analysis/value_dataset_definition.py`), where test = {alt, cholesterol, hba1c etc.}
2. Generate frequency table of 1000 most common test and reference range values and total number of tests using `generate_value_table_{test}` (runs `analysis/proxy_null_analysis/generate_freq_table.r`)
3. Generate a histogram of the top 1000 most common test and reference range values using `generate_value_histogram_{test}` (runs `analysis/proxy_null_analysis/generate_histogram.r`)
4. Generate summary statistics of the extracted test/reference range values using `generate_value_summary` (runs `analysis/proxy_null_analysis/summary_stats.py`)

Additionally, total patient counts for both sets of data are generate using `generate_patient_counts` (runs `analysis/count_patients.py`).

# Notes

[View on OpenSAFELY](https://jobs.opensafely.org/repo/https%253A%252F%252Fgithub.com%252Fopensafely%252Fopen-pathology-sdr)

Details of the purpose and any published outputs from this project can be found at the link above.

The contents of this repository MUST NOT be considered an accurate or valid representation of the study or its purpose.
This repository may reflect an incomplete or incorrect analysis with no further ongoing work.
The content has ONLY been made public to support the OpenSAFELY [open science and transparency principles](https://www.opensafely.org/about/#contributing-to-best-practice-around-open-science) and to support the sharing of re-usable code for other subsequent users.
No clinical, policy, or safety conclusions must be drawn from the contents of this repository.

# About the OpenSAFELY framework

The OpenSAFELY framework is a Trusted Research Environment (TRE) for electronic health records research in the NHS,
with a focus on public accountability and research quality.

Read more at [OpenSAFELY.org](https://opensafely.org).

# Licences

As standard, research projects have a MIT license.
