# Usage: Rscript analysis/proxy_null_analysis/generate_histogram.r --test [test]

library(ggplot2)
library(dplyr)
library(scales)
library(glue)
source("analysis/proxy_null_analysis/config.r") # Provides opt$test and codelist variables

if (opt$test_run){
  # Set seed for reproducibility
  set.seed(123)
  # Parameters
  mu <- 2         # Mean (expected propn)
  theta <- 3       # Dispersion parameter: smaller = more overdispersed
  n <- 50000         # Sample size
  sim_data <- rnbinom(n, size = theta, mu = mu)
  # Tabulate and convert to data frame
  top_1000 <- as.data.frame(table(sim_data))
  # Rename columns for clarity
  colnames(top_1000) <- c("value", "propn_midpoint6")
  top_1000[top_1000$value == 0, ]$propn_midpoint6 <- top_1000[top_1000$value == 0, ]$propn_midpoint6 + 1000
  # Convert 'value' from factor to numeric
  top_1000$value <- as.numeric(as.character(top_1000$value))
  # Show first few values
  print(head(top_1000))
} else {
  n_tests_table <- read.csv(glue("output/output/{opt$test}/proxy_null/total_tests_midpoint6_{opt$test}.csv"))
}

# Iteratively generate histograms for each field
fields <- c('numeric_value', 'ref_range')
for (field in fields){

  # If test is hba1c, create a facet plot to compare hba1c_numeric and hba1c normal codelists
  if (opt$test == 'hba1c_numeric'){
    
    # Initialize a list to store dataframes
    df_list <- list()
    tests <- c('hba1c', 'hba1c_numeric')

    # Loop through each test
    for(test in tests){
      top_1000 <- read.csv(glue('output/output/{opt$test}/proxy_null/top_1000_numeric_values_{opt$test}.csv'))
      n_tests_table <- read.csv(glue("output/output/{opt$test}/proxy_null/total_tests_midpoint6_{opt$test}.csv"))

      # Round floats to nearest integer (i.e. binning)
      top_1000$value <- round(top_1000$value)
      n_tests <- n_tests_table[n_tests_table$field == field, 'total_tests_midpoint6']

      # Aggregate to get propns per integer
      aggregated_top_1000 <- top_1000 %>%
        group_by(value) %>%
        summarise(total_propn_midpoint6_derived = sum(propn_midpoint6), .groups = "drop")

      # Add test name for tracking
      aggregated_top_1000$test <- test

      # Store in list
      df_list[[test]] <- aggregated_top_1000
    }

    # Combine all test dataframes vertically
    combined_df <- bind_rows(df_list)

    # Generate faceted histogram
    p <- ggplot(combined_df, aes(x = value, y = total_propn_midpoint6_derived)) +
      geom_bar(stat = "identity", 
              fill = "lightblue", 
              color = "black", 
              alpha = 0.7) +
      scale_x_continuous(limits = c(min(combined_df$value) - 2, max(combined_df$value) + 2)) +
      scale_y_continuous(labels = label_comma()) +  # disables scientific notation
      labs(title = "Histogram of 1000 Most Common {field_formatted}s, n = {n_tests}", 
          x = field_formatted, 
          y = "Proportion") +
      facet_wrap(~ test, scales = "fixed") 

    ggsave(glue("output/output/{opt$test}/proxy_null/numeric_values_{opt$test}.png"), plot = p, width = 10, height = 5)

  } else{ # For non-hba1c tests, create a simple histogram

    # Initialize a list to store dataframes
    top_1000_list <- list()
    aggregated_top_1000_list <- list()
    fields <- c('numeric_value', 'upper_bound', 'lower_bound')

    # Loop through each test
    for(field in fields){
    
      top_1000_list[[field]] <- read.csv(glue('output/output/{opt$test}/proxy_null/top_1000_{field}_{opt$test}.csv'))
      n_tests_table <- read.csv(glue("output/output/{opt$test}/proxy_null/total_tests_midpoint6_{opt$test}.csv"))

      # Round floats to nearest integer (i.e. binning)
      top_1000_list[[field]]$value <- round(top_1000_list[[field]]$value)
      n_tests <- n_tests_table[n_tests_table$field == field, 'total_tests_midpoint6']

      # Aggregate to get propns per integer
      aggregated_top_1000_list[[field]] <- top_1000_list[[field]] %>%
        group_by(value) %>%
        summarise(total_propn_midpoint6_derived = sum(propn_midpoint6), .groups = "drop")

      # Add test name for tracking
      aggregated_top_1000_list[[field]]$field <- field

    }

    # Generate test value histogram
    p_numeric_value <- ggplot(aggregated_top_1000_list[['numeric_value']], aes(x = value, y = total_propn_midpoint6_derived)) +
      geom_bar(stat = "identity", 
              fill = "lightblue", 
              color = "black", 
              alpha = 0.7) +
      scale_x_continuous(limits = c(min(aggregated_top_1000_list[['numeric_value']]$value) - 2, max(aggregated_top_1000_list[['numeric_value']]$value) + 2)) +
      scale_y_continuous(labels = label_comma()) + # this line disables scientific notation
      labs(title = glue("Histogram of 1000 Most Common Test Values for {opt$test}, n = {n_tests}"), 
          x = "Test Value", 
          y = "Proportion")

    # Generate ref range histogram
    aggregated_top_1000_ref <- rbind(aggregated_top_1000_list$lower_bound, aggregated_top_1000_list$upper_bound)

    p_ref_range <- ggplot(aggregated_top_1000_ref, aes(x = value, y = total_propn_midpoint6_derived, fill = field)) +
      geom_bar(stat = "identity", 
              alpha = 0.7) +
      #facet_wrap(~ field) +
      scale_x_continuous(limits = c(min(aggregated_top_1000_ref$value) - 2, max(aggregated_top_1000_ref$value) + 2)) +
      scale_y_continuous(labels = label_comma()) + # this line disables scientific notation
      labs(title = glue("Histogram of 1000 Most Common Reference Range values for {opt$test}, n = {n_tests}"), 
          x = "Value", 
          y = "Proportion")

    ggsave(glue("output/output/{opt$test}/proxy_null/numeric_value_{opt$test}.png"), plot = p_numeric_value)
    ggsave(glue("output/output/{opt$test}/proxy_null/ref_range_value_{opt$test}.png"), plot = p_ref_range, width = 12, height = 8, dpi = 300)
  }
}

 