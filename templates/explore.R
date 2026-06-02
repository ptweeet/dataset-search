# Lightweight dataset exploration template.
#
# Copy this file into explorations/<slug>/explore.R and edit the paths below.

library(dplyr)
library(ggplot2)

# Optional readers:
# library(readr)
# library(readxl)
# library(sf)
# library(duckdb)

source_url <- ""
local_path <- ""

# Replace this with the appropriate reader.
# dat <- readr::read_csv(local_path)

# Basic inspection ------------------------------------------------------------

# glimpse(dat)
# summary(dat)
# names(dat)

# Missingness ----------------------------------------------------------------

# dat |>
#   summarise(across(everything(), ~ sum(is.na(.x)))) |>
#   tidyr::pivot_longer(everything(), names_to = "variable", values_to = "missing") |>
#   arrange(desc(missing))

# Candidate summaries --------------------------------------------------------

# dat |>
#   count(<category>, sort = TRUE)

# Candidate plot -------------------------------------------------------------

# ggplot(dat, aes(x = <x>, y = <y>)) +
#   geom_point() +
#   theme_minimal()

# Promotion prep -------------------------------------------------------------

# Keep only the fields and rows needed for a tutorial.
# tutorial_dat <- dat |>
#   select()
#
# saveRDS(tutorial_dat, "outputs/<dataset>.rds")
