# Tutorial Proposal: Local Health Patterns with CDC PLACES

## Core Idea

Students create a short Quarto report comparing county-level public health estimates from CDC PLACES.

The tutorial teaches students how to work with local public health estimates, rank counties carefully, and investigate why related health measures should be compared as a profile rather than treated as interchangeable.

## Data Source

- Source: CDC PLACES
- Vintage/date: 2024 GIS-friendly county release explored; current data.cdc.gov metadata updated December 2025
- Geography or unit: county
- License: public domain
- Prepared data:
  - `outputs/cdc_places_county_health_selected.csv`
  - `outputs/top_counties_by_health_measure.csv`
  - `outputs/top_county_obesity_places.csv`
  - `outputs/pairwise_health_measure_correlations.csv`
  - `outputs/interesting_counties.csv`
  - `outputs/selected_county_health_profiles.csv`
  - `outputs/obesity_inactivity_rank_gaps.csv`
  - `outputs/obesity_smoking_rank_gaps.csv`
  - `outputs/obesity_measure_correlations.csv`
  - `outputs/top_obesity_county_health_profile.csv`

## Main Measure Or Question

Which counties stand out for obesity, diabetes, current smoking, and physical inactivity, and what do we learn when we compare selected counties across those measures?

Key measures:

```text
obesity = estimated percent of adults with obesity
diabetes = estimated percent of adults with diagnosed diabetes
current_smoking = estimated percent of adults who currently smoke
physical_inactivity = estimated percent of adults reporting no leisure-time physical activity
```

## Guiding Mystery

Obesity, diabetes, current smoking, and physical inactivity are related public health measures. Students may expect counties with high obesity to rank high across all of them. The correlations are similar enough that choosing one "best" comparison is less interesting than asking how the measures line up together.

The emerging story is that there is no single list of "the" counties that stand out. Some counties appear high across several measures, while others are high for one measure but less extreme for another.

The tutorial can use this mystery to motivate the second section:

- Which counties rank highest by each measure?
- Do the same counties appear across the obesity, diabetes, smoking, and physical inactivity lists?
- Which counties have similar obesity rankings but different public health profiles?
- What does a selected-county profile chart reveal that a single ranking or correlation table does not?

## Proposed Tutorial Structure

Most tutorials should have two topic sections. Each section should create a concrete artifact.

### Introduction

Students set up `analysis.qmd`, load the prepared PLACES data, render, and inspect the selected measures.

Key early points:

- PLACES estimates are model-based small-area estimates.
- Each row is a county.
- County-level estimates describe places, not individuals.

### Section 1: Finding Standout Counties

Artifact: faceted ranked bar chart showing top counties for obesity, diabetes, current smoking, and physical inactivity.

Likely exercise path:

1. Inspect the prepared county health data.
2. Confirm the unit of observation.
3. Reshape the four health measures into a long format.
4. Rank counties separately within each measure.
5. Create a faceted bar chart of the top counties by measure.
6. Compare which counties appear in more than one panel.
7. Write a short interpretation of what a ranking does and does not show.

Pedagogical purpose:

- Students learn to work with county-level public health estimates.
- The chart establishes the first version of the public health story: counties can stand out for different reasons depending on the measure.

### Section 2: Building County Health Profiles

Artifact: grouped bar chart comparing selected interesting counties across the four measures.

Likely exercise path:

1. Calculate all six pairwise correlations among the four measures.
2. Read the correlation table as an exploratory summary.
3. Use top rankings and rank-gap checks to select a small set of interesting counties.
4. Reshape the selected counties into a long profile table.
5. Create a grouped bar chart showing prevalence across all four measures.
6. Write a short interpretation that avoids individual-level or causal claims.

Pedagogical purpose:

- Students learn that related measures can move together without being identical.
- The second artifact resolves the mystery by showing that a county has a multi-measure profile, not a single public health story.

Standout county rules:

- Section 1: a county stands out if it has one of the highest prevalence estimates for a specific measure.
- Section 2: a county stands out if it has an interesting profile, such as high values across several measures, high obesity but lower related measures, high physical inactivity but lower smoking, or a large rank gap between related measures.

## File Format Notes

- Use `.csv` because the prepared data is non-spatial rectangular county data.
- Use `.rds` only if a later map-ready spatial file is added.

## Draft Artifacts

- Section 1 ranked chart: `outputs/top-counties-by-health-measure.png`
- Final selected-county profile chart: `outputs/selected-county-health-profiles.png`
- Pairwise correlation table: `outputs/pairwise_health_measure_correlations.csv`
- Selection table: `outputs/interesting_counties.csv`
- Earlier obesity-only chart: `outputs/top-county-obesity-places.png`
- Earlier heatmap-style profile chart: `outputs/top-obesity-county-health-profile.png`
- Exploratory scatterplots: `outputs/obesity-vs-physical-inactivity-places.png`, `outputs/obesity-vs-diabetes-places.png`, and `outputs/obesity-vs-smoking-places.png`

## Current Findings

- Prepared extract has 3,144 county rows and 13 selected fields.
- Holmes County, Mississippi has the highest estimated adult obesity prevalence in the focused extract.
- Among counties with at least 10,000 adults, top obesity counties include Holmes County, MS; Phillips County, AR; Dallas County, AL; Meigs County, OH; and Lee County, SC.
- The top-county lists change by measure. For example, Bethel, AK is highest for current smoking, while Phillips County, AR is highest for physical inactivity.
- Among counties with at least 10,000 adults, obesity is most strongly correlated with physical inactivity (`r = 0.750`), followed by current smoking (`r = 0.718`) and diagnosed diabetes (`r = 0.685`).
- Across all six pairwise comparisons, diabetes and physical inactivity have the strongest correlation (`r = 0.858`), followed by current smoking and physical inactivity (`r = 0.837`).
- The correlations are close enough that the most compelling lesson is not which one is highest, but that each comparison reveals a different part of the county profile.
- Coweta County, GA ranks 91st for obesity but 1,828th for physical inactivity, and Lyon County, MN ranks 56th for obesity but 1,789th for physical inactivity. These counties are useful examples of divergence.
- The selected-county grouped bar chart makes the broader conclusion visible: counties can stand out in different rankings and still have distinct profiles across diabetes, smoking, obesity, and physical inactivity.

## Knowledge Drop Opportunities

- Data/source context: PLACES provides local public health estimates across counties and other geographies.
- Unit of observation: each prepared row is one county.
- Variable meaning: crude prevalence is an estimated percent of adults in the county.
- Data quality issue: estimates are model-based small-area estimates, not direct county survey counts.
- Interpretation point: rankings and scatterplots answer different questions.
- Visualization point: a grouped profile chart can compare several measures at once after students understand rankings and correlations.
- Limitation or caveat: county-level patterns are ecological and should not be treated as individual-level causal claims.

## Why This Fits `misc.tutorials`

- CDC PLACES is a prominent public health data source.
- The dataset has clear domain vocabulary students should know.
- The tutorial produces two clear artifacts.
- The guiding mystery naturally motivates a final chart that synthesizes several rankings and comparisons.

## Open Questions

- Should the final selected-county chart use 6, 8, or 9 counties?
- Should we add a map as a later version?
- Should the tutorial filter out very small counties?
