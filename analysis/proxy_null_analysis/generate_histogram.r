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
  top_1000$propn_midpoint6 <- (top_1000$count_midpoint6 / sum(top_1000$count_midpoint6)) * 100
  top_1000$value <- round(top_1000$value)

  aggregated <- top_1000 %>%
    group_by(value) %>%
    summarise(total_propn_midpoint6_derived = sum(propn_midpoint6), .groups = "drop") %>%
    mutate(
      test = test,
      field = field,
      field_formatted = ifelse(
        field %in% names(pseudonyms),
        pseudonyms[field],
        gsub("_", " ", field)
      )
    )

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

# Set facet order: "Test Value" first
combined_df$field_formatted <- factor(
  combined_df$field_formatted,
  levels = c("Test Value", "Upper Bound", "Lower Bound")
)

# Set test facet order for hba1c_numeric
if (opt$test == "hba1c_numeric") {
  combined_df$test <- factor(combined_df$test, levels = c("hba1c_numeric", "hba1c"))
}

# Plot
p <- ggplot(combined_df, aes(x = value, y = total_propn_midpoint6_derived)) +
  geom_bar(stat = "identity", fill = "lightblue", color = "black", alpha = 0.7) +
  scale_y_continuous(labels = label_comma()) +
  labs(
    title = if (opt$test == "hba1c_numeric") {
      "Histogram of 1000 Most Common Values"
    } else {
      glue("Histogram of 1000 Most Common Values for {opt$test}")
    },
    x = "Value",
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