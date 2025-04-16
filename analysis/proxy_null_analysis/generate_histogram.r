library(ggplot2)
library(dplyr)

top_1000 <- read.csv('output/top_1000_numeric_values.csv')

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
  labs(title = "Bar Chart of numeric values for alt", 
       x = "numeric_value", 
       y = "Count")

# Generate zoomed-in histogram
pp <- ggplot(top_1000, aes(x = value, y = count_midpoint6)) +
  geom_bar(stat = "identity", 
           fill = "lightblue", 
           color = "black", 
           alpha = 0.7) +
  scale_x_continuous(limits = c(-10, 100)) +
  labs(title = "Bar Chart of numeric values for alt, zoomed", 
       x = "numeric_value", 
       y = "Count")

ggsave("output/alt_numeric_values.png", plot = p)
ggsave("output/alt_numeric_values_zoomed.png", plot = pp)
 