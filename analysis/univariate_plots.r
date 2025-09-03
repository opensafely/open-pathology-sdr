#install.packages('sf')
library(sf)
library(dplyr)
library(tidyr)
library(ggplot2)

df <- read.csv("output/output/OP SDR results table - Sheet5.csv")

# Load shapefile (UK regions)
uk_regions <- st_read("output/output/NUTS_Level_1_January_2018_GCB_in_the_United_Kingdom_2022_-2753267915301604886.geojson")
uk_regions$nuts118nm <- gsub(" \\(England\\)", "", uk_regions$nuts118nm)
uk_regions$nuts118nm <- gsub(" of England", "", uk_regions$nuts118nm)

# Pivot data
df_long <- df %>%
  filter(Field.name == "Equality Comparator") %>%  # filter rows
  select(-Field.name) %>%                  # drop the column
  pivot_longer(
    -Region, 
    names_to = "Test", 
    values_to = "Value"
  )

# Merge
merged <- uk_regions %>%
  left_join(df_long, by = c("nuts118nm" = "Region"))

merged <- merged %>% filter(!is.na(Test))

# Facet plot
p <- ggplot(merged) +
  geom_sf(aes(fill = Value), color = "white") +
  scale_fill_gradient(
    low = "white",   # low values = white
    high = "red",     # high values = red
    name = "Non-null Equality Comparator %"
  ) +
  facet_wrap(~Test) +
  theme(
    axis.text.x = element_blank(),  # removes x-axis tick labels
    axis.text.y = element_blank(),  # removes y-axis tick labels
    axis.ticks = element_blank()    # removes tick marks themselves
  )


ggsave("output/output/regions_plot.png", plot = p, width = 12, height = 8, dpi = 300)

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
  )

# Save plot
ggsave("output/output/time_facet_plot.png", plot = p, width = 12, height = 8, dpi = 300)