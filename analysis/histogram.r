library(ggplot2)
measures <- read.csv('output/numeric_value_dataset.csv')

p <- ggplot(measures, aes(x = numeric_value)) +
  geom_histogram(binwidth = 1, 
                 fill = "lightblue", 
                 color = "black", 
                 alpha = 0.7) +  
  labs(title = "Histogram of numeric values for alt", 
       x = "Values", 
       y = "Count")
ggsave("output/alt_numeric_values.png", plot=p)
 
