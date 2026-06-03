# Tutorial Proposal: When Are Americans Born?

## Core Idea

Students use the US daily birth data from the `fivethirtyeight` package to build a calendar heatmap and investigate why certain days have dramatically fewer births than others. The tutorial starts with a visually striking artifact — a tile map of 20 years of birth counts — and then sends students on a two-step investigation: first to quantify the Christmas dip, and then to ask whether the dip is growing over time. That second question trips a surprise: Christmas falls on different weekdays each year, so a naive year-over-year comparison is confounded by the day-of-week effect. Untangling that confound reveals the mechanism — scheduled deliveries let American families opt out of inconvenient dates — and explains why both the holiday dip and the weekend dip exist and are growing together.

The analysis uses AI to explore and explain. Students direct AI to combine two datasets correctly, compute summaries, build the heatmap, and then investigate a pattern they choose to interrogate further. The result is a Quarto report with two polished visualizations and a short interpretation that connects the data to a real social trend.

## Source Graphic

- Graphic: "Some People Are Too Superstitious to Have a Baby on Friday the 13th" — FiveThirtyEight
- URL: https://fivethirtyeight.com/features/some-people-are-too-superstitious-to-have-a-baby-on-friday-the-13th/
- What was cool about it: a `geom_tile` calendar heatmap of 20 years of US births that makes the entire annual rhythm of birth timing visible at a glance — September lights up, holidays go dark
- Mystery it raised: why has the Christmas dip grown deeper over the decades, even though the holiday itself hasn't changed?

## Data Source

- Source: `fivethirtyeight` R package (`US_births_1994_2003`, `US_births_2000_2014`)
- GitHub CSV backup: https://github.com/fivethirtyeight/data/tree/master/births
- Vintage/date: 1994–2014
- Geography or unit: United States; one row per calendar day
- License: CC-BY
- Prepared data:
  - `outputs/births_prepared.rds` (7,670 rows × 5 columns, ~19 KB)
  - `outputs/births_prepared.csv`

## Main Measure or Question

```text
For each calendar day (month × day_of_month), what is the average number of US births
across all years — and how does that average vary by day of week and over time?
```

## Guiding Mystery

- What result should make students curious? The calendar heatmap reveals that Dec 25 averages only 6,601 births — barely 55% of the ~12,000 typical on surrounding days. The five darkest days in the entire calendar are all holidays or holiday eves.
- What first guess might be incomplete? "People schedule around holidays" feels like the full story. But then students notice that *every* Saturday and Sunday also shows a large dip — about 40% fewer births than Tuesday — regardless of any holiday. The holiday effect and the weekend effect look identical in kind.
- How will the tutorial's artifacts help resolve the mystery? The second section asks whether the Christmas dip has grown. A naive year-over-year plot looks noisy. Students discover that Christmas falls on different weekdays each year — a Sunday Christmas (2011: 5,728 births) looks much worse than a Tuesday Christmas just from the day-of-week effect. Controlling for weekday reveals the real trend: same-weekday Christmases have consistently deeper dips in the 2000s and 2010s than in the 1990s.
- What interpretation exercise should the mystery lead to? Students connect the deepening dip to the documented rise in scheduled deliveries (C-sections and inductions climbed from ~20% to ~32% of US births 1994–2014). The calendar is a record of families gaining control over birth timing.

## Proposed Tutorial Structure

### Introduction

Students load and combine two birth datasets from the `fivethirtyeight` package, handling the 2000–2003 overlap with a filter. They inspect the structure — 7,670 rows, one per calendar day — and notice that `day_of_week` is an ordered factor, not a number.

Key early points:
- The two datasets cover different years and must be combined without double-counting
- `day_of_week` is a factor with levels Sun, Mon, Tues, Wed, Thurs, Fri, Sat — use it as a category
- The unit of observation is one calendar day; `births` is the total registered live births on that day

### Section 1: The Birth Calendar

Artifact: a calendar heatmap — `geom_tile` with month on the y-axis, day of month on the x-axis, fill = mean births across all years.

Likely exercise path:

1. Compute average births grouped by `month` and `date_of_month`
2. Plot the heatmap with `geom_tile`, reverse the y-axis so January is at the top
3. Apply a diverging or sequential fill scale; add month labels on the y-axis
4. Describe what the heatmap shows — name the September cluster, name the holiday notches
5. Identify the five darkest individual cells and what dates they correspond to

Pedagogical purpose:
- `geom_tile` on a two-variable grid is a natural extension of what students know about `geom_col` and `geom_point`
- The heatmap makes a genuinely surprising pattern visible at a glance — the September cluster and holiday dips are not things most students would predict before seeing the data

### Section 2: Unpacking the Holiday Dip

Artifact: a line/point chart of Dec 25 births as a percentage of the surrounding-December-day baseline, by year, with points colored or shaped by the weekday Christmas fell on.

Likely exercise path:

1. Compute the average births on Dec 25 and compare it to the surrounding-day baseline (Dec 20–24, Dec 27–30); state the deficit
2. Plot Dec 25 `pct_of_baseline` by year as a simple line chart — notice it looks noisy, not a clean trend
3. Color the points by `day_of_week` — immediately see that Sunday and Saturday years are the lowest
4. Reframe the question: within the same weekday, is the dip growing?
5. Summarize or annotate a few same-weekday comparisons (e.g., Sunday 1994 vs. 2005 vs. 2011: 63% → 49% → 48%)
6. Write a short interpretation: what changed between 1994 and 2014 that made families more able to avoid Dec 25?

Pedagogical purpose:
- The confound (day of week) is discovered through the data, not told to students in advance
- The "fix" (color by weekday, or filter to same weekday) is simple and satisfying
- The mechanism (scheduled deliveries) is a real social fact that the data encodes — students read causation from a pattern, which is exactly what data science is for

## File Format Notes

- Tutorial reads `births_prepared.rds` from a local `data/` folder — no package dependency at render time
- The `.rds` file is ~19 KB; trivially small for bundling with a tutorial package
- The `fivethirtyeight` package can be cited as the source without requiring students to install it

## Draft Artifacts

- Section 1: calendar heatmap (`births-heatmap.png`)
- Section 2: Dec 25 pct_of_baseline over time, colored by weekday (`christmas-dip-over-time.png` — current version needs weekday coloring added)

## Current Findings

- Dec 25 overall mean: 6,601 births (55% of surrounding-day baseline)
- Tuesday peak: 12,842 mean births; Sunday trough: 7,635 — a 40% gap
- Same-weekday Sunday comparison: 63% (1994) → 49% (2005) → 48% (2011) of baseline
- Same-weekday Saturday comparison: 57% (1999) → 50% (2004) → 50% (2010) of baseline
- Friday the 13th: 11,744 mean births vs. 12,349 on a typical Friday — about 5% lower
- Minimum single day: 5,728 (Dec 25, 2011 — Sunday)
- Maximum single day: 16,081 (Sep 9, 2009 — Wednesday)

## Knowledge Drop Opportunities

- Data/source context: the CDC and SSA datasets overlap 2000–2003; combine with care to avoid double-counting — this is a real data-provenance issue, not just a technicality
- Unit of observation: one row = one calendar day; births is registered live births that day, not necessarily born that day (registration lag exists but is small)
- Variable meaning: `day_of_week` is an ordered factor — its levels encode a category, not a numeric rank; `scale_x_continuous()` will error if you treat it like a number
- Interpretation point: the weekend dip and the holiday dip share the same mechanism — scheduled deliveries; once you see this, the heatmap reads as a map of social behavior embedded in biology
- Interpretation point: the deepening dip reflects the documented national rise in C-sections and inductions — from ~20% of US births in the early 1990s to ~32% by the 2010s
- Limitation or caveat: data ends in 2014; the scheduled-delivery trend has continued since then, so the current Christmas dip is likely even deeper than this dataset shows

## Why This Fits `misc.tutorials`

- Data loads from a package in one line; no API key, no download during render
- 7,670 rows fits easily in a tutorial bundle at 19 KB
- The mystery is two-layered: the first question (what's the pattern?) is answered by the heatmap; the second question (why is the dip growing?) requires a second plot and a conceptual move — that's exactly the right depth for a two-section tutorial
- The topic is universally relatable — every student has a birthday

## Open Questions

- Should the Section 2 artifact color points by weekday in the polished version, or use small multiples? Coloring is simpler; small multiples are cleaner but add visual complexity.
- Is Friday the 13th worth including as a sidebar or knowledge drop, or does it distract from the main thread? Probably a knowledge drop rather than a full exercise.
- Should the tutorial use `day_of_week` as-is (ordered factor with abbreviated labels like "Tues"), or recode it to standard abbreviations ("Tue") for cleaner plot labels?
- The `date` column in the raw data is redundant (derivable from year/month/date_of_month); confirm it can be dropped from the prepared file without loss.
