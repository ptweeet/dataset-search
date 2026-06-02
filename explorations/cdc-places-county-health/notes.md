# Dataset Notes: CDC PLACES County Health Measures

## Summary

- Slug: cdc-places-county-health
- Status: exploring
- Source: https://www.cdc.gov/places/
- License: Public domain
- Domain: public health
- File format: CDC Socrata API during exploration; prepared `.csv`/`.rds` for tutorial use
- Size: focused extract is small; full GIS-friendly county file has about 3,144 rows and 167 columns
- Local files:
  - `outputs/raw/cdc_places_county_selected_raw.csv`
  - `outputs/cdc_places_county_health_selected.csv`
  - `outputs/cdc_places_county_health_selected.rds`
  - `outputs/top_county_obesity_places.csv`
  - `outputs/obesity_diabetes_rank_gaps.csv`
  - `outputs/obesity_inactivity_rank_gaps.csv`
  - `outputs/obesity_smoking_rank_gaps.csv`
  - `outputs/obesity_measure_correlations.csv`
  - `outputs/pairwise_health_measure_correlations.csv`
  - `outputs/top_counties_by_health_measure.csv`
  - `outputs/interesting_counties.csv`
  - `outputs/selected_county_health_profiles.csv`
  - `outputs/top_obesity_county_health_profile.csv`
  - `outputs/top-counties-by-health-measure.png`
  - `outputs/top-county-obesity-places.png`
  - `outputs/obesity-vs-diabetes-places.png`
  - `outputs/obesity-vs-physical-inactivity-places.png`
  - `outputs/obesity-vs-smoking-places.png`
  - `outputs/selected-county-health-profiles.png`
  - `outputs/top-obesity-county-health-profile.png`

## Why This Might Make a Good Tutorial

- Potential learner audience: students interested in county-level public health patterns
- Main learning goal: use official local public health estimates to compare counties
- Supporting concepts: modeled estimates, county geography, prevalence, rankings, bivariate comparison, multi-measure profiles, ecological interpretation
- Possible tutorial title: Local Health Patterns with CDC PLACES

## Questions The Dataset Can Answer

1. Which counties have the highest estimated prevalence for obesity, diabetes, current smoking, and physical inactivity?
2. Do the same counties stand out across several measures, or do the top lists change?
3. What changes when students compare selected counties across several related public health measures instead of using one ranking?

## Guiding Mystery

- Surprising pattern: obesity, physical inactivity, smoking, and diabetes are all related, but they are not interchangeable. Some high-obesity counties look high across every measure, while others have more uneven profiles.
- Why the first guess may be incomplete: students may expect obesity, smoking, diabetes, and physical inactivity to move together everywhere, but local estimates can diverge.
- Follow-up table, plot, map, or comparison needed: faceted top-county rankings, a pairwise correlation table, and a final selected-county profile chart.
- Interpretation exercise this could support: explain why one public health ranking can start an investigation but cannot summarize a county's whole health profile.

## Data Inspection

- Number of rows: 3,144 county rows
- Number of columns: 13 selected fields
- Key variables: county FIPS, state, county name, total population, obesity, diabetes, smoking, physical inactivity, poor mental health, food insecurity
- Missing data: no missing values for obesity, diabetes, or physical inactivity in the focused extract; food insecurity has some missing values
- Surprising values: Holmes County, Mississippi has the highest obesity estimate in the focused extract, while Coweta County, Georgia and Lyon County, Minnesota have high obesity but much lower physical inactivity rankings
- Required cleaning: select focused measures, rename fields, create GEOID/county label, calculate rankings

## Source Notes

CDC PLACES provides model-based local estimates for counties, places, census tracts, and ZIP Code Tabulation Areas. CDC describes PLACES as a tool for local data on chronic disease, health outcomes, preventive services, risk behaviors, disabilities, health status, and health-related social needs.

Important interpretation point: PLACES values are estimates for geographic areas. They should not be interpreted as direct survey counts or as claims about every individual in a county.

Candidate API endpoint:

```text
https://data.cdc.gov/resource/d3i6-k6z5.csv
```

## Teaching Fit

- Beginner friendliness: high if we select a small measure set
- Interestingness: high; local public health comparisons are recognizable and meaningful
- Stability: high for a frozen release
- Package size impact: low after selecting focused columns
- Maintenance risk: low with prepared files; moderate if querying current Socrata endpoints live
- Ethics/privacy concerns: moderate; avoid stigmatizing counties or making individual-level claims from county estimates

## Tutorial Fit

- Target learner: students learning to use AI to explore public health estimates and evaluate what they support
- Possible final Quarto artifact: a two-section report comparing measure-specific county rankings and selected county health profiles
- Main result about the world: local health measures are related, but one ranking does not summarize the full public health profile of a place
- Why this belongs in `misc.tutorials`: CDC PLACES is a prominent official data source for local public health work

### Possible Exercise Path

1. Get local prepared PLACES data into the project.
2. Inspect county identifiers and selected health measures.
3. Rank counties by obesity, diabetes, current smoking, and physical inactivity.
4. Produce the first artifact: faceted ranked chart of top counties by measure.
5. Interpret what modeled county estimates do and do not mean.
6. Compare all six pairwise relationships among obesity, diabetes, current smoking, and physical inactivity.
7. Select interesting counties using top rankings and rank-gap checks.
8. Produce the second artifact: grouped bar chart showing selected county health profiles.
9. Interpret how related measures can cluster while still telling different local stories.

### Rendered Outputs Students Could Inspect

- Printed tibble: selected county health measures
- Summary statistics: ranges for selected prevalence measures
- Plot: faceted ranked chart for several health measures
- Table: pairwise correlations among selected health measures
- Plot: grouped bar chart comparing selected county profiles
- Optional plot: scatterplot comparing two related measures
- Final page element: short interpretation paragraph with source caption

### Knowledge Drop Candidates

Use these for short teaching notes after exercises. They should be about the data, the domain, the rendered output, or a key point from a companion text.

- Data/source context: PLACES provides local public health estimates across counties and other geographies
- Unit of observation: each prepared row is a county
- Variable meaning: crude prevalence is the estimated percent of adults in the county with a given measure
- Data quality issue: PLACES estimates are model-based small-area estimates
- Interpretation point: county-level relationships are ecological patterns, not individual-level causal claims
- Limitation or caveat: rankings can overemphasize small differences between similar estimates

### Reproducibility Plan

- Can `analysis.qmd` read local data without downloading during render? yes, after exploration creates prepared files
- Where should source copies or prepared data live? likely `inst/extdata/<tutorial>/` in `misc.tutorials`
- What source URL comment should appear near the data-reading code? Source: CDC PLACES, https://www.cdc.gov/places/
- What data reduction or transformation is needed before promotion? select release, columns, measures, and whether to include county geometry
- File format plan: use `.csv` for non-spatial data; use `.rds` if a map-ready spatial file is added

## Exploration Results

- 2026-06-02: Confirmed current CDC PLACES county GIS-friendly data are available on data.cdc.gov. The 2025 release exists, and the 2024 release page lists public domain licensing and about 3,144 county rows.
- 2026-06-02: Queried selected fields from the CDC PLACES county GIS-friendly endpoint. Prepared extract has 3,144 county rows and 13 selected fields.
- 2026-06-02: Highest obesity counties among counties with at least 10,000 adults include Holmes County, MS; Phillips County, AR; Dallas County, AL; Meigs County, OH; and Lee County, SC.
- 2026-06-02: Lyon County, MN and Coweta County, GA create a useful rank-gap mystery: they rank high for obesity but much lower for diabetes.
- 2026-06-02: Draft artifacts created: `top-county-obesity-places.png` and `obesity-vs-diabetes-places.png`.
- 2026-06-02: Compared obesity with diagnosed diabetes, current smoking, and physical inactivity. Among counties with at least 10,000 adults, physical inactivity had the strongest correlation with obesity (`r = 0.750`), followed by current smoking (`r = 0.718`) and diabetes (`r = 0.685`).
- 2026-06-02: Physical inactivity creates the clearest tutorial mystery: Coweta County, GA ranks 91st for obesity but 1,828th for physical inactivity, and Lyon County, MN ranks 56th for obesity but 1,789th for physical inactivity.
- 2026-06-02: Draft comparison artifacts created: `obesity-vs-physical-inactivity-places.png`, `obesity-vs-smoking-places.png`, `obesity_inactivity_rank_gaps.csv`, `obesity_smoking_rank_gaps.csv`, and `obesity_measure_correlations.csv`.
- 2026-06-02: Added final profile artifact: `top-obesity-county-health-profile.png`. The stronger tutorial message is that related public health measures cluster, but each county has a profile rather than a single story.
- 2026-06-02: Expanded Section 1 to rank counties separately for obesity, diabetes, current smoking, and physical inactivity. Added `top-counties-by-health-measure.png`.
- 2026-06-02: Added all six pairwise correlations. The strongest pair is diabetes and physical inactivity (`r = 0.858`), followed by current smoking and physical inactivity (`r = 0.837`).
- 2026-06-02: Added selected-county final artifact: `selected-county-health-profiles.png`. Counties are selected because they stand out in different rankings or rank-gap checks.

## Decision

- Decision: continue exploring
- Reason: strong fit for local public health data, guiding mysteries, and careful interpretation
- Next action: treat `top-counties-by-health-measure.png` as the Section 1 artifact and `selected-county-health-profiles.png` as the likely final Section 2 artifact

## Promotion Notes

If promoted, record:

- target tutorial folder:
- final data format:
- transformations applied:
- source notes required:
- tutorial authoring guide concerns:
- tutorial proposal path:
