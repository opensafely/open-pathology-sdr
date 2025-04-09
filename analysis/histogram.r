library(ggplot2)
library(dplyr)

measures <- read.csv('output/numeric_value_dataset.csv')

p <- ggplot(measures, aes(x = numeric_value)) +
  geom_histogram(binwidth = 1, 
                 fill = "lightblue", 
                 color = "black", 
                 alpha = 0.7) +  
  scale_x_continuous(limits = c(0, 1000)) +  # Limit x-axis to 0–1000
  labs(title = "Histogram of numeric values for alt", 
       x = "Values", 
       y = "Count")

pp <- ggplot(measures, aes(x = numeric_value)) +
  geom_histogram(binwidth = 1, 
                 fill = "lightblue", 
                 color = "black", 
                 alpha = 0.7) +  
  scale_x_continuous(limits = c(0, 100)) +  # Limit x-axis to 0–1000
  labs(title = "Histogram of numeric values for alt", 
       x = "Values", 
       y = "Count")

# Create a frequency table
freq_table <- as.data.frame(table(measures$numeric_value))
# Rename columns for clarity
colnames(freq_table) <- c("numeric_value", "count")
# Convert numeric_value back to numeric (since table makes it a factor)
freq_table$numeric_value <- as.numeric(as.character(freq_table$numeric_value))
# Create the frequency table and convert to tibble with proper names
freq_table <- as.data.frame(table(measures$numeric_value))
colnames(freq_table) <- c("value", "count")  # Rename columns for clarity
# Sort and extract top 1000
top_1000 <- freq_table %>%
  arrange(desc(count)) %>%
  slice_head(n = 1000)
# Save to CSV
write.csv(top_1000, "output/top_1000_numeric_values.csv", row.names = FALSE)

ggsave("output/alt_numeric_values.png", plot = p)
ggsave("output/alt_numeric_values_zoomed.png", plot = pp)
 
