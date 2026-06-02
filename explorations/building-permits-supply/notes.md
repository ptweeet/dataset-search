# Dataset Notes: Census Building Permits Survey Housing Supply

## Summary

- Slug: building-permits-supply
- Status: exploring
- Source: https://www.census.gov/permits
- License: Public domain
- Domain: housing
- File format: Census ASCII comma-delimited text during exploration; prepared `.csv`/`.rds` for tutorial use
- Size: 2025 county annual file is about 367 KB
- Local files:
  - `outputs/raw/co2025a.txt`
  - `outputs/building_permits_county_2025.csv`
  - `outputs/building_permits_county_2025.rds`
  - `outputs/top_county_building_permits_2025.csv`
  - `outputs/top-county-building-permits.png`
  - `outputs/top-county-supply-mix.png`

## Why This Might Make a Good Tutorial

- Potential learner audience: students learning how housing supply is measured in public data
- Main learning goal: analyze new privately-owned residential construction authorized by building permits
- Supporting concepts: permits versus completed homes, county geography, structure type, supply mix, rankings
- Possible tutorial title: Housing Supply with Census Building Permits

## Questions The Dataset Can Answer

1. Which counties authorized the most new housing units in 2025?
2. Which high-permit counties relied more on multi-family structures?
3. How does the story change when we compare total units with supply mix?

## Guiding Mystery

- Surprising pattern: Miami-Dade County ranks fifth by total authorized units among the selected top counties but has a much higher multi-family share than Maricopa or Harris Counties.
- Why the first guess may be incomplete: total permits measure volume, but supply mix shows what kind of housing is being authorized.
- Follow-up table, plot, map, or comparison needed: a ranked bar chart for total units, followed by a supply-mix chart for selected high-permit counties.
- Interpretation exercise this could support: explain why a county can be a major source of new housing units without having the same structure mix as another high-growth county.

## Data Inspection

- Number of rows: 3,029 prepared county rows
- Number of columns: 16 prepared columns
- Key variables: survey year, state FIPS, county FIPS, county name, units by structure type, valuation by structure type
- Missing data: no missing total unit values in the prepared data
- Surprising values: among the top 15 counties by total authorized units, multi-family share ranges from about 15% in Montgomery County, Texas to about 84% in Miami-Dade County, Florida
- Required cleaning: add column names, build county GEOID, select estimate-with-imputation fields, calculate total units and multi-family share

## Source Notes

The Building Permits Survey provides statistics on new privately-owned residential construction. The Census Bureau says data are available monthly, year-to-date, and annually at national, state, CBSA, county, and place levels.

The county ASCII documentation defines annual file names as `coYYYYa.txt` and describes the 30-column record layout. The 2025 final annual county file is available as:

```text
https://www2.census.gov/econ/bps/County/co2025a.txt
```

Important interpretation point: building permits measure housing units authorized by permits, not completed housing units.

## Teaching Fit

- Beginner friendliness: medium; raw ASCII files need column naming
- Interestingness: high; housing supply is timely and policy-relevant
- Stability: high for frozen annual extracts
- Package size impact: low after reduction
- Maintenance risk: low if using frozen prepared data; moderate if re-downloading current annual files
- Ethics/privacy concerns: low; county aggregate public records

## Tutorial Fit

- Target learner: students learning to use AI to turn public raw data files into clear analytical artifacts
- Possible final Quarto artifact: a two-section report comparing where new housing is authorized and what kind of supply is being permitted
- Main result about the world: housing supply is not only about how many units are permitted, but also about whether those units are single-family or multi-family
- Why this belongs in `misc.tutorials`: Census Building Permits is a prominent housing data source with real policy relevance and nontrivial source vocabulary

### Possible Exercise Path

1. Get local prepared permit data into the project.
2. Inspect the raw field names and prepared county-level data.
3. Rank counties by total authorized housing units.
4. Produce the first artifact: ranked bar chart of top permit counties.
5. Interpret what building permits measure.
6. Compare single-family and multi-family units among selected high-permit counties.
7. Produce the second artifact: supply-mix chart.
8. Interpret how total volume and structure mix tell different stories.

### Rendered Outputs Students Could Inspect

- Printed tibble: prepared county permit data
- Summary statistics: total units, single-family units, multi-family units
- Plot: ranked bar chart of counties by total authorized units
- Plot: supply-mix chart for selected counties
- Final page element: short interpretation paragraph with source caption

### Knowledge Drop Candidates

Use these for short teaching notes after exercises. They should be about the data, the domain, the rendered output, or a key point from a companion text.

- Data/source context: Building Permits Survey tracks new privately-owned residential construction authorized by permits
- Unit of observation: each row is a county-year
- Variable meaning: one-unit structures are separated from 2-unit, 3-4-unit, and 5+-unit structures
- Data quality issue: estimates with imputation include reported and imputed data
- Interpretation point: permits are authorizations, not completed homes
- Limitation or caveat: counties with large populations naturally tend to authorize more units unless rates are calculated

### Reproducibility Plan

- Can `analysis.qmd` read local data without downloading during render? yes, after exploration creates prepared files
- Where should source copies or prepared data live? likely `inst/extdata/<tutorial>/` in `misc.tutorials`
- What source URL comment should appear near the data-reading code? Source: U.S. Census Bureau Building Permits Survey, https://www.census.gov/permits
- What data reduction or transformation is needed before promotion? select year, geography, estimate fields, total units, single-family units, multi-family units, valuation fields if needed
- File format plan: use `.csv` for prepared county permit data

## Exploration Results

- 2026-06-02: Confirmed the BPS main page says final annual 2025 estimates were released on 2026-05-14 and available by county.
- 2026-06-02: Confirmed the county ASCII index includes `co2025a.txt`, last modified on 2026-05-14.
- 2026-06-02: Downloaded and parsed `co2025a.txt`. Prepared file has 3,029 county rows and 16 columns.
- 2026-06-02: Top counties by total authorized units are Maricopa, Harris, Los Angeles, Collin, Miami-Dade, Travis, Clark, Tarrant, Wake, Montgomery, Lee, Orange, Dallas, Fort Bend, and San Diego.
- 2026-06-02: Miami-Dade has a much higher multi-family share among top counties, about 84%, while Maricopa and Harris are around 45%.
- 2026-06-02: Draft artifacts created: `top-county-building-permits.png` and `top-county-supply-mix.png`.

## Decision

- Decision: continue exploring
- Reason: supply is a timely housing angle and complements ACS affordability and Zillow market-trend explorations
- Next action: inspect the draft charts and decide whether these counties make the strongest tutorial comparison

## Promotion Notes

If promoted, record:

- target tutorial folder:
- final data format:
- transformations applied:
- source notes required:
- tutorial authoring guide concerns:
- tutorial proposal path:
