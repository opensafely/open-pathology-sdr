# This script creates a dataset file version of the measures file
# for testing purposes

import argparse
from ehrql import codelist_from_csv
from ehrql.tables.core import clinical_events as events
from ehrql.tables.core import patients
from ehrql.tables.tpp import practice_registrations as registrations
from ehrql import create_dataset

dataset = create_dataset()
parser = argparse.ArgumentParser()
parser.add_argument("--codelist")
args = parser.parse_args()
start_date = "2020-03-31"
end_date = "2021-03-31"

# Codelists
# --------------------------------------------------------------------------------------
codelist = codelist_from_csv(args.codelist, column="code")
codelist_events = events.where(
    events.snomedct_code.is_in(codelist)
    & events.date.is_on_or_between(start_date, end_date)
)

dataset.region = registrations.for_patient_on(start_date).practice_nuts1_region_name

dataset.codelist_event_count = codelist_events.count_for_patient()

dataset.test_value_count = codelist_events.where(
    events.numeric_value.is_not_null()
).count_for_patient()

dataset.define_population(patients.exists_for_patient())

