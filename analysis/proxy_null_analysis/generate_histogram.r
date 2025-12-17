# USAGE: Rscript analysis/proxy_null_analysis/generate_histogram.r
# Options
# --test [alt OR hba1c OR chol etc]

library(ggplot2)
library(dplyr)
library(scales)
library(glue)

source("analysis/proxy_null_analysis/config.r") # opt$test and codelist variables

pseudonyms <- c(
  "numeric_value" = "Test Value",
  "upper_bound"   = "Upper Bound",
  "lower_bound"   = "Lower Bound"
)

# Helper: load, transform, and summarise data
process_field <- function(test, field) {
  top_1000 <- read.csv(glue("output/output/{test}/proxy_null/top_1000_{field}_{test}.csv"))
  total_tests <- read.csv(glue("output/output/{test}/proxy_null/total_tests_mp6_{test}.csv"))
  # Read summary with first column as row names so we can index by statistic name
  summary_stats <- read.csv(glue("output/output/{test}/proxy_null/value_summary_{test}.csv"), row.names = 1)

  # Extract number of non-null tests for field (ensure numeric)
  n_tests <- as.numeric(summary_stats["count", 'numeric_value'])
  top_1000$propn_mp6 <- (top_1000$count_mp6 / n_tests) * 100
  top_1000$value <- round(top_1000$value)

  if (test == "hba1c_numeric") {
    aggregated <- top_1000 %>%
          group_by(value) %>%
          summarise(total_propn_mp6_derived = sum(propn_mp6), .groups = "drop") %>%
          mutate(
            test = glue("{test}, n = {n_tests}"),
            field = field,
            field_formatted = ifelse(
              field %in% names(pseudonyms),
                pseudonyms[field],
                gsub("_", " ", field)
              ),
            n_tests = n_tests
          )
  } else{
    aggregated <- top_1000 %>%
      group_by(value) %>%
      summarise(total_propn_mp6_derived = sum(propn_mp6), .groups = "drop") %>%
      mutate(
        test = test,
        field = field,
        field_formatted = ifelse(
          field %in% names(pseudonyms),
          glue("{pseudonyms[field]}, n = {n_tests}"),
          gsub("_", " ", field)
        ),
        n_tests = n_tests
      )
  }
  aggregated
}

# Choose fields & tests
if (opt$test == "hba1c_numeric") {
  fields <- c("numeric_value", "upper_bound", "lower_bound")
  tests  <- c("hba1c", "hba1c_numeric")
} else {
  fields <- c("numeric_value", "upper_bound", "lower_bound")
  tests  <- opt$test
}

# Build combined dataframe
df_list <- list()
for (test in tests) {
  for (field in fields) {
    df_list[[paste(test, field, sep = "_")]] <- process_field(test, field)
  }
}
combined_df <- bind_rows(df_list)
print(combined_df)

# Set facet order: "Test Value" first
if (opt$test == "hba1c_numeric") {
  combined_df$field_formatted <- factor(
    combined_df$field_formatted,
    levels = unique(c(
      "Test Value",
      "Upper Bound",
      "Lower Bound"
    ))
  )
} else {
  # using grep "^" to search for labels beginning with the field name
  # Use `value = TRUE` so `grep` returns the matching label strings rather than their indices
  combined_df$field_formatted <- factor(
    combined_df$field_formatted,
    levels = unique(c(
      grep("^Test Value", combined_df$field_formatted, value = TRUE),
      grep("^Upper Bound", combined_df$field_formatted, value = TRUE),
      grep("^Lower Bound", combined_df$field_formatted, value = TRUE)
    ))
  )
}

combined_df <- combined_df %>%
  mutate(test = recode(test,
    "hba1c" = "HbA1c Full",
    "hba1c_numeric" = "HbA1c Simplified"
  ))
print(combined_df)
# Plot
p <- ggplot(combined_df, aes(x = value, y = total_propn_mp6_derived)) +
  geom_bar(stat = "identity", fill = "lightblue", color = "black", alpha = 0.7) +
  scale_y_continuous(labels = label_comma()) +
  theme(text = element_text(size = 15)) +
  labs(
    x = "Test Result",
    y = "Proportion"
  ) +
  {
    if (opt$test == "hba1c_numeric") {
      facet_grid(field_formatted ~ test, scales = "free")
    } else {
      facet_wrap(~ field_formatted, scales = "free", ncol = 1)
    }
  }

# Save
ggsave(
  glue("output/output/{opt$test}/proxy_null/all_values_{opt$test}.png"),
  plot = p,
  width = if (opt$test == "hba1c_numeric") 12 else 10,
  height = 8,
  dpi = 300
)
