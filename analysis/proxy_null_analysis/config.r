library(optparse)

option_list <- list(make_option(c("--test"), type = "character", default = NULL, help = "Test"),
                    make_option(c("--test_run"), action = "store_true", default = FALSE, 
                    help = "Uses test data instead of full data"))

# Parse the arguments
opt <- parse_args(OptionParser(option_list = option_list))

if (is.null(opt$test)) {
    codelist <- NULL
} else if (opt$test == 'alt') {
    codelist <- 'codelists/opensafely-alanine-aminotransferase-alt-tests.csv'
} else if (opt$test == 'chol') {
    codelist <- 'codelists/opensafely-cholesterol-tests.csv'
} else if (opt$test == 'hba1c') {
    codelist <- 'codelists/opensafely-glycated-haemoglobin-hba1c-tests.csv'
} else if (opt$test == 'rbc') {
    codelist <- 'codelists/opensafely-red-blood-cell-rbc-tests.csv'
} else if (opt$test == 'sodium') {
    codelist <- 'codelists/opensafely-sodium-tests-numerical-value.csv'
} else if (opt$test == 'hba1c_numeric') {
    codelist <- 'codelist/opensafely/glycated-haemoglobin-hba1c-tests-numerical-value.csv'
}

if (opt$test_run){
    test <- 'alt'
    codelist <- 'codelists/opensafely-alanine-aminotransferase-alt-tests.csv'
}
