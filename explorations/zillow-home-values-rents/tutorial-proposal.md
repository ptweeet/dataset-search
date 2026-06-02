# Tutorial Proposal: Rent and Home Value Trends with Zillow Data

## Core Idea

Students create a short Quarto report comparing rent and home-value trends across selected U.S. metro areas using Zillow Research data.

The tutorial teaches students to reshape wide monthly data, interpret housing market indexes, and compare trends on a common indexed scale.

## Data Source

- Source: Zillow Research Data
- Vintage/date: live CSVs confirmed on 2026-06-02; raw files last modified on 2026-05-16
- Geography or unit: metro area by month
- License: Zillow data terms require review before promotion
- Prepared data:
  - `outputs/zillow_metro_rents_values_long.csv`
  - `outputs/zillow_metro_rents_values_indexed.csv`
  - `outputs/zillow_metro_latest_growth.csv`

## Main Measure Or Question

How have rents and home values changed across selected metro areas since 2020?

The tutorial can use January 2020 as a baseline:

```text
index value = current value / first 2020 value * 100
```

## Guiding Mystery

Austin has the lowest rent growth among the selected metros since January 2020, about 15%, but its home-value growth is about 28%. That gap is a useful mystery because many students may expect rents and home values to move together.

The tutorial can use this mystery to motivate the second section:

- Do rent and home-value indexes tell the same story?
- Which metros show the largest gaps between rent growth and home-value growth?
- What does indexing reveal that the original dollar values obscure?

A second possible mystery is Miami:

- Miami has the highest selected-metro rent growth, about 54%.
- Its home-value growth is similar, about 55%.
- Why does Miami look different from Austin?

## Proposed Tutorial Structure

Most tutorials should have two topic sections. Each section should create a concrete artifact.

### Introduction

Students set up `analysis.qmd`, load the prepared Zillow data, render, and inspect the data structure.

Key early points:

- Zillow Research publishes housing market indexes, not raw listings.
- Raw Zillow CSVs are wide: each monthly date is a column.
- The prepared tutorial data should be local because Zillow updates monthly and says CSV paths can change.

### Section 1: Rent Trends

Artifact: line chart of ZORI rent levels for selected metro areas.

Likely exercise path:

1. Inspect selected metro rows and monthly rent values.
2. Learn why wide monthly columns need to become long data for plotting.
3. Plot ZORI rents over time for selected metros.
4. Improve labels, dollar formatting, legend, and source caption.
5. Write a short interpretation of rent trends.

Pedagogical purpose:

- Students practice recognizing and reshaping time-series data.
- The line chart shows how rent levels differ across metros and change over time.

### Section 2: Rent Versus Home Value Growth

Artifact: indexed line chart comparing ZORI rent growth and ZHVI home-value growth.

Likely exercise path:

1. Join rent and home-value series by metro and month.
2. Index both measures to January 2020 = 100.
3. Plot indexed rent and home-value growth.
4. Compare growth patterns across selected metros.
5. Write a short interpretation without making forecasts or investment claims.

Pedagogical purpose:

- Indexing lets students compare measures with different dollar scales.
- The chart teaches that rents and home values are related but can move differently.

## File Format Notes

- Use `.csv` because the prepared data is non-spatial rectangular time-series data.
- Keep raw Zillow CSVs in the exploration only; ship reduced prepared files if promoted.

## Draft Artifacts

- Rent trend chart: `outputs/selected-metro-rent-trends.png`
- Indexed growth chart: `outputs/rent-vs-home-value-growth.png`

## Current Findings

- Official Metro ZHVI and ZORI CSV endpoints are live as of 2026-06-02.
- Zillow says data updates monthly and CSV paths can change.
- Exploration should freeze selected metro/date data before promotion.
- Prepared indexed data has 608 rows and 10 columns for eight selected geographies from January 2020 through April 2026.
- Miami has the highest selected-metro rent growth since January 2020, about 54%.
- Austin has the lowest selected-metro rent growth, about 15%, while its home-value growth is about 28%.
- Austin and Miami create a useful contrast: Austin has a large gap between home-value and rent growth, while Miami's rent and home-value growth are both high and similar.

## Knowledge Drop Opportunities

- Data/source context: Zillow Research publishes housing indexes used by analysts and journalists.
- Unit of observation: each prepared row is one metro-month.
- Variable meaning: ZORI is typical observed market rent; ZHVI is typical home value.
- Data quality issue: not all geographies have complete monthly coverage.
- Interpretation point: indexing to 100 makes growth comparable across measures with different units.
- Limitation or caveat: historical trends are not forecasts or investment advice.

## Why This Fits `misc.tutorials`

- Zillow is a prominent housing data source.
- Students learn real housing-market vocabulary.
- The tutorial produces two clear artifacts.
- The analysis path teaches a common data-science task: reshaping wide time-series data.

## Open Questions

- Which metro set should the final tutorial use?
- Should the first section use dollar rent levels or indexed rent growth?
- Should Zillow affordability metrics be considered instead of raw ZORI/ZHVI?
- What exact wording should we use around Zillow data terms and citation?
