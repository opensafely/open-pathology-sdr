library(ggplot2)
library(dplyr)
library(glue)
source("analysis/proxy_null_analysis/config.r") # Provides opt$codelist and test variables

# A function to apply midpoint rounding as per OS documentation on disclosure control
roundmid_any <- function(x, to=6){
  ceiling(x/to)*to - (floor(to/2)*(x!=0))
}

measures <- read.csv(glue('output/{test}/proxy_null/numeric_value_dataset_{test}.csv'))

#--------- Create frequency table -------------------------------------------------

freq_table <- as.data.frame(table(measures$numeric_value))
# Rename columns for clarity
colnames(freq_table) <- c("numeric_value", "count")
# Convert numeric_value back to numeric (since table makes it a factor)
freq_table$numeric_value <- as.numeric(as.character(freq_table$numeric_value))
colnames(freq_table) <- c("value", "count")  # Rename columns for clarity
# Sort and extract top 1000
top_1000 <- freq_table %>%
  arrange(desc(count)) %>%
  slice_head(n = 1000)
# Apply midpoint 6 rounding
top_1000$count <- roundmid_any(top_1000$count)
top_1000 <- rename(top_1000, count_midpoint6 = count)

write.csv(top_1000, glue("output/{test}/proxy_null/top_1000_numeric_values_{test}.csv"), row.names = FALSE)

