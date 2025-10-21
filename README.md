# open-pathology-sdr

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

# Project Pipeline

**Main Measures**
1. Generate measures with `measure_definition.py`
2. Release measures from Airlock
3. Process raw measures into results tables with `format_results.py`
4. Generate bivariate (regions with time) line plots from results tables using `plots.r`
5. Process results tables into univariate tables using external google sheets document
6. Generate univariate (region or time) line/heatmap plots from univariate tables using `univariate_plots.r`

**Sentinel Values**
1. Extract dataset with `numeric_value_dataset_definition.py`
2. Generate summary stats from dataset with `summary_stats.py`
3. Extract top 1000 values from dataset with `generate_freq_table.r`
4. Generate histogram from top 1000 values with `generate_histogram.r`
Configure codelists in `config.r`

# Licences

As standard, research projects have a MIT license.