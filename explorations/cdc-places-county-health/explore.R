# Explore CDC PLACES county health measures.

library(dplyr)
library(ggplot2)
library(readr)
library(stringr)

source_url <- "https://www.cdc.gov/places/"
places_resource_url <- "https://data.cdc.gov/resource/d3i6-k6z5.csv"

script_file <- sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE))
script_dir <- if (length(script_file) == 1) dirname(normalizePath(script_file)) else getwd()
output_dir <- file.path(script_dir, "outputs")
raw_dir <- file.path(output_dir, "raw")
dir.create(raw_dir, showWarnings = FALSE, recursive = TRUE)

selected_fields <- paste(
  c(
    "stateabbr",
    "statedesc",
    "countyname",
    "countyfips",
    "totalpopulation",
    "totalpop18plus",
    "obesity_crudeprev",
    "diabetes_crudeprev",
    "csmoking_crudeprev",
    "lpa_crudeprev",
    "mhlth_crudeprev",
    "foodinsecu_crudeprev"
  ),
  collapse = ","
)

query_url <- paste0(
  places_resource_url,
  "?$select=",
  selected_fields,
  "&$limit=5000"
)

places_raw <- read_csv(query_url, show_col_types = FALSE)
write_csv(places_raw, file.path(raw_dir, "cdc_places_county_selected_raw.csv"))

places <- places_raw |>
  transmute(
    state_abbr = stateabbr,
    state = statedesc,
    county = countyname,
    geoid = str_pad(as.character(countyfips), 5, pad = "0"),
    county_label = paste0(countyname, ", ", stateabbr),
    total_population = totalpopulation,
    adult_population = totalpop18plus,
    obesity = obesity_crudeprev,
    diabetes = diabetes_crudeprev,
    current_smoking = csmoking_crudeprev,
    physical_inactivity = lpa_crudeprev,
    poor_mental_health = mhlth_crudeprev,
    food_insecurity = foodinsecu_crudeprev
  ) |>
  arrange(desc(obesity))

# Basic inspection ------------------------------------------------------------

glimpse(places)

places |>
  summarise(
    rows = n(),
    counties = n_distinct(geoid),
    states = n_distinct(state_abbr),
    missing_obesity = sum(is.na(obesity)),
    missing_diabetes = sum(is.na(diabetes)),
    missing_physical_inactivity = sum(is.na(physical_inactivity))
  )

places |>
  summarise(across(
    c(obesity, diabetes, current_smoking, physical_inactivity, poor_mental_health, food_insecurity),
    list(min = ~ min(.x, na.rm = TRUE), median = ~ median(.x, na.rm = TRUE), max = ~ max(.x, na.rm = TRUE))
  ))

# Candidate summaries --------------------------------------------------------

top_obesity_counties <- places |>
  filter(!is.na(obesity), adult_population >= 10000) |>
  slice_max(obesity, n = 15)

top_obesity_counties |>
  select(county_label, adult_population, obesity, diabetes, physical_inactivity, food_insecurity)

pattern_counties <- places |>
  filter(!is.na(obesity), !is.na(diabetes), adult_population >= 10000) |>
  mutate(
    obesity_rank = min_rank(desc(obesity)),
    diabetes_rank = min_rank(desc(diabetes)),
    rank_gap = diabetes_rank - obesity_rank
  ) |>
  arrange(desc(rank_gap))

pattern_counties |>
  select(county_label, adult_population, obesity, diabetes, obesity_rank, diabetes_rank, rank_gap) |>
  head(10)

# Candidate plots -------------------------------------------------------------

obesity_rank_plot <- top_obesity_counties |>
  ggplot(aes(x = reorder(county_label, obesity), y = obesity)) +
  geom_col(fill = "#397367") +
  coord_flip() +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  labs(
    title = "Counties with the Highest Estimated Adult Obesity Prevalence",
    subtitle = "CDC PLACES county estimates among counties with at least 10,000 adults",
    x = NULL,
    y = "Estimated adult obesity prevalence",
    caption = "Source: CDC PLACES, County Data GIS-Friendly Format"
  ) +
  theme_minimal()

ggsave(
  file.path(output_dir, "top-county-obesity-places.png"),
  obesity_rank_plot,
  width = 9,
  height = 6,
  dpi = 300,
  bg = "white"
)

obesity_diabetes_plot <- places |>
  filter(!is.na(obesity), !is.na(diabetes), adult_population >= 10000) |>
  ggplot(aes(x = obesity, y = diabetes)) +
  geom_point(aes(size = adult_population), alpha = 0.35, color = "#397367") +
  geom_smooth(method = "lm", se = FALSE, color = "#c17c74", linewidth = 0.8) +
  scale_x_continuous(labels = scales::percent_format(scale = 1)) +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  scale_size_continuous(labels = scales::comma, guide = "none") +
  labs(
    title = "Obesity and Diabetes Estimates Usually Move Together",
    subtitle = "But counties can still sit above or below the overall pattern",
    x = "Estimated adult obesity prevalence",
    y = "Estimated diagnosed diabetes prevalence",
    caption = "Source: CDC PLACES, County Data GIS-Friendly Format"
  ) +
  theme_minimal()

ggsave(
  file.path(output_dir, "obesity-vs-diabetes-places.png"),
  obesity_diabetes_plot,
  width = 8,
  height = 6,
  dpi = 300,
  bg = "white"
)

# Promotion prep -------------------------------------------------------------

write_csv(places, file.path(output_dir, "cdc_places_county_health_selected.csv"))
saveRDS(places, file.path(output_dir, "cdc_places_county_health_selected.rds"))
write_csv(top_obesity_counties, file.path(output_dir, "top_county_obesity_places.csv"))
write_csv(pattern_counties, file.path(output_dir, "obesity_diabetes_rank_gaps.csv"))
