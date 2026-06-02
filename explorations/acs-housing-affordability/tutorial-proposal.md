# Tutorial Proposal: Housing Affordability with Census Data

## Core Idea

Students create a short Quarto report about renter cost burden across U.S. states using 2024 ACS 5-year data.

The tutorial teaches students how to work with a gold-standard public data source, interpret an affordability measure, and compare what different visual artifacts reveal.

## Data Source

- Source: U.S. Census Bureau American Community Survey
- Vintage: 2024 ACS 5-year estimates
- Geography: states, including DC and Puerto Rico
- Prepared data:
  - `outputs/acs_housing_affordability_states.csv`
  - `outputs/acs_housing_affordability_states.rds`
  - `outputs/acs_housing_affordability_states_geo.rds`

## Main Measure

`rent_burden_rate` is the share of renter households with computed rent burden that spend at least 30% of household income on gross rent.

Working definition:

```text
(rent 30.0-34.9% + rent 35.0-39.9% + rent 40.0-49.9% + rent 50.0%+) /
(total renter households - rent burden not computed)
```

## Guiding Mystery

Florida ranks highest in this extract by renter cost burden, ahead of places like Hawaii and California. That is surprising because Florida does not have the highest median gross rent.

The tutorial can use this mystery to motivate the first section:

- Is rent burden mostly about high rents?
- Or does income change the story?
- What does `rent_burden_rate` reveal that median rent alone does not?

The map can extend the mystery:

- Is high rent burden concentrated in one region?
- Do high-burden states form a visible geographic pattern?
- What does the map reveal that the bar chart does not?

## Proposed Tutorial Structure

### Introduction

Students set up `analysis.qmd`, load the needed packages, render, and inspect the prepared ACS data.

Key early points:

- ACS data is survey-based.
- Each row in this extract is a geography.
- Median rent, median income, home value, and rent burden are related but distinct measures.

### Section 1: Rent Burden Rankings

Artifact: ranked bar chart of the states with the highest renter cost burden.

Likely exercise path:

1. Inspect the prepared ACS data.
2. Load the non-spatial `.csv` file and note that it is a plain text table.
3. Print selected columns and confirm the unit of observation.
4. Rank states by `rent_burden_rate`.
5. Create a bar chart of the top states.
6. Improve labels, subtitle, axis formatting, and source caption.
7. Write a short interpretation.

Pedagogical purpose:

- The bar chart teaches precise comparison and ranking.
- Students see that ranking by rent burden differs from ranking by median rent alone.

### Section 2: Rent Burden Geography

Artifact: choropleth map of renter cost burden across U.S. states.

Likely exercise path:

1. Introduce why the map section uses `.rds` instead of `.csv`.
2. Introduce geometry as shape data attached to rows.
3. Inspect the map-ready spatial data.
4. Create a first state map using `rent_burden_rate`.
5. Improve fill scale, legend labels, title, subtitle, and source caption.
6. Compare the map to the bar chart.
7. Write a short geographic interpretation.

Pedagogical purpose:

- The map introduces spatial data without becoming a GIS tutorial.
- Students learn that maps are useful when geography reveals patterns that rankings do not.

## File Format Teaching Opportunity

This tutorial can use file formats as a small, practical lesson:

- Use `.csv` in Section 1 because the bar-chart data is an ordinary table that students can inspect in many tools.
- Use `.rds` in Section 2 because the map-ready data is an R object with an `sf` geometry column, which `.csv` does not preserve well.

The transition from the bar chart to the map gives students a reason to learn the distinction. `.csv` is portable and transparent; `.rds` preserves richer R objects.

## Draft Artifacts

- Ranked bar chart: `outputs/top-state-rent-burden.png`
- State map: `outputs/state-rent-burden-map.png`

## Current Findings

- Prepared non-spatial extract has 52 rows and 13 columns.
- Prepared spatial extract has 52 rows and 15 columns.
- No missing values in the prepared non-spatial fields.
- Top states by renter cost burden are Florida, Hawaii, Nevada, California, Louisiana, Colorado, Connecticut, Oregon, Georgia, and South Carolina.
- Florida ranks highest by renter cost burden even though Hawaii and California have higher median gross rent.

## Why This Fits `misc.tutorials`

- Housing is a recognizable real-world domain.
- ACS is a durable, prominent public data source.
- The tutorial can teach domain vocabulary students should use when prompting AI.
- The analysis path produces two concrete artifacts.
- The final Quarto report says something meaningful about housing affordability across the United States.

## Open Questions

- Should the final tutorial use states only, or add a later county-level variation?
- Should Puerto Rico remain in the map artifact or be handled separately in prose?
- How much should the tutorial emphasize margins of error in this first version?
- Should the final package data use `.csv`, `.rds`, or both?
