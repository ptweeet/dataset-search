# Dataset Search

This project is a workspace for finding, evaluating, and shaping datasets before they become tutorials in the companion [`misc.tutorials`](https://github.com/ptweeet/misc.tutorials) package.

The goal is to keep early dataset research messy and cheap here, while only moving curated, tutorial-ready material into `misc.tutorials`.

Dataset promotion should follow the tutorial authoring guide in `misc.tutorials`. Use that guide as the contract for deciding whether a dataset can support a normal `learnr` tutorial: an exploratory data path, AI-directed edits to `analysis.qmd`, rendered outputs students can inspect, useful knowledge drops, and a small published Quarto artifact.

The project also keeps a higher-level walkthrough report in `reports/`. That report is for planning and review, not for student use. It should summarize the candidate datasets, the cleaned tables students would see, the section-level artifacts, and the reason each tutorial is worth teaching with AI support.

## Workflow

Start from a cool graphic, not from a domain. `topics.yml` is a loose domain filter that shapes where to look — it is not the entry point.

1. **Hunt for a compelling graphic.** Browse data journalism outlets: NYT Graphics, The Pudding, Reuters Graphics, Our World in Data, FiveThirtyEight (archived), Washington Post Graphics. Use `topics.yml` as a rough filter for domains worth focusing on. Log every promising find in `graphics.yml`.
2. **Apply the three gates.** A graphic clears the bar when all of the following are true: (a) the underlying data is publicly available, (b) AI can approximate the graphic using that data, and (c) there is a genuine mystery in the data students can solve. Record findings directly in the `graphics.yml` entry.
3. **Promote to a dataset candidate.** Once all three gates pass, add an entry to `datasets.yml` with `source_graphic` pointing to the `graphics.yml` slug and `found_via: graphic-first`.
4. Create an exploration folder under `explorations/`.
5. Fill out `notes.md` from `templates/dataset-notes.md`.
6. Use `explore.R` from `templates/explore.R` for lightweight inspection.
7. Draft `tutorial-proposal.md` from `templates/tutorial-proposal.md`.
8. Draft a project-level walkthrough in `reports/` when it helps compare candidates or explain findings to others.
9. Decide whether the dataset is rejected, kept for later, or promoted.
10. Promote only prepared tutorial assets into `misc.tutorials`.

## Statuses

- `discovered`: Found, but not reviewed yet.
- `exploring`: Currently being inspected.
- `promising`: Looks useful, but no tutorial has been drafted.
- `rejected`: Not suitable for a tutorial.
- `promoted`: Data and notes moved into `misc.tutorials`.
- `tutorial-drafted`: Tutorial exists but may need review.
- `published`: Tutorial is complete and part of the package.

## Repository Layout

```text
dataset-search/
  README.md
  topics.yml          <- domain filter; shapes where to look, not what to find
  graphics.yml        <- top of funnel; one entry per compelling graphic candidate
  datasets.yml        <- promoted from graphics.yml once all three gates pass
  explorations/
    dataset-name/
      notes.md
      explore.R
      tutorial-proposal.md
      outputs/
  templates/
    dataset-notes.md
    explore.R
    tutorial-proposal.md
```

## Evaluation Criteria

Prefer datasets that are:

- easy to load with common R packages
- small enough to ship with a tutorial, or easy to reproducibly derive
- stable and available from a durable source
- clearly licensed for teaching use
- rich enough to support several exercises
- surprising enough to motivate further exploration with a clear guiding mystery
- realistic without burying learners in cleanup work

Messy datasets can still be useful when the messiness is the lesson.

## Guiding Mysteries

Strong tutorials are not just organized around data; they are organized around curiosity. During exploration, look for a surprising pattern, puzzle, or tension that gives students a reason to keep going.

A useful guiding mystery should:

- arise from the actual data
- be easy to state in plain language
- make a first guess feel incomplete
- require another table, plot, map, or comparison to investigate
- lead naturally to an interpretation exercise

Examples:

- A place ranks highest by housing burden even though it does not have the highest rent.
- Two related measures move together in one metro but diverge in another.
- A map reveals a regional pattern that was hard to see in a ranking.

## Tutorial Fit

The `tutorial_fit` section in `datasets.yml` records whether a dataset can become the kind of tutorial described in the authoring guide. It should answer:

- What final Quarto artifact could a student publish?
- What guiding mystery motivates the analysis?
- What exploratory path would the tutorial follow?
- What rendered tables, plots, or summaries would students inspect?
- What domain facts, data quirks, or interpretation points could become knowledge drops?
- Can the tutorial read local data without downloading during render?

When writing `tutorial_fit`, keep the focus on AI-assisted data science work. The point is not to document every implementation step in detail; it is to show that a student can use AI to prepare data, compare measures, inspect outputs, and interpret what the result means.

A dataset can be interesting but still have poor tutorial fit. Promote datasets that can support a clear sequence of small exercises ending in a meaningful result about the world.

## Exploration Artifact

Each completed exploration should produce a `tutorial-proposal.md`. Treat this as the final artifact of the research phase.

The proposal should summarize:

- the tutorial's core idea
- the data source and prepared files
- the main measure or analytical question
- the guiding mystery
- the likely tutorial sections
- the artifact created by each section
- likely exercise paths
- knowledge-drop opportunities
- open questions before promotion

The proposal is what someone should be able to read before deciding whether the dataset should move into `misc.tutorials`.

## Promotion Checklist

Before moving a dataset into `misc.tutorials`, confirm:

- source URL and license are recorded
- tutorial learning goal is clear
- `tutorial_fit` identifies a plausible final artifact
- a guiding mystery motivates the analysis and is grounded in the data
- `tutorial_fit` outlines an analysis path with inspect, refine, visualize or summarize, and interpret steps
- likely knowledge drops are about the data, the domain, or the rendered output
- reproducibility notes explain how the tutorial will use local data
- `tutorial-proposal.md` summarizes the intended tutorial structure and section artifacts
- data has been reduced or transformed as needed
- final file format is chosen, such as `.rds`, `.xlsx`, `.geojson`, or `.duckdb`
- final data file is small enough for the package
- exploration notes identify the likely tutorial path
- any companion `reports/` brief explains the candidate at a higher level for review or discussion

Suggested destination in `misc.tutorials`:

```text
inst/tutorials/<tutorial-name>/
  tutorial.Rmd
  data/
    <dataset-file>
    source-notes.md
```
