# Explore ACS housing affordability data at the state level.

library(dplyr)
library(ggplot2)
library(readr)
library(sf)
library(tidycensus)
library(tigris)

source_url <- "https://www.census.gov/programs-surveys/acs/data/data-via-api.html"
api_base_url <- "https://api.census.gov/data/2024/acs/acs5"

acs_year <- 2024
acs_survey <- "acs5"
geography <- "state"

script_file <- sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE))
script_dir <- if (length(script_file) == 1) dirname(normalizePath(script_file)) else getwd()
output_dir <- file.path(script_dir, "outputs")
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

if (!nzchar(Sys.getenv("CENSUS_API_KEY"))) {
  stop(
    "Set CENSUS_API_KEY before pulling ACS data. ",
    "Metadata is public, but Census API data requests currently require a key."
  )
}

census_api_key(Sys.getenv("CENSUS_API_KEY"), install = FALSE, overwrite = TRUE)

acs_variables <- c(
  median_household_income = "B19013_001",
  median_gross_rent = "B25064_001",
  median_home_value = "B25077_001",
  renter_households_total = "B25070_001",
  rent_30_to_34 = "B25070_007",
  rent_35_to_39 = "B25070_008",
  rent_40_to_49 = "B25070_009",
  rent_50_plus = "B25070_010",
  rent_not_computed = "B25070_011"
)

raw_acs <- get_acs(
  geography = geography,
  variables = acs_variables,
  year = acs_year,
  survey = acs_survey,
  output = "wide",
  cache_table = TRUE
)

raw_acs_geo <- get_acs(
  geography = geography,
  variables = acs_variables,
  year = acs_year,
  survey = acs_survey,
  output = "wide",
  geometry = TRUE,
  cache_table = TRUE
)

dat <- raw_acs |>
  transmute(
    geoid = GEOID,
    name = NAME,
    median_household_income = median_household_incomeE,
    median_household_income_moe = median_household_incomeM,
    median_gross_rent = median_gross_rentE,
    median_gross_rent_moe = median_gross_rentM,
    median_home_value = median_home_valueE,
    median_home_value_moe = median_home_valueM,
    renter_households_total = renter_households_totalE,
    rent_not_computed = rent_not_computedE,
    renter_households_computed = renter_households_totalE - rent_not_computedE,
    rent_burdened_households =
      rent_30_to_34E + rent_35_to_39E + rent_40_to_49E + rent_50_plusE,
    rent_burden_rate = rent_burdened_households / renter_households_computed,
    annual_rent_to_income = (median_gross_rentE * 12) / median_household_incomeE
  ) |>
  arrange(desc(rent_burden_rate))

dat_geo <- raw_acs_geo |>
  transmute(
    geoid = GEOID,
    name = NAME,
    median_household_income = median_household_incomeE,
    median_household_income_moe = median_household_incomeM,
    median_gross_rent = median_gross_rentE,
    median_gross_rent_moe = median_gross_rentM,
    median_home_value = median_home_valueE,
    median_home_value_moe = median_home_valueM,
    renter_households_total = renter_households_totalE,
    rent_not_computed = rent_not_computedE,
    renter_households_computed = renter_households_totalE - rent_not_computedE,
    rent_burdened_households =
      rent_30_to_34E + rent_35_to_39E + rent_40_to_49E + rent_50_plusE,
    rent_burden_rate = rent_burdened_households / renter_households_computed,
    annual_rent_to_income = (median_gross_rentE * 12) / median_household_incomeE,
    geometry = geometry
  ) |>
  st_as_sf() |>
  shift_geometry()

# Basic inspection ------------------------------------------------------------

glimpse(dat)

dat |>
  summarise(across(where(is.numeric), list(
    min = ~ min(.x, na.rm = TRUE),
    median = ~ median(.x, na.rm = TRUE),
    max = ~ max(.x, na.rm = TRUE)
  )))

# Missingness ----------------------------------------------------------------

dat |>
  summarise(across(everything(), ~ sum(is.na(.x)))) |>
  tidyr::pivot_longer(everything(), names_to = "variable", values_to = "missing") |>
  arrange(desc(missing))

# Candidate summaries --------------------------------------------------------

top_rent_burden <- dat |>
  select(
    name,
    rent_burden_rate,
    median_gross_rent,
    median_household_income,
    annual_rent_to_income
  ) |>
  head(10)

top_rent_burden

# Candidate plot -------------------------------------------------------------

rent_burden_plot <- top_rent_burden |>
  ggplot(aes(x = reorder(name, rent_burden_rate), y = rent_burden_rate)) +
  geom_col(fill = "#397367") +
  coord_flip() +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "States with the Highest Renter Cost Burden",
    subtitle = "Share of renter households with computed rent burden spending at least 30% of income on gross rent",
    x = NULL,
    y = "Rent-burdened renter households",
    caption = "Source: U.S. Census Bureau, 2024 ACS 5-year estimates"
  ) +
  theme_minimal()

ggsave(
  file.path(output_dir, "top-state-rent-burden.png"),
  rent_burden_plot,
  width = 8,
  height = 5,
  dpi = 300
)

# Candidate map --------------------------------------------------------------

rent_burden_map <- ggplot(dat_geo) +
  geom_sf(aes(fill = rent_burden_rate), color = "white", linewidth = 0.2) +
  scale_fill_viridis_c(
    option = "mako",
    direction = -1,
    labels = scales::percent,
    name = "Rent burden"
  ) +
  labs(
    title = "Renter Cost Burden Across U.S. States",
    subtitle = "Share of renter households with computed rent burden spending at least 30% of income on gross rent",
    caption = "Source: U.S. Census Bureau, 2024 ACS 5-year estimates"
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    plot.title.position = "plot",
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    legend.background = element_rect(fill = "white", color = NA)
  )

ggsave(
  file.path(output_dir, "state-rent-burden-map.png"),
  rent_burden_map,
  width = 9,
  height = 5.5,
  dpi = 300,
  bg = "white"
)

# Promotion prep -------------------------------------------------------------

tutorial_dat <- dat |>
  select(
    geoid,
    name,
    median_household_income,
    median_household_income_moe,
    median_gross_rent,
    median_gross_rent_moe,
    median_home_value,
    median_home_value_moe,
    renter_households_total,
    renter_households_computed,
    rent_burdened_households,
    rent_burden_rate,
    annual_rent_to_income
  )

saveRDS(tutorial_dat, file.path(output_dir, "acs_housing_affordability_states.rds"))
write_csv(tutorial_dat, file.path(output_dir, "acs_housing_affordability_states.csv"))
saveRDS(dat_geo, file.path(output_dir, "acs_housing_affordability_states_geo.rds"))
