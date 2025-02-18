from datetime import date

from analysis.dataset_definition import dataset  # noqa: F401

test_data = {
    1: {
        "clinical_events": [
            {
                "numeric_value": 7,
                "snomedct_code": "1013211000000103",
                "date": date(2020, 4, 1),
            },
            {"snomedct_code": "1013211000000103", "date": date(2020, 4, 1)},
        ],
        "patients": {},
        "practice_registrations": {},
        "expected_in_population": True,
        "expected_columns": {"codelist_event_count": 2, "test_value_count": 1},
    }
}

