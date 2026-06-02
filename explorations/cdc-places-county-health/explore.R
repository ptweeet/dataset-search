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

measure_order <- c("Obesity", "Diabetes", "Current smoking", "Physical inactivity")

health_measures_long <- places |>
  filter(adult_population >= 10000) |>
  select(
    geoid,
    county_label,
    adult_population,
    obesity,
    diabetes,
    current_smoking,
    physical_inactivity
  ) |>
  tidyr::pivot_longer(
    cols = c(obesity, diabetes, current_smoking, physical_inactivity),
    names_to = "measure",
    values_to = "prevalence"
  ) |>
  mutate(
    measure = factor(
      measure,
      levels = c("obesity", "diabetes", "current_smoking", "physical_inactivity"),
      labels = measure_order
    )
  )

top_counties_by_measure <- health_measures_long |>
  filter(!is.na(prevalence)) |>
  group_by(measure) |>
  slice_max(prevalence, n = 8, with_ties = FALSE) |>
  arrange(measure, desc(prevalence)) |>
  mutate(
    measure_rank = row_number(),
    county_rank_label = paste0(str_pad(measure_rank, 2, pad = "0"), ". ", county_label)
  ) |>
  ungroup() |>
  mutate(county_rank_label = factor(county_rank_label, levels = rev(unique(county_rank_label))))

top_obesity_counties <- places |>
  filter(!is.na(obesity), adult_population >= 10000) |>
  slice_max(obesity, n = 15, with_ties = FALSE)

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

measure_correlations <- places |>
  filter(adult_population >= 10000) |>
  summarise(
    obesity_diabetes = cor(obesity, diabetes, use = "complete.obs"),
    obesity_current_smoking = cor(obesity, current_smoking, use = "complete.obs"),
    obesity_physical_inactivity = cor(obesity, physical_inactivity, use = "complete.obs")
  ) |>
  tidyr::pivot_longer(
    everything(),
    names_to = "comparison",
    values_to = "correlation"
  )

measure_correlations

correlation_places <- places |>
  filter(adult_population >= 10000)

pairwise_correlations <- data.frame(
  measure_x = c(
    "Obesity",
    "Obesity",
    "Obesity",
    "Diabetes",
    "Diabetes",
    "Current smoking"
  ),
  measure_y = c(
    "Diabetes",
    "Current smoking",
    "Physical inactivity",
    "Current smoking",
    "Physical inactivity",
    "Physical inactivity"
  ),
  correlation = c(
    cor(correlation_places$obesity, correlation_places$diabetes, use = "complete.obs"),
    cor(correlation_places$obesity, correlation_places$current_smoking, use = "complete.obs"),
    cor(correlation_places$obesity, correlation_places$physical_inactivity, use = "complete.obs"),
    cor(correlation_places$diabetes, correlation_places$current_smoking, use = "complete.obs"),
    cor(correlation_places$diabetes, correlation_places$physical_inactivity, use = "complete.obs"),
    cor(correlation_places$current_smoking, correlation_places$physical_inactivity, use = "complete.obs")
  )
) |>
  arrange(desc(correlation))

pairwise_correlations

inactivity_pattern_counties <- places |>
  filter(!is.na(obesity), !is.na(physical_inactivity), adult_population >= 10000) |>
  mutate(
    obesity_rank = min_rank(desc(obesity)),
    physical_inactivity_rank = min_rank(desc(physical_inactivity)),
    rank_gap = physical_inactivity_rank - obesity_rank
  ) |>
  arrange(desc(rank_gap))

inactivity_pattern_counties |>
  select(
    county_label,
    adult_population,
    obesity,
    physical_inactivity,
    obesity_rank,
    physical_inactivity_rank,
    rank_gap
  ) |>
  head(10)

smoking_pattern_counties <- places |>
  filter(!is.na(obesity), !is.na(current_smoking), adult_population >= 10000) |>
  mutate(
    obesity_rank = min_rank(desc(obesity)),
    current_smoking_rank = min_rank(desc(current_smoking)),
    rank_gap = current_smoking_rank - obesity_rank
  ) |>
  arrange(desc(rank_gap))

smoking_pattern_counties |>
  select(
    county_label,
    adult_population,
    obesity,
    current_smoking,
    obesity_rank,
    current_smoking_rank,
    rank_gap
  ) |>
  head(10)

interesting_county_reasons <- data.frame(
  geoid = c("28051", "05107", "01047", "01065", "22097", "13021", "27083", "13077", "48479"),
  selection_reason = c(
    "Highest obesity county; also high across related measures",
    "High obesity, diabetes, and physical inactivity",
    "High obesity and diabetes, but less extreme smoking",
    "High diabetes and physical inactivity with very high obesity",
    "High obesity and smoking",
    "High obesity with a less extreme smoking profile",
    "High obesity but much lower diabetes and physical inactivity rankings",
    "High obesity but much lower smoking and physical inactivity rankings",
    "High physical inactivity but lower smoking"
  )
)

interesting_counties <- places |>
  inner_join(interesting_county_reasons, by = "geoid") |>
  mutate(
    county_label = factor(county_label, levels = county_label),
    selection_reason = factor(selection_reason, levels = selection_reason)
  )

interesting_county_profiles <- interesting_counties |>
  select(
    county_label,
    selection_reason,
    obesity,
    diabetes,
    current_smoking,
    physical_inactivity
  ) |>
  tidyr::pivot_longer(
    cols = c(obesity, diabetes, current_smoking, physical_inactivity),
    names_to = "measure",
    values_to = "prevalence"
  ) |>
  mutate(
    measure = factor(
      measure,
      levels = c("obesity", "diabetes", "current_smoking", "physical_inactivity"),
      labels = measure_order
    )
  )

county_measure_profiles <- places |>
  filter(
    adult_population >= 10000,
    !is.na(obesity),
    !is.na(diabetes),
    !is.na(current_smoking),
    !is.na(physical_inactivity)
  ) |>
  mutate(
    obesity_percentile = percent_rank(obesity),
    diabetes_percentile = percent_rank(diabetes),
    current_smoking_percentile = percent_rank(current_smoking),
    physical_inactivity_percentile = percent_rank(physical_inactivity)
  )

top_obesity_profile <- county_measure_profiles |>
  semi_join(select(top_obesity_counties, geoid), by = "geoid") |>
  select(
    county_label,
    obesity,
    diabetes,
    current_smoking,
    physical_inactivity,
    obesity_percentile,
    diabetes_percentile,
    current_smoking_percentile,
    physical_inactivity_percentile
  ) |>
  tidyr::pivot_longer(
    cols = c(obesity, diabetes, current_smoking, physical_inactivity),
    names_to = "measure",
    values_to = "prevalence"
  )

top_obesity_profile_percentiles <- county_measure_profiles |>
  semi_join(select(top_obesity_counties, geoid), by = "geoid") |>
  select(
    county_label,
    obesity_percentile,
    diabetes_percentile,
    current_smoking_percentile,
    physical_inactivity_percentile
  ) |>
  tidyr::pivot_longer(
    -county_label,
    names_to = "measure",
    values_to = "percentile"
  ) |>
  mutate(measure = str_remove(measure, "_percentile$"))

top_obesity_profile <- top_obesity_profile |>
  left_join(
    top_obesity_profile_percentiles,
    by = c("county_label", "measure")
  ) |>
  mutate(
    county_label = factor(
      county_label,
      levels = rev(top_obesity_counties$county_label)
    ),
    measure = factor(
      measure,
      levels = c("obesity", "diabetes", "current_smoking", "physical_inactivity"),
      labels = c("Obesity", "Diabetes", "Current smoking", "Physical inactivity")
    ),
    prevalence_label = paste0(round(prevalence, 1), "%")
  ) |>
  select(county_label, measure, prevalence, percentile, prevalence_label)
# Candidate plots -------------------------------------------------------------

top_measures_plot <- top_counties_by_measure |>
  ggplot(aes(x = county_rank_label, y = prevalence)) +
  geom_col(fill = "#397367") +
  coord_flip() +
  facet_wrap(~measure, scales = "free_y") +
  scale_x_discrete(labels = ~ str_remove(.x, "^\\d+\\. ")) +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  labs(
    title = "Different Counties Stand Out for Different Health Measures",
    subtitle = "Top counties by estimated prevalence among counties with at least 10,000 adults",
    x = NULL,
    y = "Estimated adult prevalence",
    caption = "Source: CDC PLACES, County Data GIS-Friendly Format"
  ) +
  theme_minimal(base_size = 11) +
  theme(panel.grid.major.y = element_blank())

ggsave(
  file.path(output_dir, "top-counties-by-health-measure.png"),
  top_measures_plot,
  width = 12,
  height = 8,
  dpi = 300,
  bg = "white"
)

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

obesity_inactivity_plot <- places |>
  filter(!is.na(obesity), !is.na(physical_inactivity), adult_population >= 10000) |>
  ggplot(aes(x = obesity, y = physical_inactivity)) +
  geom_point(aes(size = adult_population), alpha = 0.35, color = "#397367") +
  geom_smooth(method = "lm", se = FALSE, color = "#c17c74", linewidth = 0.8) +
  scale_x_continuous(labels = scales::percent_format(scale = 1)) +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  scale_size_continuous(labels = scales::comma, guide = "none") +
  labs(
    title = "Obesity and Physical Inactivity Estimates Are Related",
    subtitle = "Some high-obesity counties still sit below the inactivity pattern",
    x = "Estimated adult obesity prevalence",
    y = "Estimated adult physical inactivity prevalence",
    caption = "Source: CDC PLACES, County Data GIS-Friendly Format"
  ) +
  theme_minimal()

ggsave(
  file.path(output_dir, "obesity-vs-physical-inactivity-places.png"),
  obesity_inactivity_plot,
  width = 8,
  height = 6,
  dpi = 300,
  bg = "white"
)

obesity_smoking_plot <- places |>
  filter(!is.na(obesity), !is.na(current_smoking), adult_population >= 10000) |>
  ggplot(aes(x = obesity, y = current_smoking)) +
  geom_point(aes(size = adult_population), alpha = 0.35, color = "#397367") +
  geom_smooth(method = "lm", se = FALSE, color = "#c17c74", linewidth = 0.8) +
  scale_x_continuous(labels = scales::percent_format(scale = 1)) +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  scale_size_continuous(labels = scales::comma, guide = "none") +
  labs(
    title = "Obesity and Smoking Estimates Do Not Tell the Same Story",
    subtitle = "County rankings can diverge even when measures are positively related",
    x = "Estimated adult obesity prevalence",
    y = "Estimated current smoking prevalence",
    caption = "Source: CDC PLACES, County Data GIS-Friendly Format"
  ) +
  theme_minimal()

ggsave(
  file.path(output_dir, "obesity-vs-smoking-places.png"),
  obesity_smoking_plot,
  width = 8,
  height = 6,
  dpi = 300,
  bg = "white"
)

profile_heatmap <- top_obesity_profile |>
  ggplot(aes(x = measure, y = county_label, fill = percentile)) +
  geom_tile(color = "white", linewidth = 0.6) +
  geom_text(aes(label = prevalence_label), size = 3.2, color = "#1f2933") +
  scale_fill_gradientn(
    colors = c("#f7fbff", "#b7d7e8", "#397367", "#c17c74"),
    breaks = c(0, 0.25, 0.50, 0.75, 1),
    labels = scales::percent_format(),
    limits = c(0, 1),
    name = "County percentile",
    guide = guide_colorbar(
      title.position = "top",
      barwidth = 12,
      barheight = 0.6
    )
  ) +
  labs(
    title = "High-Obesity Counties Have Different Health Profiles",
    subtitle = "Cell labels show estimated prevalence; color shows percentile among counties with at least 10,000 adults",
    x = NULL,
    y = NULL,
    caption = "Source: CDC PLACES, County Data GIS-Friendly Format"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(face = "bold"),
    legend.position = "bottom"
  )

ggsave(
  file.path(output_dir, "top-obesity-county-health-profile.png"),
  profile_heatmap,
  width = 10,
  height = 7,
  dpi = 300,
  bg = "white"
)

interesting_county_bar_plot <- interesting_county_profiles |>
  ggplot(aes(x = measure, y = prevalence, fill = measure)) +
  geom_col(width = 0.72, show.legend = FALSE) +
  geom_text(
    aes(label = paste0(round(prevalence, 1), "%")),
    vjust = -0.25,
    size = 2.8,
    color = "#1f2933"
  ) +
  facet_wrap(~county_label, ncol = 3) +
  scale_y_continuous(
    labels = scales::percent_format(scale = 1),
    limits = c(0, 56)
  ) +
  scale_fill_manual(
    values = c(
      "Obesity" = "#397367",
      "Diabetes" = "#c17c74",
      "Current smoking" = "#5c6f7b",
      "Physical inactivity" = "#d9a441"
    )
  ) +
  labs(
    title = "Selected Counties Have Different Health Profiles",
    subtitle = "Counties were selected because they stand out in different rankings or rank-gap checks",
    x = NULL,
    y = "Estimated adult prevalence",
    caption = "Source: CDC PLACES, County Data GIS-Friendly Format"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    axis.text.x = element_text(angle = 35, hjust = 1),
    panel.grid.major.x = element_blank()
  )

ggsave(
  file.path(output_dir, "selected-county-health-profiles.png"),
  interesting_county_bar_plot,
  width = 12,
  height = 9,
  dpi = 300,
  bg = "white"
)

# Promotion prep -------------------------------------------------------------

write_csv(places, file.path(output_dir, "cdc_places_county_health_selected.csv"))
saveRDS(places, file.path(output_dir, "cdc_places_county_health_selected.rds"))
write_csv(top_counties_by_measure, file.path(output_dir, "top_counties_by_health_measure.csv"))
write_csv(top_obesity_counties, file.path(output_dir, "top_county_obesity_places.csv"))
write_csv(pattern_counties, file.path(output_dir, "obesity_diabetes_rank_gaps.csv"))
write_csv(inactivity_pattern_counties, file.path(output_dir, "obesity_inactivity_rank_gaps.csv"))
write_csv(smoking_pattern_counties, file.path(output_dir, "obesity_smoking_rank_gaps.csv"))
write_csv(measure_correlations, file.path(output_dir, "obesity_measure_correlations.csv"))
write_csv(pairwise_correlations, file.path(output_dir, "pairwise_health_measure_correlations.csv"))
write_csv(interesting_counties, file.path(output_dir, "interesting_counties.csv"))
write_csv(interesting_county_profiles, file.path(output_dir, "selected_county_health_profiles.csv"))
write_csv(top_obesity_profile, file.path(output_dir, "top_obesity_county_health_profile.csv"))
