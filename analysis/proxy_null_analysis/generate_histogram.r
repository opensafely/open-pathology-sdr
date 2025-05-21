library(ggplot2)
library(dplyr)
library(scales)
library(glue)
source("analysis/proxy_null_analysis/config.r") # Provides opt$codelist and test variables

if (opt$test_run){
  # Set seed for reproducibility
  set.seed(123)
  # Parameters
  mu <- 13         # Mean (expected count)
  theta <- 3       # Dispersion parameter: smaller = more overdispersed
  n <- 50000         # Sample size
  sim_data <- rnbinom(n, size = theta, mu = mu)
  # Tabulate and convert to data frame
  top_1000 <- as.data.frame(table(sim_data))
  # Rename columns for clarity
  colnames(top_1000) <- c("value", "count_midpoint6")
  top_1000[top_1000$value == 0, ]$count_midpoint6 <- top_1000[top_1000$value == 0, ]$count_midpoint6 + 1000
  # Convert 'value' from factor to numeric
  top_1000$value <- as.numeric(as.character(top_1000$value))
  # Show first few values
  print(head(top_1000))
} else {
  top_1000 <- read.csv(glue('output/{test}/proxy_null/top_1000_numeric_values_{test}.csv'))
}

# Round floats to nearest integer (i.e. binning)
top_1000$value <- round(top_1000$value)
reconstructed <- rep(as.numeric(as.character(top_1000$value)), top_1000$count_midpoint6)
upper_quartile <- as.numeric(quantile(reconstructed, probs = 0.95))

# Aggregate to get counts per integer
aggregated_top_1000 <- top_1000 %>%
  group_by(value) %>%
  summarise(total_count_midpoint6_derived = sum(count_midpoint6), .groups = "drop")

# Generate histogram
p <- ggplot(aggregated_top_1000, aes(x = value, y = total_count_midpoint6_derived)) +
  geom_bar(stat = "identity", 
           fill = "lightblue", 
           color = "black", 
           alpha = 0.7) +
  scale_x_continuous(limits = c(min(aggregated_top_1000$value) - 2, max(aggregated_top_1000$value) + 2)) +
  scale_y_continuous(labels = label_comma()) + # this line disables scientific notation
  labs(title = glue("Histogram of top 1000 numeric values for {test}"), 
       x = "numeric_value", 
       y = "Count")

# Generate zoomed-in histogram
pp <- ggplot(aggregated_top_1000, aes(x = value, y = total_count_midpoint6_derived)) +
  geom_bar(stat = "identity", 
           fill = "lightblue", 
           color = "black", 
           alpha = 0.7) +
  scale_x_continuous(limits = c(min(aggregated_top_1000$value) - 2, upper_quartile)) +
  scale_y_continuous(labels = label_comma()) + 
  labs(title = glue("Histogram of top 1000 numeric values for {test}, zoomed"), 
       x = "numeric_value", 
       y = "Count")

ggsave(glue("output/{test}/proxy_null/numeric_values_{test}.png"), plot = p)
ggsave(glue("output/{test}/proxy_null/numeric_values_zoomed_{test}.png"), plot = pp)
 