library(ggplot2)
library(dplyr)
library(scales)
library(glue)
source("analysis/proxy_null_analysis/config.r") # Provides opt$codelist and test variables

fields <- c("numeric_value", "lower_bound", "upper_bound")
for (field in fields){

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
    colnames(top_1000) <- c("value", "count_mp6")
    top_1000[top_1000$value == 0, ]$count_mp6 <- top_1000[top_1000$value == 0, ]$count_mp6 + 1000
    # Convert 'value' from factor to numeric
    top_1000$value <- as.numeric(as.character(top_1000$value))
    # Show first few values
    print(head(top_1000))
  } else {
    top_1000 <- read.csv(glue('output/{test}/proxy_null/top_1000_{field}_{test}.csv'))
  }

  # Round floats to nearest integer (i.e. binning)
  top_1000$value <- round(top_1000$value)
  # Aggregate to get propn per integer
  aggregated_top_1000 <- top_1000 %>%
    group_by(value) %>%
    summarise(total_propn_mp6 = sum(propn_mp6), .groups = "drop")

  # Generate histogram
  p <- ggplot(aggregated_top_1000, aes(x = value, y = total_propn_mp6)) +
    geom_bar(stat = "identity", 
            fill = "lightblue", 
            color = "black", 
            alpha = 0.7) +
    scale_x_continuous(limits = c(min(aggregated_top_1000$value) - 2, max(aggregated_top_1000$value) + 2)) +
    scale_y_continuous(labels = label_comma()) + # this line disables scientific notation
    labs(title = glue("Histogram of top 1000 {field} values for {test}"), 
        x = field, 
        y = "Propn")

  ggsave(glue("output/{test}/proxy_null/{field}_{test}.png"), plot = p)
}