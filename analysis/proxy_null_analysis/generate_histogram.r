library(ggplot2)
library(dplyr)
library(scales)
library(glue)
source("analysis/proxy_null_analysis/config.r") # Provides opt$codelist and test variables

top_1000 <- read.csv(glue('output/{test}/proxy_null/top_1000_numeric_values_{test}.csv'))

# Round floats to nearest integer (i.e. binning)
top_1000$value <- round(top_1000$value)
# Aggregate to get counts per integer
aggregated_top_1000 <- top_1000 %>%
  group_by(value) %>%
  summarise(total_count_midpoint6_derived = sum(count_midpoint6), .groups = "drop")

# Generate histogram
p <- ggplot(top_1000, aes(x = value, y = count_midpoint6)) +
  geom_bar(stat = "identity", 
           fill = "lightblue", 
           color = "black", 
           alpha = 0.7) +
  scale_x_continuous(limits = c(-10, 1000)) +
  scale_y_continuous(labels = label_comma()) + # this line disables scientific notation
  labs(title = glue("Histogram of top 1000 numeric values for {test}"), 
       x = "numeric_value", 
       y = "Count")

# Generate zoomed-in histogram
pp <- ggplot(top_1000, aes(x = value, y = count_midpoint6)) +
  geom_bar(stat = "identity", 
           fill = "lightblue", 
           color = "black", 
           alpha = 0.7) +
  scale_x_continuous(limits = c(-10, 100)) +
  scale_y_continuous(labels = label_comma()) + 
  labs(title = glue("Histogram of top 1000 numeric values for {test}, zoomed"), 
       x = "numeric_value", 
       y = "Count")

ggsave(glue("output/{test}/proxy_null/numeric_values_{test}.png"), plot = p)
ggsave(glue("output/{test}/proxy_null/numeric_values_zoomed_{test}.png"), plot = pp)
 