# Tutorial Proposal: Housing Supply with Census Building Permits

## Core Idea

Students create a short Quarto report about where new housing was authorized in 2025 using Census Building Permits Survey county data.

The tutorial teaches students that housing supply is not just a question of how many units are permitted. The type of units matters too.

## Data Source

- Source: U.S. Census Bureau Building Permits Survey
- Vintage/date: final annual 2025 county estimates, released May 14, 2026
- Geography or unit: county-year
- License: public domain
- Prepared data:
  - `outputs/building_permits_county_2025.csv`
  - `outputs/top_county_building_permits_2025.csv`

## Main Measure Or Question

Which counties authorized the most new housing units in 2025, and what kind of housing did they authorize?

Key measures:

```text
total_units_est = total authorized residential units
multi_family_units_est = units in 2-unit structures + units in 3-4 unit structures + units in 5+ unit structures
multi_family_share = multi_family_units_est / total_units_est
```

## Guiding Mystery

Maricopa and Harris Counties authorize the most total housing units in 2025, but Miami-Dade County has a much higher multi-family share despite ranking fifth by total units.

The tutorial can use this mystery to motivate the second section:

- Does "building a lot" mean the same thing everywhere?
- Which high-permit counties are adding mostly single-family units?
- Which are adding more multi-family supply?
- What does supply mix reveal that total permits alone does not?

## Proposed Tutorial Structure

Most tutorials should have two topic sections. Each section should create a concrete artifact.

### Introduction

Students set up `analysis.qmd`, load the prepared permit data, render, and inspect the fields.

Key early points:

- Building permits measure authorized units, not completed homes.
- Each row is a county-year.
- The raw Census file has official structure-type fields that need friendlier names.

### Section 1: Where New Housing Is Authorized

Artifact: ranked bar chart of counties with the most authorized housing units.

Likely exercise path:

1. Inspect the prepared county permit data.
2. Confirm the unit of observation.
3. Rank counties by total authorized units.
4. Create a bar chart of the top counties.
5. Improve labels, comma formatting, subtitle, and source caption.
6. Write a short interpretation of the ranking.

Pedagogical purpose:

- Students learn what building permits measure.
- The chart establishes the first version of the supply story: total volume.

### Section 2: What Kind of Housing Is Authorized

Artifact: supply-mix chart comparing one-unit and multi-family shares among high-permit counties.

Likely exercise path:

1. Create or inspect `multi_family_units_est`.
2. Calculate `multi_family_share`.
3. Compare high-permit counties by structure type.
4. Create a stacked share chart.
5. Write a short interpretation of how the supply story changes.

Pedagogical purpose:

- Students learn that totals can hide composition.
- The second artifact resolves the mystery by showing that housing supply differs by structure type.

## File Format Notes

- Use `.csv` for the prepared tutorial data because it is rectangular county-year data.
- Keep the raw Census ASCII file in the exploration, but ship a named, reduced prepared file if promoted.

## Draft Artifacts

- Ranked bar chart: `outputs/top-county-building-permits.png`
- Supply-mix chart: `outputs/top-county-supply-mix.png`

## Current Findings

- The 2025 county annual file is available from the Census BPS county ASCII directory.
- Prepared county data has 3,029 rows and 16 columns.
- Top counties by total authorized units are Maricopa, Harris, Los Angeles, Collin, Miami-Dade, Travis, Clark, Tarrant, Wake, Montgomery, Lee, Orange, Dallas, Fort Bend, and San Diego.
- Miami-Dade has a multi-family share of about 84%, compared with about 45% for Maricopa and Harris.
- Montgomery County, Texas has the lowest multi-family share among the top 15 counties, about 15%.

## Knowledge Drop Opportunities

- Data/source context: BPS tracks new privately-owned residential construction authorized by permits.
- Unit of observation: each prepared row is one county in one year.
- Variable meaning: permits are authorizations, not completions.
- Data quality issue: estimate fields include imputation.
- Interpretation point: total units and supply mix are different housing-supply stories.
- Limitation or caveat: county totals are not adjusted for county population.

## Why This Fits `misc.tutorials`

- Housing supply is a timely public-policy topic.
- Census BPS is a prominent official housing data source.
- The tutorial produces two clear artifacts.
- The dataset has a natural mystery that motivates a second visualization.

## Open Questions

- Should the tutorial stay county-level or use state-level data for simplicity?
- Should we add county population later to calculate permits per capita?
- Which counties make the most compelling final comparison?
