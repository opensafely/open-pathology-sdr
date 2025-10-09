# USAGE: Rscript analysis/plots.r --format [lines_region OR lines_test]
# RELEASED RESULTS SHOULD BE IN "OUTPUT/OUTPUT/[test]"
# GENERATES RESULTS PLOTS, DEPENDS ON format_results.py

library(tidyverse)
library(optparse)
library(glue)
library(stringr)

# Parse the arguments
option_list <- list(make_option(c("--format"), type = "character"))
opt <- parse_args(OptionParser(option_list = option_list))

# Load the data for all tests
tests <- c('alt', 'chol', 'hba1c_numeric', 'rbc', 'sodium')

# Read each CSV into a list of dataframes, adding a column to identify the test
df_list <- lapply(tests, function(test) {
  read_csv(glue("output/output/{test}/results_table_{test}.csv")) %>%
    mutate(test_name = test)  # optional: add test name as a column
})

# Concatenate all dataframes into one
df_combined <- bind_rows(df_list)

# Choose plot format
if (opt$format == 'lines_region'){
  color_col = 'region'
  facet_col = 'test_name'

} else if (opt$format == 'lines_test'){
  color_col = 'test_name'
  facet_col = 'region'
}

# Change strings to be more readable
col_map <- c("rate_test_value" = "Test Value", "rate_lower_bound" = "Lower Bound", "rate_upper_bound" = "Upper Bound", 
            'rate_equality_comparator' = 'Equality Comparator', 'rate_differential_comparator' = 'Differential Comparator')
# Replace column names the mapping
df_combined <- df_combined %>%
  rename_with(~ ifelse(. %in% names(col_map), col_map[.], .))
value_map <- c("alt" = "ALT", "chol" = "Cholesterol", "hba1c_numeric" = "HbA1c", "rbc" = "RBC", "sodium" = "Sodium")
df_combined$test_name <- value_map[df_combined$test_name]

# Step 1: Reshape ALL test-specific columns into long format
df_long <- pivot_longer(
  data = df_combined,
  cols = c(
    "Test Value", "Lower Bound", "Upper Bound", "Equality Comparator", "Differential Comparator",
    "numerator_has_differential_comparator", "numerator_has_equality_comparator",
    "numerator_has_lower_bound", "numerator_has_upper_bound",
    "numerator_has_test_value",
    "denominator_test_value", "denominator_bounds", "denominator_comparators"
  ),
  names_to = "field_name",
  values_to = "value"
)

# Optional: View final result
print(df_long)
write.csv(df_long, "output/output/df_combined.csv")

# Iteratively generate plots for each measure
measures <- c('Test Value', 'Lower Bound', 'Upper Bound', 'Equality Comparator', 'Differential Comparator')
df_plot <- df_combined

for (measure in measures){ 

  p <- ggplot(df_plot, aes(x = interval_start, y = .data[[measure]], color = .data[[color_col]])) +
    geom_line(alpha = 0.6, linetype = 'dashed') +
    facet_wrap(~ .data[[facet_col]], nrow = 3) +
    scale_y_continuous(limits = c(0, 100)) +
    # scale_color_manual(
    #   values = c(
    #   "Upper/lower Bound" = "red",
    #   "Equality Comparator" = "blue",
    #   "Differential Comparator" = "black",
    #   "Test Value" = "green")) +
    labs(
      title = glue("% of Tests with Non-Null {measure}"),
      y = "% of Tests",
      color = "Region",
    ) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = c(1, 0),         # Position of legend
      legend.justification = c(1, 0),          # Part of legend that the position applies to
      legend.background = element_rect(fill = alpha("white", 0.8), color = "grey80"),
      legend.box.background = element_rect(color = "grey50"),
      legend.title = element_text(face = "bold"),
      axis.title.x = element_blank(),
      text = element_text(size = 15)
    ) +
    guides(color = guide_legend(nrow = 3))

  ggsave(glue("output/output/{measure}_plot_{opt$format}.png"), plot = p, width = 12, height = 8, dpi = 300)
}
