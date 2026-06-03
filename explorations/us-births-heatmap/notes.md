# Dataset Notes: US Daily Births Heatmap

## Summary

- Slug: us-births-heatmap
- Status: exploring
- Source graphic: us-births-heatmap (graphics.yml)
- Found via: graphic-first
- Source: fivethirtyeight R package (`US_births_1994_2003`, `US_births_2000_2014`); GitHub CSV backup at https://github.com/fivethirtyeight/data/tree/master/births
- License: CC-BY
- Domain: social behavior / health
- File format: R package (instant load), CSV backup
- Size: 7,670 rows × 6 columns after combining (1994–2014, one row per calendar day)
- Local files: `outputs/births_prepared.rds`, `outputs/births_prepared.csv`

## Why This Might Make a Good Tutorial

- Potential learner audience: any intro R student; the topic (birthdays) is universally relatable
- Main learning goal: create a calendar heatmap with `geom_tile`, then investigate a pattern through a second comparison
- Supporting concepts: grouped summaries, `bind_rows`, ordered factors, controlling for a confound
- Possible tutorial title: "When Are Americans Born? Holidays, Weekends, and the Scheduled Delivery"

## Questions The Dataset Can Answer

1. What is the shape of the US birth calendar — which days and months have the most and fewest births?
2. How large is the holiday dip on Dec 25, and what does the surrounding week look like?
3. Has the holiday dip grown over time, and why does the answer require controlling for day of week?

## Guiding Mystery

- Surprising pattern: Dec 25, 2011 (Sunday) had only 5,728 births — the lowest single day in 20 years. Christmas Day overall averages 6,601 births, only 55% of the surrounding-day baseline of ~12,000.
- Why the first guess may be incomplete: "People just avoid scheduling deliveries on Christmas" feels like the full answer — but then you notice the same dip on Dec 24, New Year's Day, and also *every* Saturday and Sunday regardless of holidays. Weekends average ~7,600–8,600 births vs. ~12,600 on a Tuesday. The holiday and the weekend effect are tangled.
- Follow-up comparison needed: To see whether the dip is *growing* over time, you need to compare like weekdays across years (e.g., Dec 25 on a Sunday in 1994, 2005, and 2011). Doing so reveals the trend is real: Sunday Christmases went from 63% of baseline → 49% → 48%. The day-of-week confound is the mechanism reveal: scheduled deliveries are how families actually opt out.
- Interpretation exercise: What does the growing dip tell us about how birth timing has changed? Scheduled deliveries (C-sections and inductions) climbed from ~20% of births in the 1990s to ~32% by the 2010s — giving more families the ability to choose (and avoid) any given date.

## Data Inspection

- Number of rows: 7,670 (1994–2014, with 1994–1999 from the CDC dataset and 2000–2014 from the SSA dataset)
- Number of columns: 6 (year, month, date_of_month, date, day_of_week, births)
- Key variables:
  - `year`, `month`, `date_of_month`: calendar position
  - `day_of_week`: ordered factor — levels are Sun, Mon, Tues, Wed, Thurs, Fri, Sat
  - `births`: integer count of births on that calendar day
- Missing data: none observed
- Surprising values:
  - Min: 5,728 (Dec 25, 2011 — Sunday)
  - Max: 16,081 (Sep 9, 2009 — Wednesday)
  - Tuesday is the peak weekday at 12,842 mean births; Sunday the trough at 7,635 — a 40% gap driven entirely by scheduled deliveries
- Required cleaning: combine the two datasets with `bind_rows(filter(year < 2000), dataset_2)` to avoid double-counting the 2000–2003 overlap. Drop the `date` column for the prepared file (redundant given year/month/date_of_month).

## Key Quantitative Findings

| Comparison | Value |
|---|---|
| Mean daily births, weekdays (Mon–Fri) | ~12,394 |
| Mean daily births, Saturdays | 8,622 |
| Mean daily births, Sundays | 7,635 |
| Sunday vs. Tuesday deficit | −40% |
| Dec 25 overall mean | 6,601 |
| Dec 25 as % of surrounding-day baseline | ~55% |
| Dec 25 on Sunday (1994, 2005, 2011) | 63% → 49% → 48% of baseline |
| Dec 25 on Saturday (1999, 2004, 2010) | 57% → 50% → 50% of baseline |
| Friday the 13th vs. typical Friday | ~5% lower (11,744 vs. 12,349) |

## Teaching Fit

- Beginner friendliness: high — data loads from a package, columns are self-explanatory, no joins needed beyond combining two datasets
- Interestingness: very high — birthdays are universally relatable; the holiday-avoidance finding surprises most people
- Stability: high — historical birth data does not change
- Package size impact: low — 7,670-row CSV is ~165 KB
- Maintenance risk: very low — data is historical and static
- Ethics/privacy concerns: none — aggregate counts, no individual-level data

## Tutorial Fit

- Target learner: intro-level R student who has seen `ggplot2` basics
- Possible final Quarto artifact: a two-section report with a calendar heatmap and a trend comparison of Christmas births by weekday group
- Main result about the world: scheduled deliveries have given American families increasing control over birth timing, and that control shows up in growing holiday and weekend dips in the national birth calendar
- Why this belongs in `misc.tutorials`: small footprint, loads from a package, the mystery unfolds in a natural two-step that requires exactly one `geom_tile` and one `geom_line`, and the conclusion is genuinely surprising and interpretable

### Possible Exercise Path

1. Load both birth datasets from the `fivethirtyeight` package and combine them, filtering to avoid double-counting
2. Inspect structure — notice `day_of_week` is a factor, not a number
3. Compute average births by month and day of month; create the calendar heatmap
4. Spot the holiday dips and the September cluster; name what you see
5. Quantify the Christmas dip — compute Dec 25 average vs. surrounding-day baseline
6. Try to see if the dip is growing over time — first naive plot looks noisy
7. Discover the day-of-week confound — Christmas falls on different weekdays each year
8. Reframe: compare Dec 25 to the day-of-week baseline (or filter to same-weekday years)
9. Reveal the trend: same-weekday comparisons confirm the dip has deepened
10. Write an interpretation connecting the trend to the rise of scheduled deliveries

### Rendered Outputs Students Could Inspect

- Calendar heatmap (month × day_of_month, fill = mean births)
- Bar chart of births by day of week (shows weekend dip clearly)
- Line/point chart of Dec 25 pct_of_baseline by year, colored by day of week

### Knowledge Drop Candidates

- Data/source context: the two datasets come from different sources (CDC NCHS vs. SSA) and overlap 2000–2003; using both without deduplication would double-count those years
- Unit of observation: one row = one calendar day; births is the total count of live births registered that day in the US
- Variable meaning: `day_of_week` is an ordered factor with levels Sun through Sat; treat it as a category, not a number
- Data quality issue: the datasets use registration date, not birth date — a small number of births registered days after they occurred may shift the totals slightly
- Interpretation point: the weekend dip and the holiday dip share the same mechanism — scheduled deliveries let families avoid inconvenient dates
- Interpretation point: the growing holiday dip reflects the national rise in C-sections and inductions, from ~20% of births in the 1990s to ~32% by the 2010s
- Limitation or caveat: the data ends in 2014; patterns since then may differ as birth rates and scheduling practices have continued to evolve

### Reproducibility Plan

- Can `analysis.qmd` read local data without downloading during render? Yes — save `births_prepared.rds` locally and read from there
- Where should source copies or prepared data live? `data/births_prepared.rds` inside the tutorial folder
- What source URL comment should appear near the data-reading code? `# Source: fivethirtyeight R package — US_births_1994_2003 and US_births_2000_2014`
- What data reduction is needed? Drop the `date` column (redundant); save as RDS for compact size

## Exploration Results

Generated outputs:
- `births-heatmap.png` — calendar heatmap; Sep cluster and holiday dips clearly visible
- `births-by-day-of-week.png` — weekday bar chart; Tue peak, Sun trough, 40% gap
- `december-births-by-day.png` — Dec 20–31 bar chart; Dec 24–26 and Dec 31 in red
- `christmas-dip-over-time.png` — Dec 25 pct_of_baseline by year; noisy due to day-of-week variation but trend is downward
- `friday_13th_summary.csv` — Fri 13th averages 11,744 vs. 12,349 on a typical Friday (~5% lower)

The heatmap is immediately striking. The September cluster is bright and the holiday dips are unmistakable dark notches. The day-of-week bar chart is the strongest single-chart teaching moment — the Sunday trough is so far below Tuesday that students immediately ask why.

## Decision

- Decision: promote to tutorial
- Reason: data is instantly loadable, mystery is genuine and two-layered, plots are clean and compelling, topic is universally relatable, and the tutorial arc naturally teaches `geom_tile`, grouped summaries, and the concept of a confounding variable in a very approachable way
- Next action: draft `tutorial-proposal.md`, then promote to `misc.tutorials`

## Promotion Notes

- Target tutorial folder: `inst/tutorials/us-births-heatmap/`
- Final data format: `.rds` (prepared combined dataset, ~19 KB)
- Transformations applied: `bind_rows` + year filter to deduplicate; drop `date` column
- Source notes required: note the two-dataset origin and the registration-date caveat
- Tutorial proposal path: `explorations/us-births-heatmap/tutorial-proposal.md`
