# USAGE: r analysis/univariate_plots.r

# install.packages('sf')
# library(sf)
library(dplyr)
library(tidyr)
library(ggplot2)

# df <- read.csv("output/output/OP SDR results table - Sheet5.csv")

# # Load shapefile
# uk_regions <- st_read("output/output/NUTS_Level_1_January_2018_GCB_in_the_United_Kingdom_2022_-2753267915301604886.geojson")
# uk_regions$nuts118nm <- gsub(" \\(England\\)", "", uk_regions$nuts118nm)
# uk_regions$nuts118nm <- gsub(" of England", "", uk_regions$nuts118nm)

# # Pivot data (keep Field.name!)
# df_long <- df %>%
#   pivot_longer(
#     cols = -(c(Field.name, Region)), 
#     names_to = "Test", 
#     values_to = "Value"
#   )

# # Merge shapefile and data
# merged <- uk_regions %>%
#   left_join(df_long, by = c("nuts118nm" = "Region")) %>%
#   filter(!is.na(Test), !is.na(Field.name))

# # Reorder field names
# merged$Field.name <- factor(
#   merged$Field.name,
#   levels = c("Test Value", "Upper Bound", "Lower Bound", "Equality Comparator", "Differential Comparator")
# )

# # Facet by BOTH Test and Field.name
# p <- ggplot(merged) +
#   geom_sf(aes(fill = Value), color = "white") +
#   scale_fill_gradient(
#     low = "white",
#     high = "red",
#     name = "Non-null %"
#   ) +
#   facet_grid(Field.name ~ Test, switch = 'y') +
#   theme(
#     axis.text.x = element_blank(),
#     axis.text.y = element_blank(),
#     axis.ticks = element_blank(),
#     text = element_text(size = 15))

# ggsave("output/output/regions_plot_grid.png", plot = p, width = 10, height = 10, dpi = 300)

# ------------- Time plot ----------------------------

df <- read.csv("output/output/OP SDR results table - Interval csv.csv")

# Pivot longer so each test is in its own row
df_long <- df %>%
  pivot_longer(
    cols = ALT:Sodium,   # adjust if more columns exist
    names_to = "Test",
    values_to = "Value"
  ) %>%
  mutate(Interval = as.Date(Interval))   # ensure date type
print(df_long)
# Facet plot over time
p <- ggplot(df_long, aes(x = Interval, y = Value, color = Test)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  facet_wrap(~Field.name) +
  scale_y_continuous(limits = c(0, 100)) +  # sets y-axis 0-100 for all facets
  labs(
    x = NULL,
    y = "Non-null %",
    color = NULL
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1), # angled dates for readability
    text = element_text(size = 15)
  )

# Save plot
ggsave("output/output/time_facet_plot.png", plot = p, width = 12, height = 8, dpi = 300)