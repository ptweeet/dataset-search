# Exploration: US Daily Births Heatmap
# Source: fivethirtyeight R package (US_births_1994_2003, US_births_2000_2014)
# GitHub CSV: https://github.com/fivethirtyeight/data/tree/master/births
# License: CC-BY

library(dplyr)
library(ggplot2)
library(fivethirtyeight)

out <- "explorations/us-births-heatmap/outputs"

# Load and inspect -------------------------------------------------------

data("US_births_1994_2003", package = "fivethirtyeight")
data("US_births_2000_2014", package = "fivethirtyeight")

glimpse(US_births_1994_2003)
glimpse(US_births_2000_2014)

# day_of_week coding: 1 = Mon ... 7 = Sun
US_births_1994_2003 |> count(day_of_week) |> print()

# Combine: 1994–1999 from first dataset, 2000–2014 from second (avoids double-counting)
births <- bind_rows(
  US_births_1994_2003 |> filter(year < 2000),
  US_births_2000_2014
)

cat("Rows:", nrow(births), "\n")
cat("Years:", range(births$year), "\n")

# Save raw combined dataset
saveRDS(births, file.path(out, "raw/births_combined_raw.rds"))
write.csv(births, file.path(out, "raw/births_combined_raw.csv"), row.names = FALSE)

# Basic summaries --------------------------------------------------------

# Overall range
births |>
  summarise(
    min_births = min(births),
    max_births = max(births),
    mean_births = mean(births)
  ) |>
  print()

# Which single day had the fewest births?
births |> slice_min(births, n = 5) |> select(year, month, date_of_month, day_of_week, births) |> print()

# Which had the most?
births |> slice_max(births, n = 5) |> select(year, month, date_of_month, day_of_week, births) |> print()

# Day of week pattern ----------------------------------------------------
# Reveals the scheduled-birth mechanism: weekends are dramatically lower

dow_summary <- births |>
  group_by(day_of_week) |>
  summarise(mean_births = mean(births), .groups = "drop") |>
  mutate(day_of_week = factor(day_of_week,
    levels = c("Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun")))

print(dow_summary)
write.csv(dow_summary, file.path(out, "dow_summary.csv"), row.names = FALSE)

p_dow <- ggplot(dow_summary, aes(x = day_of_week, y = mean_births)) +
  geom_col(fill = "#2166ac") +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Average US Births by Day of Week (1994–2014)",
    subtitle = "Weekends have far fewer births — scheduled deliveries cluster on weekdays",
    x = NULL, y = "Mean daily births"
  ) +
  theme_minimal(base_size = 13)

ggsave(file.path(out, "births-by-day-of-week.png"), p_dow, width = 8, height = 5, dpi = 150)

# Calendar heatmap -------------------------------------------------------
# Average births by month × day of month across all years

births_by_date <- births |>
  group_by(month, date_of_month) |>
  summarise(mean_births = mean(births), .groups = "drop")

write.csv(births_by_date, file.path(out, "births_by_date.csv"), row.names = FALSE)

month_labels <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

p_heatmap <- ggplot(births_by_date, aes(x = date_of_month, y = month, fill = mean_births)) +
  geom_tile(color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(option = "B", direction = -1, labels = scales::comma) +
  scale_y_reverse(breaks = 1:12, labels = month_labels) +
  scale_x_continuous(breaks = c(1, 5, 10, 15, 20, 25, 31)) +
  labs(
    title = "Average US Births by Day of Year (1994–2014)",
    subtitle = "September clusters bright; holidays go nearly dark",
    x = "Day of month", y = NULL, fill = "Mean\nbirths"
  ) +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank())

ggsave(file.path(out, "births-heatmap.png"), p_heatmap, width = 11, height = 6, dpi = 150)

# Holiday dips -----------------------------------------------------------
# Quantify the deficit on specific dates vs. surrounding days

# Christmas (Dec 25)
dec_context <- births |>
  filter(month == 12, date_of_month %in% 20:31) |>
  group_by(date_of_month) |>
  summarise(mean_births = mean(births), .groups = "drop")

print(dec_context)
write.csv(dec_context, file.path(out, "december_births_by_day.csv"), row.names = FALSE)

p_dec <- ggplot(dec_context, aes(x = date_of_month, y = mean_births)) +
  geom_col(
    aes(fill = date_of_month %in% c(24, 25, 26, 31)),
    show.legend = FALSE
  ) +
  scale_fill_manual(values = c("FALSE" = "#2166ac", "TRUE" = "#d73027")) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Average US Births: December 20–31",
    subtitle = "Dec 24–26 and Dec 31 show sharp dips; surrounding days are normal",
    x = "Day of December", y = "Mean daily births"
  ) +
  theme_minimal(base_size = 13)

ggsave(file.path(out, "december-births-by-day.png"), p_dec, width = 8, height = 5, dpi = 150)

# Friday the 13th --------------------------------------------------------
# Compare births on the 13th by day of week to detect the Friday effect

fri13_summary <- births |>
  filter(date_of_month == 13) |>
  group_by(day_of_week) |>
  summarise(
    n_occurrences = n(),
    mean_births = mean(births),
    .groups = "drop"
  ) |>
  mutate(day_of_week = factor(day_of_week,
    levels = c("Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun")))

print(fri13_summary)
write.csv(fri13_summary, file.path(out, "friday_13th_summary.csv"), row.names = FALSE)

# Historical change in Christmas dip ------------------------------------
# Does the holiday avoidance grow over time as scheduled births became common?

christmas_by_year <- births |>
  filter(month == 12, date_of_month == 25) |>
  select(year, births)

# Compare to the average of Dec 20–24 and Dec 27–30 in same year (controls for year-level trends)
dec_baseline_by_year <- births |>
  filter(month == 12, date_of_month %in% c(20:24, 27:30)) |>
  group_by(year) |>
  summarise(baseline_births = mean(births), .groups = "drop")

christmas_vs_baseline <- christmas_by_year |>
  left_join(dec_baseline_by_year, by = "year") |>
  mutate(pct_of_baseline = births / baseline_births)

print(christmas_vs_baseline)
write.csv(christmas_vs_baseline, file.path(out, "christmas_vs_baseline_by_year.csv"), row.names = FALSE)

p_xmas_trend <- ggplot(christmas_vs_baseline, aes(x = year, y = pct_of_baseline)) +
  geom_line(color = "#2166ac", linewidth = 1) +
  geom_point(color = "#2166ac", size = 2.5) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray50") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  scale_x_continuous(breaks = seq(1994, 2014, by = 2)) +
  labs(
    title = "Christmas Day Births as a Share of Surrounding December Days",
    subtitle = "The dip has deepened over time as scheduled deliveries became more common",
    x = NULL, y = "Dec 25 births as % of nearby-day average"
  ) +
  theme_minimal(base_size = 13)

ggsave(file.path(out, "christmas-dip-over-time.png"), p_xmas_trend, width = 9, height = 5, dpi = 150)

# Prepared tutorial dataset ----------------------------------------------

births_prepared <- births |>
  select(year, month, date_of_month, day_of_week, births)

saveRDS(births_prepared, file.path(out, "births_prepared.rds"))
write.csv(births_prepared, file.path(out, "births_prepared.csv"), row.names = FALSE)

cat("\nDone. Outputs written to", out, "\n")
