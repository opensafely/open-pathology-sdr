# USAGE: Rscript analysis/plots.r --path_test [alt or chol or hba1c or hba1c_numeric or rbc or sodium]
# RELEASED RESULTS SHOULD BE IN "OUTPUT/OUTPUT/[alt or chol or hba1c or rbc or sodium]"
# GENERATES RESULTS PLOTS, DEPENDS ON format_results.py

library(tidyverse)
library(optparse)
library(glue)

# Parse the arguments
option_list <- list(make_option(c("--path_test"), type = "character"))
opt <- parse_args(OptionParser(option_list = option_list))
# Load the data
df <- read_csv(glue("output/output/{opt$path_test}/results_table_{opt$path_test}.csv"))

df <- df %>% select(-rate_lower_bound)
df <- df %>% rename(rate_bounds = rate_upper_bound)

# Reshape to long format
df_long <- df %>%
  pivot_longer(
    cols = starts_with("rate_"),
    names_to = "rate_type",
    values_to = "rate"
  )

df_long <- df_long %>%
  mutate(rate_type = factor(rate_type,
    levels = c("rate_bounds", "rate_equality_comparator", "rate_test_value", "rate_differential_comparator"),
    labels = c("Upper/lower Bound", "Equality Comparator", "Test Value", "Differential Comparator")
  ))

#df_plot1 <- filter(df_long, rate_type != 'rate_differential_comparator')
df_plot1 <- df_long

p <- ggplot(df_plot1, aes(x = interval_start, y = rate, color = rate_type, linetype = rate_type)) +
  geom_line(alpha = 0.6) +
  facet_wrap(~ region) +
  scale_y_continuous(limits = c(0, 100)) +
  scale_linetype_manual(values = c(
    "Upper/lower Bound" = "dashed",
    "Equality Comparator" = "dashed",
    "Differential Comparator" = "dashed",
    "Test Value" = "dashed"
  )) +
  scale_color_manual(
    values = c(
    "Upper/lower Bound" = "red",
    "Equality Comparator" = "blue",
    "Differential Comparator" = "black",
    "Test Value" = "green")) +
  labs(
    title = "% of Tests with Field by Region Over Time",
    x = "Interval Start",
    y = "% of Tests",
    color = "Field",
    linetype = "Field" 
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom")

# ------ Differential comparator plot ------------------------------------------------

# df_plot2 <- filter(df_long, rate_type == 'rate_differential_comparator')

# p2 <- ggplot(df_plot2, aes(x = interval_start, y = rate)) +
#   geom_line(alpha = 1) +
#   facet_wrap(~ region) +
#   scale_y_continuous(limits = c(0, 100)) +
#   labs(
#     title = "% of Tests with Differential Comparator by Region Over Time",
#     x = "Interval Start",
#     y = "% of Tests"
#   ) +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(glue("output/output/{opt$path_test}/{opt$path_test}_plot.png"), plot = p, width = 12, height = 8, dpi = 300)
#ggsave(glue("output/output/{opt$path_test}/{opt$path_test}_plot_diff.png"), plot = p2, width = 12, height = 8, dpi = 300)

