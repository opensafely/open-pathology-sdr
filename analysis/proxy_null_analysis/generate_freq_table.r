library(ggplot2)
library(dplyr)

# A function to apply midpoint rounding as per OS documentation on disclosure control
roundmid_any <- function(x, to=6){
  ceiling(x/to)*to - (floor(to/2)*(x!=0))
}

measures <- read.csv('output/numeric_value_dataset.csv')

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
# Replace values between 1 and 7 with "[REDACT]"
top_1000$count[top_1000$count >= 1 & top_1000$count <= 7] <- "[REDACT]"
top_1000 <- rename(top_1000, count_midpoint6 = count)

write.csv(top_1000, "output/top_1000_numeric_values.csv", row.names = FALSE)

