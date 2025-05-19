library(optparse)

option_list <- list(make_option(c("--codelist"), type = "character", help = "Path to codelist file"))

# Parse the arguments
opt <- parse_args(OptionParser(option_list = option_list))

if (opt$codelist == 'codelists/opensafely-alanine-aminotransferase-alt-tests.csv'){
    test <- 'alt'
} else if (opt$codelist == 'codelists/opensafely-cholesterol-tests.csv'){
    test <- 'chol'
} else if (opt$codelist == 'codelists/opensafely-glycated-haemoglobin-hba1c-tests.csv'){
    test <- 'hba1c'
} else if (opt$codelist == 'codelists/opensafely-red-blood-cell-rbc-tests.csv'){
    test <- 'rbc'
} else if (opt$codelist == 'codelists/opensafely-sodium-tests-numerical-value.csv'){
    test <- 'sodium'
} 