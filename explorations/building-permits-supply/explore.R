# Explore Census Building Permits Survey county annual data.

library(dplyr)
library(ggplot2)
library(readr)
library(stringr)
library(tidyr)

source_url <- "https://www.census.gov/permits"
county_annual_url <- "https://www2.census.gov/econ/bps/County/co2025a.txt"

script_file <- sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE))
script_dir <- if (length(script_file) == 1) dirname(normalizePath(script_file)) else getwd()
output_dir <- file.path(script_dir, "outputs")
raw_dir <- file.path(output_dir, "raw")
dir.create(raw_dir, showWarnings = FALSE, recursive = TRUE)

raw_path <- file.path(raw_dir, "co2025a.txt")
download.file(county_annual_url, raw_path, mode = "wb", quiet = TRUE)

permit_cols <- c(
  "survey_year",
  "state_fips",
  "county_fips",
  "region",
  "division",
  "county_name",
  "units_1_buildings_est",
  "units_1_units_est",
  "units_1_value_est",
  "units_2_buildings_est",
  "units_2_units_est",
  "units_2_value_est",
  "units_3_4_buildings_est",
  "units_3_4_units_est",
  "units_3_4_value_est",
  "units_5plus_buildings_est",
  "units_5plus_units_est",
  "units_5plus_value_est",
  "units_1_buildings_reported",
  "units_1_units_reported",
  "units_1_value_reported",
  "units_2_buildings_reported",
  "units_2_units_reported",
  "units_2_value_reported",
  "units_3_4_buildings_reported",
  "units_3_4_units_reported",
  "units_3_4_value_reported",
  "units_5plus_buildings_reported",
  "units_5plus_units_reported",
  "units_5plus_value_reported"
)

raw_permits <- read_csv(
  raw_path,
  col_names = permit_cols,
  skip = 3,
  show_col_types = FALSE,
  col_types = cols(.default = col_character())
)

permits <- raw_permits |>
  mutate(
    across(
      -county_name,
      ~ parse_number(.x)
    ),
    state_fips = str_pad(as.character(state_fips), 2, pad = "0"),
    county_fips = str_pad(as.character(county_fips), 3, pad = "0"),
    geoid = paste0(state_fips, county_fips),
    total_units_est = units_1_units_est + units_2_units_est + units_3_4_units_est + units_5plus_units_est,
    total_value_est = units_1_value_est + units_2_value_est + units_3_4_value_est + units_5plus_value_est,
    multi_family_units_est = units_2_units_est + units_3_4_units_est + units_5plus_units_est,
    multi_family_share = if_else(total_units_est > 0, multi_family_units_est / total_units_est, NA_real_),
    single_family_share = if_else(total_units_est > 0, units_1_units_est / total_units_est, NA_real_)
  ) |>
  select(
    survey_year,
    geoid,
    state_fips,
    county_fips,
    county_name,
    region,
    division,
    units_1_units_est,
    units_2_units_est,
    units_3_4_units_est,
    units_5plus_units_est,
    multi_family_units_est,
    total_units_est,
    total_value_est,
    multi_family_share,
    single_family_share
  ) |>
  arrange(desc(total_units_est))

# Basic inspection ------------------------------------------------------------

glimpse(permits)

permits |>
  summarise(
    rows = n(),
    counties = n_distinct(geoid),
    total_units = sum(total_units_est, na.rm = TRUE),
    counties_with_zero_units = sum(total_units_est == 0, na.rm = TRUE),
    missing_total_units = sum(is.na(total_units_est))
  )

# Candidate summaries --------------------------------------------------------

top_permit_counties <- permits |>
  filter(total_units_est > 0) |>
  slice_max(total_units_est, n = 15) |>
  mutate(county_label = str_glue("{county_name} ({state_fips})"))

top_permit_counties |>
  select(county_name, state_fips, total_units_est, units_1_units_est, multi_family_units_est, multi_family_share)

supply_mix <- top_permit_counties |>
  select(county_label, units_1_units_est, multi_family_units_est) |>
  pivot_longer(
    cols = c(units_1_units_est, multi_family_units_est),
    names_to = "structure_type",
    values_to = "units"
  ) |>
  mutate(
    structure_type = recode(
      structure_type,
      units_1_units_est = "One-unit structures",
      multi_family_units_est = "Multi-family structures"
    )
  )

# Candidate plots -------------------------------------------------------------

top_permits_plot <- top_permit_counties |>
  ggplot(aes(x = reorder(county_label, total_units_est), y = total_units_est)) +
  geom_col(fill = "#397367") +
  coord_flip() +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Counties Authorizing the Most New Housing Units",
    subtitle = "New privately-owned residential units authorized by building permits, 2025",
    x = NULL,
    y = "Authorized housing units",
    caption = "Source: U.S. Census Bureau Building Permits Survey"
  ) +
  theme_minimal()

ggsave(
  file.path(output_dir, "top-county-building-permits.png"),
  top_permits_plot,
  width = 9,
  height = 6,
  dpi = 300,
  bg = "white"
)

supply_mix_plot <- supply_mix |>
  ggplot(aes(x = reorder(county_label, units), y = units, fill = structure_type)) +
  geom_col(position = "fill") +
  coord_flip() +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = c("One-unit structures" = "#397367", "Multi-family structures" = "#c17c74")) +
  labs(
    title = "High-Permit Counties Differ in Their Housing Supply Mix",
    subtitle = "Share of authorized units in one-unit versus multi-family structures, 2025",
    x = NULL,
    y = "Share of authorized units",
    fill = NULL,
    caption = "Source: U.S. Census Bureau Building Permits Survey"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave(
  file.path(output_dir, "top-county-supply-mix.png"),
  supply_mix_plot,
  width = 9,
  height = 6,
  dpi = 300,
  bg = "white"
)

# Promotion prep -------------------------------------------------------------

write_csv(permits, file.path(output_dir, "building_permits_county_2025.csv"))
saveRDS(permits, file.path(output_dir, "building_permits_county_2025.rds"))
write_csv(top_permit_counties, file.path(output_dir, "top_county_building_permits_2025.csv"))
