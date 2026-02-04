# Data availability and citation

Use this file for manuscript **Methods (Data)**, **Data availability statement**, and **how to cite** the dataset or code. Fill in the placeholders with your actual sources and repository URL.

---

## Dataset citations (Methods)

Insert in the manuscript where data are first described.

**NHL (ice hockey):**
- Example: *Data were obtained from [NHL.com / NHL official statistics / insert your source]. Game-level data, time span [e.g. 2000–2020].*
- Processed series: `data/processed/clean_game.csv` (Date, HomeTeam, AwayTeam, FTHG, FTAG) produced by `process_data_folder.py` from raw CSVs in `data/raw/`.

**NBA (basketball):**
- Example: *Data were obtained from [NBA.com / Basketball-Reference / insert your source]. Time span [start year]–[end year].*

**Premier League / football:**
- Example: *Data were obtained from [Premier League / Opta / insert your source]. Time span [start year]–[end year].*

**Variables (14 per team):** FTGoalsFor, FTGoalsAgainst, TeamGS, TeamGC, TeamPoints, MatchWeek, TeamFormPts, WinStreak3, WinStreak5, LossStreak3, LossStreak5, TeamGD, TeamDiffPts, TeamDiffFormPts. See `chaos_config.m` and [README_TECHNICAL.md](README_TECHNICAL.md) §3.

---

## Data availability statement (manuscript)

Template for the manuscript Data availability section:

> The data that support the findings of this study are available from [insert source, e.g. NHL.com, NBA.com, or “the corresponding author upon reasonable request”]. Processed series and classification results are available from the authors upon reasonable request. Code is available at [insert repository URL or DOI, e.g. https://github.com/username/chaospaper].

Replace the bracketed parts with your actual data source and code repository URL or DOI.

---

## How to cite this code/repository

If you want others to cite the repository:

**Suggested format (BibTeX):**

```bibtex
@software{chaospaper20XX,
  author = {[Your names]},
  title = {Chaospaper: Chaos theory for sports performance analytics},
  year = {20XX},
  url = {https://github.com/[username]/chaospaper},
  note = {Code for chaos classification, LLE, and prove-hypothesis pipeline}
}
```

**Plain text:**

> [Your names], Chaospaper: Chaos theory for sports performance analytics, 20XX. Available at: https://github.com/[username]/chaospaper

Replace `[Your names]`, `20XX`, and `[username]` with the actual authors, year, and repository owner.

---

## Related documentation

- **Methods (Data)** — Ready-to-insert text: [MANUSCRIPT_REVISION_CONTENT.md](MANUSCRIPT_REVISION_CONTENT.md) P2.3.
- **Reviewer response (dataset)** — [docs/REVIEW_RESPONSE.md](docs/REVIEW_RESPONSE.md) Part C (Reviewer #1).
