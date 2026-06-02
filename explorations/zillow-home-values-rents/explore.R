# Explore Zillow metro home-value and rent data.

library(dplyr)
library(ggplot2)
library(lubridate)
library(readr)
library(stringr)
library(tidyr)

source_url <- "https://www.zillow.com/research/data/"

zhvi_url <- "https://files.zillowstatic.com/research/public_csvs/zhvi/Metro_zhvi_uc_sfrcondo_tier_0.33_0.67_sm_sa_month.csv"
zori_url <- "https://files.zillowstatic.com/research/public_csvs/zori/Metro_zori_uc_sfrcondomfr_sm_month.csv"

script_file <- sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE))
script_dir <- if (length(script_file) == 1) dirname(normalizePath(script_file)) else getwd()
output_dir <- file.path(script_dir, "outputs")
raw_dir <- file.path(output_dir, "raw")
dir.create(raw_dir, showWarnings = FALSE, recursive = TRUE)

zhvi_raw_path <- file.path(raw_dir, "zillow_metro_zhvi.csv")
zori_raw_path <- file.path(raw_dir, "zillow_metro_zori.csv")

download.file(zhvi_url, zhvi_raw_path, mode = "wb", quiet = TRUE)
download.file(zori_url, zori_raw_path, mode = "wb", quiet = TRUE)

zhvi_raw <- read_csv(zhvi_raw_path, show_col_types = FALSE)
zori_raw <- read_csv(zori_raw_path, show_col_types = FALSE)

selected_metros <- c(
  "United States",
  "New York, NY",
  "Miami, FL",
  "Phoenix, AZ",
  "Austin, TX",
  "Denver, CO",
  "Boston, MA",
  "San Francisco, CA"
)

reshape_zillow <- function(dat, value_name) {
  dat |>
    filter(RegionName %in% selected_metros) |>
    pivot_longer(
      cols = matches("^\\d{4}-\\d{2}-\\d{2}$"),
      names_to = "date",
      values_to = value_name
    ) |>
    mutate(date = as.Date(date)) |>
    select(RegionID, SizeRank, RegionName, RegionType, StateName, date, all_of(value_name))
}

zhvi_long <- reshape_zillow(zhvi_raw, "zhvi")
zori_long <- reshape_zillow(zori_raw, "zori")

zillow_joined <- zori_long |>
  inner_join(
    zhvi_long,
    by = c("RegionID", "SizeRank", "RegionName", "RegionType", "StateName", "date")
  ) |>
  filter(date >= as.Date("2020-01-31")) |>
  arrange(RegionName, date)

zillow_indexed <- zillow_joined |>
  group_by(RegionName) |>
  filter(!is.na(zori), !is.na(zhvi)) |>
  mutate(
    zori_index = zori / first(zori) * 100,
    zhvi_index = zhvi / first(zhvi) * 100
  ) |>
  ungroup()

zillow_indexed_long <- zillow_indexed |>
  select(RegionName, date, zori_index, zhvi_index) |>
  pivot_longer(
    cols = c(zori_index, zhvi_index),
    names_to = "measure",
    values_to = "index_value"
  ) |>
  mutate(
    measure = recode(
      measure,
      zori_index = "Rent index",
      zhvi_index = "Home value index"
    )
  )

# Basic inspection ------------------------------------------------------------

glimpse(zori_raw)
glimpse(zhvi_raw)

zillow_joined |>
  summarise(
    rows = n(),
    metros = n_distinct(RegionName),
    first_date = min(date),
    last_date = max(date),
    missing_zori = sum(is.na(zori)),
    missing_zhvi = sum(is.na(zhvi))
  )

# Candidate summaries --------------------------------------------------------

latest_growth <- zillow_indexed |>
  group_by(RegionName) |>
  filter(date == max(date)) |>
  ungroup() |>
  transmute(
    RegionName,
    date,
    rent_growth_since_2020 = zori_index - 100,
    home_value_growth_since_2020 = zhvi_index - 100,
    growth_gap = home_value_growth_since_2020 - rent_growth_since_2020
  ) |>
  arrange(desc(rent_growth_since_2020))

latest_growth

# Candidate plots ------------------------------------------------------------

rent_trend_plot <- zillow_indexed |>
  filter(RegionName != "United States") |>
  ggplot(aes(x = date, y = zori, color = RegionName)) +
  geom_line(linewidth = 0.8) +
  scale_y_continuous(labels = scales::dollar) +
  labs(
    title = "Typical Rents in Selected Metro Areas",
    subtitle = "Zillow Observed Rent Index, January 2020 through latest available month",
    x = NULL,
    y = "ZORI",
    color = NULL,
    caption = "Source: Zillow Research Data"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave(
  file.path(output_dir, "selected-metro-rent-trends.png"),
  rent_trend_plot,
  width = 9,
  height = 5.5,
  dpi = 300,
  bg = "white"
)

growth_comparison_plot <- zillow_indexed_long |>
  filter(RegionName %in% c("United States", "Miami, FL", "Phoenix, AZ", "Austin, TX")) |>
  ggplot(aes(x = date, y = index_value, color = measure)) +
  geom_hline(yintercept = 100, color = "gray75", linewidth = 0.3) +
  geom_line(linewidth = 0.8) +
  facet_wrap(vars(RegionName), ncol = 2) +
  labs(
    title = "Rent and Home Value Growth Since January 2020",
    subtitle = "Each series is indexed to 100 at the first available 2020 observation",
    x = NULL,
    y = "Index value",
    color = NULL,
    caption = "Source: Zillow Research Data"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave(
  file.path(output_dir, "rent-vs-home-value-growth.png"),
  growth_comparison_plot,
  width = 9,
  height = 6,
  dpi = 300,
  bg = "white"
)

# Promotion prep -------------------------------------------------------------

write_csv(zillow_joined, file.path(output_dir, "zillow_metro_rents_values_long.csv"))
write_csv(zillow_indexed, file.path(output_dir, "zillow_metro_rents_values_indexed.csv"))
write_csv(latest_growth, file.path(output_dir, "zillow_metro_latest_growth.csv"))
saveRDS(zillow_indexed, file.path(output_dir, "zillow_metro_rents_values_indexed.rds"))
