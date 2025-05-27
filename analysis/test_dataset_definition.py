from datetime import date

from analysis.dataset_definition import dataset  # noqa: F401

test_data = {
    1: {
        "clinical_events_ranges": [
            {
                "numeric_value": 30,
                "snomedct_code": "1013211000000103",
                "date": date(2020, 4, 1),
                "lower_bound": 23,
                "upper_bound": 76,
                "comparator": "<",
            },
            {
                "numeric_value": 0,
                "snomedct_code": "1013211000000103",
                "date": date(2020, 4, 1),
                "lower_bound": 23,
                "upper_bound": 76,
                "comparator": "~",
            },
        ],
        "patients": {

        },
        "expected_in_population": True,
        "expected_columns": {
            "has_test_value": 1,
        },
    }
}

