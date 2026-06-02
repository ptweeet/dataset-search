# Tutorial Proposal: Local Health Patterns with CDC PLACES

## Core Idea

Students create a short Quarto report comparing county-level public health estimates from CDC PLACES.

The tutorial teaches students how to work with local public health estimates, rank counties carefully, and investigate whether related health measures tell the same story.

## Data Source

- Source: CDC PLACES
- Vintage/date: 2024 GIS-friendly county release explored; current data.cdc.gov metadata updated December 2025
- Geography or unit: county
- License: public domain
- Prepared data:
  - `outputs/cdc_places_county_health_selected.csv`
  - `outputs/top_county_obesity_places.csv`
  - `outputs/obesity_diabetes_rank_gaps.csv`

## Main Measure Or Question

Which counties have the highest estimated adult obesity prevalence, and do those counties also have the highest estimated diabetes prevalence?

Key measures:

```text
obesity = estimated percent of adults with obesity
diabetes = estimated percent of adults with diagnosed diabetes
```

## Guiding Mystery

Obesity and diabetes are related public health measures, so students may expect the same counties to rank high on both. But Lyon County, Minnesota and Coweta County, Georgia rank high for estimated obesity while ranking much lower for estimated diabetes.

The tutorial can use this mystery to motivate the second section:

- Which counties rank highest by obesity?
- Do those counties also rank highest by diabetes?
- Which counties sit above or below the overall obesity-diabetes pattern?
- What does a scatterplot reveal that a ranking does not?

## Proposed Tutorial Structure

Most tutorials should have two topic sections. Each section should create a concrete artifact.

### Introduction

Students set up `analysis.qmd`, load the prepared PLACES data, render, and inspect the selected measures.

Key early points:

- PLACES estimates are model-based small-area estimates.
- Each row is a county.
- County-level estimates describe places, not individuals.

### Section 1: Ranking County Health Estimates

Artifact: ranked bar chart of counties with the highest estimated adult obesity prevalence.

Likely exercise path:

1. Inspect the prepared county health data.
2. Confirm the unit of observation.
3. Rank counties by estimated adult obesity prevalence.
4. Create a bar chart of the top counties.
5. Improve labels, percent formatting, subtitle, and source caption.
6. Write a short interpretation of what the ranking does and does not show.

Pedagogical purpose:

- Students learn to work with county-level public health estimates.
- The chart establishes the first version of the public health story: one measure, ranked.

### Section 2: Comparing Related Health Measures

Artifact: scatterplot comparing estimated obesity and diagnosed diabetes prevalence.

Likely exercise path:

1. Compare obesity and diabetes estimates.
2. Plot county obesity against diabetes.
3. Add a trend line.
4. Identify counties above or below the overall pattern.
5. Write a short interpretation that avoids individual-level or causal claims.

Pedagogical purpose:

- Students learn that related measures can move together without being identical.
- The second artifact resolves the mystery by showing pattern and exceptions.

## File Format Notes

- Use `.csv` because the prepared data is non-spatial rectangular county data.
- Use `.rds` only if a later map-ready spatial file is added.

## Draft Artifacts

- Ranked bar chart: `outputs/top-county-obesity-places.png`
- Scatterplot: `outputs/obesity-vs-diabetes-places.png`

## Current Findings

- Prepared extract has 3,144 county rows and 13 selected fields.
- Holmes County, Mississippi has the highest estimated adult obesity prevalence in the focused extract.
- Among counties with at least 10,000 adults, top obesity counties include Holmes County, MS; Phillips County, AR; Dallas County, AL; Meigs County, OH; and Lee County, SC.
- Lyon County, MN and Coweta County, GA rank high for obesity but much lower for diabetes, making them useful cases for the guiding mystery.

## Knowledge Drop Opportunities

- Data/source context: PLACES provides local public health estimates across counties and other geographies.
- Unit of observation: each prepared row is one county.
- Variable meaning: crude prevalence is an estimated percent of adults in the county.
- Data quality issue: estimates are model-based small-area estimates, not direct county survey counts.
- Interpretation point: rankings and scatterplots answer different questions.
- Limitation or caveat: county-level patterns are ecological and should not be treated as individual-level causal claims.

## Why This Fits `misc.tutorials`

- CDC PLACES is a prominent public health data source.
- The dataset has clear domain vocabulary students should know.
- The tutorial produces two clear artifacts.
- The guiding mystery naturally motivates the second visualization.

## Open Questions

- Should the final tutorial use obesity and diabetes, or another pair of measures?
- Should we add a map as a later version?
- Should the tutorial filter out very small counties?
