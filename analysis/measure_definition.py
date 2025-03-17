import argparse
from ehrql import INTERVAL, Measures, codelist_from_csv, years
from ehrql.tables.tpp import clinical_events_ranges as ranges
from ehrql.tables.tpp import practice_registrations as registrations

parser = argparse.ArgumentParser()
parser.add_argument("--codelist")
args = parser.parse_args()
index_date = "2018-01-01"

# Codelists
codelist = codelist_from_csv(args.codelist, column="code")
codelist_events = ranges.where(
    ranges.snomedct_code.is_in(codelist) & ranges.date.is_during(INTERVAL)
)

# Stratification variables
region = registrations.for_patient_on(INTERVAL.start_date).practice_nuts1_region_name

# Presence of codelist (denominator)
codelist_event_count = codelist_events.count_for_patient()

# Booleans
has_test_value = ranges.numeric_value.is_not_null()
has_equality_comparator = ranges.comparator.is_in(["=", "~"])
has_differential_comparator = ranges.comparator.is_not_null() & ~has_equality_comparator
has_upper_bound = ranges.upper_bound.is_not_null()
has_lower_bound = ranges.lower_bound.is_not_null()

# Create filtered table for each query
count_measures = {}
count_measures['has_test_value'] = codelist_events.where(
    has_test_value
)
count_measures['has_equality_comparator'] = codelist_events.where(
    has_equality_comparator
)
count_measures['has_differential_comparator'] = codelist_events.where(
    has_differential_comparator
)
count_measures['has_upper_bound'] = codelist_events.where(
    has_lower_bound
)
count_measures['has_lower_bound'] = codelist_events.where(
    has_upper_bound
)

# Measures
# --------------------------------------------------------------------------------------
measures = Measures()
measures.configure_dummy_data(population_size=1000, legacy=True)
measures.define_defaults(
    denominator=codelist_event_count,
    intervals=years(1).starting_on(index_date),
    group_by={"region": region},
)

for measure, table in count_measures.items():
    measures.define_measure(
        name=measure,
        numerator=table.count_for_patient(),
    )
