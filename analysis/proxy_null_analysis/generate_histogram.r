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
pseudonyms <- c(
"numeric_value" = "Test Value",
"upper_bound" = "Upper Bound",
"lower_bound" = "Lower Bound"
)

# If test is hba1c, create a facet plot to compare hba1c_numeric and hba1c normal codelists
if (opt$test == 'hba1c_numeric') {

  fields <- c('numeric_value', 'upper_bound', 'lower_bound')
  tests <- c('hba1c', 'hba1c_numeric')
  df_list <- list()

  for (test in tests) {

    for (field in fields) {

      top_1000 <- read.csv(glue('output/output/{test}/proxy_null/top_1000_{field}_{test}.csv'))
      n_tests_table <- read.csv(glue("output/output/{test}/proxy_null/total_tests_midpoint6_{test}.csv"))

      top_1000$value <- round(top_1000$value)
      n_tests <- n_tests_table[n_tests_table$field == field, 'total_tests_midpoint6']

      aggregated <- top_1000 %>%
        group_by(value) %>%
        summarise(total_propn_midpoint6_derived = sum(propn_midpoint6), .groups = "drop") %>%
        mutate(
          test = test,
          field = field,
          field_formatted = ifelse(
          field %in% names(pseudonyms),
          glue("{pseudonyms[field]}"),
          glue("{gsub('_', ' ', field)}")
          )
        )

      df_list[[paste(test, field, sep = "_")]] <- aggregated
    }
  }

  combined_df <- bind_rows(df_list)

  p <- ggplot(combined_df, aes(x = value, y = total_propn_midpoint6_derived)) +
    geom_bar(stat = "identity", fill = "lightblue", color = "black", alpha = 0.7) +
    scale_y_continuous(labels = label_comma()) +
    labs(title = "Histogram of 1000 Most Common Values", x = "Value", y = "Proportion") +
    facet_grid(field_formatted ~ test, scales = "free")

  ggsave(glue("output/output/{opt$test}/proxy_null/all_values_{opt$test}.png"),
        plot = p, width = 12, height = 8, dpi = 300)

} else {

  fields <- c('numeric_value', 'upper_bound', 'lower_bound')
  df_list <- list()

  for (field in fields) {

    top_1000 <- read.csv(glue('output/output/{opt$test}/proxy_null/top_1000_{field}_{opt$test}.csv'))
    n_tests_table <- read.csv(glue("output/output/{opt$test}/proxy_null/total_tests_midpoint6_{opt$test}.csv"))

    top_1000$value <- round(top_1000$value)
    n_tests <- n_tests_table[n_tests_table$field == field, 'total_tests_midpoint6']

  aggregated <- top_1000 %>%
    group_by(value) %>%
    summarise(total_propn_midpoint6_derived = sum(propn_midpoint6), .groups = "drop") %>%
    mutate(
      # Replace field with pseudonym if available, otherwise keep original
      field_formatted = ifelse(
        field %in% names(pseudonyms),
        glue("{pseudonyms[field]}"),
        glue("{gsub('_', ' ', field)}")
      )
    )
    df_list[[field]] <- aggregated
  }

  combined_df <- bind_rows(df_list)

  p <- ggplot(combined_df, aes(x = value, y = total_propn_midpoint6_derived)) +
    geom_bar(stat = "identity", fill = "lightblue", color = "black", alpha = 0.7) +
    scale_y_continuous(labels = label_comma()) +
    labs(title = glue("Histogram of 1000 Most Common Values for {opt$test}"),
          x = "Value", y = "Proportion") +
    facet_wrap(~ field_formatted, scales = "free", ncol = 1)

  ggsave(glue("output/output/{opt$test}/proxy_null/all_values_{opt$test}.png"),
          plot = p, width = 10, height = 8, dpi = 300)
  }


 