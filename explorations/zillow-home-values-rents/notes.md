# Dataset Notes: Zillow Home Values and Rents

## Summary

- Slug: zillow-home-values-rents
- Status: exploring
- Source: https://www.zillow.com/research/data/
- License: Zillow data terms require review before promotion
- Domain: housing
- File format: Zillow CSV during exploration; prepared `.csv`/`.rds` for tutorial use
- Size: raw Metro ZHVI is about 4.2 MB; raw Metro ZORI is about 986 KB; prepared indexed file is 608 rows x 10 columns
- Local files:
  - `outputs/raw/zillow_metro_zhvi.csv`
  - `outputs/raw/zillow_metro_zori.csv`
  - `outputs/zillow_metro_rents_values_long.csv`
  - `outputs/zillow_metro_rents_values_indexed.csv`
  - `outputs/zillow_metro_rents_values_indexed.rds`
  - `outputs/zillow_metro_latest_growth.csv`
  - `outputs/selected-metro-rent-trends.png`
  - `outputs/rent-vs-home-value-growth.png`

## Why This Might Make a Good Tutorial

- Potential learner audience: students interested in local housing market trends
- Main learning goal: compare rent and home-value changes over time using Zillow Research data
- Supporting concepts: time series, wide-to-long reshaping, index measures, percent change, metro geography
- Possible tutorial title: Rent and Home Value Trends with Zillow Data

## Questions The Dataset Can Answer

1. How have rents changed across selected metro areas since 2020?
2. Did rents and home values move together in the same metros?
3. Which metro had the largest gap between rent growth and home-value growth?

## Data Inspection

- Number of rows: 608 prepared metro-month rows after filtering to selected metros and dates from 2020 onward
- Number of columns: 10 in the indexed prepared file
- Key variables: `RegionName`, `RegionType`, `StateName`, monthly ZORI values, monthly ZHVI values
- Missing data: none in the joined selected-metro data from January 2020 through April 2026
- Surprising values: Miami has the largest rent growth among selected metros, while Austin has the lowest rent growth despite substantial home-value growth
- Required cleaning: choose metros, reshape monthly columns, join ZORI and ZHVI, index both series to a baseline

## Source Notes

Zillow Research says CSV download paths change occasionally and data is updated on the 16th of each month. For a tutorial, freeze prepared teaching data locally rather than depending on live downloads during render.

Official source concepts:

- ZHVI is Zillow's measure of typical home value for a region.
- ZORI is Zillow's smoothed measure of typical observed market-rate rent.
- ZORI is dollar-denominated and weighted to the rental housing stock.

Candidate raw files:

- ZHVI, Metro, all homes, smoothed and seasonally adjusted: `https://files.zillowstatic.com/research/public_csvs/zhvi/Metro_zhvi_uc_sfrcondo_tier_0.33_0.67_sm_sa_month.csv`
- ZORI, Metro, all homes plus multifamily, smoothed: `https://files.zillowstatic.com/research/public_csvs/zori/Metro_zori_uc_sfrcondomfr_sm_month.csv`

## Teaching Fit

- Beginner friendliness: medium; wide monthly columns require reshaping
- Interestingness: high; students recognize rent and home prices
- Stability: moderate; data updates monthly and paths can change
- Package size impact: likely low after filtering to selected metros and dates
- Maintenance risk: moderate unless prepared files are frozen
- Ethics/privacy concerns: low for aggregate metro indexes; avoid investment or forecasting advice

## Tutorial Fit

- Target learner: students learning to use AI to reshape and visualize time-series housing data
- Possible final Quarto artifact: a two-section report comparing rent trends and rent-vs-home-value growth across selected metros
- Main result about the world: housing market trends differ by metro, and rents and home values do not always move together
- Why this belongs in `misc.tutorials`: Zillow Research is a prominent housing data source with domain-specific vocabulary analysts should know

### Possible Exercise Path

1. Get local prepared Zillow data into the project.
2. Inspect geography fields and monthly columns.
3. Reshape ZORI from wide to long.
4. Produce the first artifact: line chart of rent trends across selected metros.
5. Interpret rent trends.
6. Join ZORI and ZHVI for the same selected metros.
7. Index both series to a common baseline such as January 2020 = 100.
8. Produce the second artifact: line chart comparing rent growth and home-value growth.
9. Interpret the comparison and avoid forecasting claims.

### Rendered Outputs Students Could Inspect

- Printed tibble: selected metro rows before reshaping
- Printed tibble: long-format time-series data
- Plot: line chart of ZORI rent levels over time
- Plot: indexed line chart comparing ZORI and ZHVI growth
- Final page element: short interpretation paragraph with source caption

### Knowledge Drop Candidates

Use these for short teaching notes after exercises. They should be about the data, the domain, the rendered output, or a key point from a companion text.

- Data/source context: Zillow Research publishes housing market indexes that update monthly
- Unit of observation: each row in the raw file is a geography; each date column is a monthly value
- Variable meaning: ZORI measures typical observed market-rate rent; ZHVI measures typical home value
- Data quality issue: not every metro has complete data for every month
- Interpretation point: indexing to 100 makes growth comparable even when rent and home values use different dollar scales
- Limitation or caveat: trend comparisons describe historical changes, not forecasts or investment advice

### Reproducibility Plan

- Can `analysis.qmd` read local data without downloading during render? yes, after exploration creates prepared files
- Where should source copies or prepared data live? likely `inst/extdata/<tutorial>/` in `misc.tutorials`
- What source URL comment should appear near the data-reading code? Source: Zillow Research Data, https://www.zillow.com/research/data/
- What data reduction or transformation is needed before promotion? filter metros, choose date range, reshape to long format, and calculate indexed growth
- File format plan: use `.csv` for prepared non-spatial time-series data

## Exploration Results

- 2026-06-02: Confirmed official Metro ZHVI and ZORI CSV endpoints are live. Both raw files were last modified on 2026-05-16.
- 2026-06-02: Downloaded raw Metro ZHVI and ZORI files, filtered to eight selected geographies, and prepared joined/indexed data for January 2020 through April 2026.
- 2026-06-02: Prepared indexed data has 608 rows and 10 columns, with no missing ZORI or ZHVI values.
- 2026-06-02: Latest selected-metro rent growth since January 2020 ranks Miami highest at about 54%, followed by the United States overall, Phoenix, New York, Boston, Denver, San Francisco, and Austin.
- 2026-06-02: Draft artifacts created: `selected-metro-rent-trends.png` and `rent-vs-home-value-growth.png`.

## Decision

- Decision: continue exploring
- Reason: strong student interest and clear fit for time-series reshaping and interpretation
- Next action: inspect draft charts and decide whether the selected metros make the strongest tutorial story

## Promotion Notes

If promoted, record:

- target tutorial folder:
- final data format:
- transformations applied:
- source notes required:
- tutorial authoring guide concerns:
- tutorial proposal path:
