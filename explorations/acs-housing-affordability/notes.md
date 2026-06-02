# Dataset Notes: ACS Housing Affordability

## Summary

- Slug: acs-housing-affordability
- Status: exploring
- Source: https://www.census.gov/programs-surveys/acs/data/data-via-api.html
- License: Public domain
- Domain: housing
- File format: Census API during exploration; prepared `.rds` and `.csv` for tutorial use
- Size: 52 rows x 13 columns in the prepared state-level extract
- Local files:
  - `outputs/acs_housing_affordability_states.rds`
  - `outputs/acs_housing_affordability_states.csv`
  - `outputs/acs_housing_affordability_states_geo.rds`
  - `outputs/top-state-rent-burden.png`
  - `outputs/state-rent-burden-map.png`

## Why This Might Make a Good Tutorial

- Potential learner audience: students learning to use real public data sources for local housing questions
- Main learning goal: compare housing affordability across places using ACS estimates
- Supporting concepts: geography, medians, rent burden, margins of error, variable definitions, local variation
- Possible tutorial title: Housing Affordability with Census Data

## Planned Tutorial Structure

Most tutorials should have two topic sections. For this tutorial, each section can create one artifact:

1. Rent Burden Rankings
   - Artifact: ranked bar chart of the states with the highest renter cost burden
   - Purpose: teach the affordability measure directly and show precise ranking
   - Interpretation question: what does the ranking show, and why is it different from just ranking median rent?

2. Rent Burden Geography
   - Artifact: choropleth map of renter cost burden across U.S. states
   - Purpose: introduce geometry as shape data attached to rows, then use the same affordability measure geographically
   - Interpretation question: what geographic pattern does the map reveal that the bar chart did not?

The bar chart and map should not be redundant. The bar chart should answer which states rank highest. The map should answer where high renter cost burden clusters geographically.

## Questions The Dataset Can Answer

1. Which selected counties or states have the highest median rent relative to income?
2. Where are renter households most likely to be rent burdened?
3. How do median rent, median home value, and household income tell different stories about affordability?

## Data Inspection

- Number of rows: 52 state-level rows, including DC and Puerto Rico
- Number of columns: 13 prepared columns
- Spatial rows: 52 rows in the map-ready file, including DC and Puerto Rico
- Key variables: median gross rent, median household income, median home value, renter cost burden, geography name
- Missing data: none in prepared fields
- Surprising values: Florida has the highest state-level rent-burden rate in this extract, above Hawaii, Nevada, and California
- Required cleaning: variable renaming, computed rent-burden rate, and estimate/MOE handling

### State-Level Variable Plan

Use 2024 ACS 5-year detailed tables:

- `B19013_001`: median household income in the past 12 months
- `B25064_001`: median gross rent
- `B25077_001`: median value of owner-occupied housing units
- `B25070_001`: total renter-occupied housing units
- `B25070_007`: gross rent is 30.0 to 34.9 percent of household income
- `B25070_008`: gross rent is 35.0 to 39.9 percent of household income
- `B25070_009`: gross rent is 40.0 to 49.9 percent of household income
- `B25070_010`: gross rent is 50.0 percent or more of household income
- `B25070_011`: gross rent percentage not computed

Working definition:

```text
rent_burden_rate =
  (B25070_007 + B25070_008 + B25070_009 + B25070_010) /
  (B25070_001 - B25070_011)
```

This uses renter households with a computed rent burden as the denominator.

## Teaching Fit

- Beginner friendliness: high if we preselect variables and geography
- Interestingness: high; housing affordability is recognizable and local
- Stability: high for prepared ACS extracts, though annual ACS releases change values
- Package size impact: likely low if reduced to selected places and variables
- Maintenance risk: moderate if relying on live API calls; lower with a frozen teaching file
- Ethics/privacy concerns: low for aggregate ACS data; interpretation should avoid overclaiming about individuals

## Tutorial Fit

- Target learner: students past infrastructure tutorials who can use AI to edit and render `analysis.qmd`
- Possible final Quarto artifact: a short report comparing housing affordability across selected counties or states
- Main result about the world: some places are more rent-burdened or expensive relative to income than others, and the measure chosen changes the story
- Why this belongs in `misc.tutorials`: ACS is a gold-standard public data source, and housing is a real domain where analysts need source vocabulary and careful interpretation

### Possible Exercise Path

1. Get local data into the project: provide or create a reduced ACS housing file
2. Inspect structure and vocabulary: print variable names, geography fields, estimates, and MOE columns
3. Summarize important variables: rank places by rent, income, home value, and rent burden
4. Notice a problem, pattern, or limitation: similar estimates may not be meaningfully different once MOE is considered
5. Produce the first artifact: ranked bar chart of rent-burden states
6. Interpret the ranking: one or two sentences explaining what the selected measure does and does not show
7. Introduce geometry: show that state rows can carry a boundary shape column for mapping
8. Produce the second artifact: choropleth map of state rent burden
9. Interpret the geography: one or two sentences explaining what the map shows that the bar chart did not
10. Publish or prepare for publication: final render, source caption, and GitHub Pages publish

### Rendered Outputs Students Could Inspect

- Printed tibble: selected ACS variables by geography
- Summary statistics: range and missingness for affordability measures
- Plot: ranked bar chart comparing the highest rent-burden states
- Map: choropleth map comparing renter cost burden across states
- Table: top/bottom places by rent burden or rent-to-income ratio
- Final page element: short interpretation paragraph with source caption

### Knowledge Drop Candidates

Use these for short teaching notes after exercises. They should be about the data, the domain, the rendered output, or a key point from a companion text.

- Data/source context: ACS is a survey-based source for housing, social, economic, and demographic estimates
- Unit of observation: each row is likely a geography, not a person or household, after aggregation
- Variable meaning: median gross rent, median household income, and rent burden measure different affordability concepts
- Data quality issue: ACS estimates include uncertainty; margins of error matter for close comparisons
- Interpretation point: a county median can hide large within-county differences
- Geometry concept: a map-ready data frame can have ordinary columns plus one geometry column containing shapes
- Visualization comparison: bar charts make ranking easier, while maps make regional clustering easier to see
- File format concept: `.csv` is a portable plain text table, while `.rds` preserves richer R objects such as `sf` data with geometry
- Limitation or caveat: aggregate data cannot describe every household in a place

### Reproducibility Plan

- Can `analysis.qmd` read local data without downloading during render? yes, after exploration creates a prepared file
- Where should source copies or prepared data live? likely `inst/extdata/<tutorial>/` in `misc.tutorials`
- What source URL comment should appear near the data-reading code? Source: U.S. Census Bureau ACS API, https://www.census.gov/programs-surveys/acs/data/data-via-api.html
- What data reduction or transformation is needed before promotion? choose geography, variables, year, variable names, and whether to include MOE columns
- File format plan: use `.csv` for the non-spatial bar-chart section and `.rds` for the map-ready spatial section

## Exploration Results

- 2026-06-02: Confirmed 2024 ACS 5-year API metadata is available. Live data requests currently require a Census API key.
- 2026-06-02: Pulled 2024 ACS 5-year state data with `tidycensus`. Prepared extract has 52 rows and 13 columns. There are no missing values in the prepared fields.
- 2026-06-02: Top 10 states by computed renter cost burden are Florida, Hawaii, Nevada, California, Louisiana, Colorado, Connecticut, Oregon, Georgia, and South Carolina.
- 2026-06-02: The state-level extract produces a clear ranked-bar-chart exercise. It may be enough for an introductory ACS housing tutorial, though counties would provide more local texture.
- 2026-06-02: Added a spatial extract and draft state choropleth map. The map-ready file has 52 rows and keeps the same geographies as the non-spatial extract.

## Decision

- Decision: continue exploring
- Reason: strong alignment with the authoring guide and housing topic goals
- Next action: inspect the plot and decide whether state-level variation is rich enough, or whether to create a second county-level extract

## Promotion Notes

If promoted, record:

- target tutorial folder:
- final data format:
- transformations applied:
- source notes required:
- tutorial authoring guide concerns:
