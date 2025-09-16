from datetime import date

from analysis.proxy_null_analysis.value_dataset_definition import dataset  

test_data = { #tests alt
    1: {
        "clinical_events_ranges": [
            {
                "numeric_value": 34,
                "snomedct_code": "1013211000000103",
                "date": date(2020, 4, 1),
                "lower_bound": 0,
                "upper_bound": 76,
                "comparator": "<",
            },
            {
                "numeric_value": 0,
                "snomedct_code": "1013211000000103",
                "date": date(2020, 5, 1),
                "lower_bound": 2,
                "upper_bound": 100,
                "comparator": "~",
            },
        ],
        "patients": {

        },
        "expected_in_population": True,
        "expected_columns": {
            "zero_count": 1,
            "codelist_event_count": 2,
            "codelist_event_exists": 1,
            "numeric_value": 34,
            "upper_bound": 76,
            "lower_bound": 0
        },
    }
}

