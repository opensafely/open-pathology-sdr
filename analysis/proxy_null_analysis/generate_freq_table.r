library(ggplot2)
library(dplyr)
library(glue)
library(tidyverse)
source("analysis/proxy_null_analysis/config.r") # Provides opt$codelist and test variables

# A function to apply midpoint rounding as per OS documentation on disclosure control
roundmid_any <- function(x, to=6){
  ceiling(x/to)*to - (floor(to/2)*(x!=0))
}

measures <- read.csv(glue('output/{test}/proxy_null/value_dataset_{test}.csv'))

#--------- Create frequency table -------------------------------------------------

fields <- c("numeric_value", "lower_bound", "upper_bound")
total_tests_midpoint6_list <- list() 

for (field in fields) {

  # Select relevant columns
  measures_sub <- select(measures, codelist_event_count, all_of(field))

  # Extract total number of tests in time period
  total_tests <- sum(measures_sub$codelist_event_count, na.rm = TRUE)
  total_tests_midpoint6 <- roundmid_any(total_tests)

  # Add total to table
  total_tests_midpoint6_list[[length(total_tests_midpoint6_list) + 1]] <- tibble(
    test = test,
    field = field,
    total_tests_midpoint6 = total_tests_midpoint6
  )

  # Generate frequency per value table
  freq_table <- as.data.frame(table(measures_sub[[field]]))
  colnames(freq_table) <- c("value", "count")
  freq_table$value <- as.numeric(as.character(freq_table$value))

  # Extract 1000 most common values
  top_1000 <- freq_table %>%
    arrange(desc(count)) %>%
    slice_head(n = 1000) %>%
    mutate(
      count_midpoint6 = roundmid_any(count),
      propn_midpoint6 = ((count_midpoint6 / total_tests_midpoint6)*100)
    ) %>%
    select(value, count_midpoint6, propn_midpoint6)

  # Save top 1000 table per field
  write.csv(
    top_1000,
    glue("output/{test}/proxy_null/top_1000_{field}_{test}.csv"),
    row.names = FALSE
  )
}

# Combine all totals into one table and write it
total_tests_midpoint6_df <- bind_rows(total_tests_midpoint6_list)

write_csv(
  total_tests_midpoint6_df,
  glue("output/{test}/proxy_null/total_tests_midpoint6_{test}.csv")
)


