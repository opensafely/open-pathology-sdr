library(optparse)

option_list <- list(make_option(c("--codelist"), type = "character", default = NULL, help = "Path to codelist file"),
                    make_option(c("--test_run"), action = "store_true", default = FALSE, 
                    help = "Uses test data instead of full data"))

# Parse the arguments
opt <- parse_args(OptionParser(option_list = option_list))

if (is.null(opt$codelist)) {
    test <- NULL
} else if (opt$codelist == 'codelists/opensafely-alanine-aminotransferase-alt-tests.csv') {
    test <- 'alt'
} else if (opt$codelist == 'codelists/opensafely-cholesterol-tests.csv') {
    test <- 'chol'
} else if (opt$codelist == 'codelists/opensafely-glycated-haemoglobin-hba1c-tests.csv') {
    test <- 'hba1c'
} else if (opt$codelist == 'codelists/opensafely-red-blood-cell-rbc-tests.csv') {
    test <- 'rbc'
} else if (opt$codelist == 'codelists/opensafely-sodium-tests-numerical-value.csv') {
    test <- 'sodium'
} else if (opt$codelist == 'codelist/opensafely/glycated-haemoglobin-hba1c-tests-numerical-value.csv') {
    test <- 'hba1c_numeric'
}

if (opt$test_run){
    test <- 'alt'
}
