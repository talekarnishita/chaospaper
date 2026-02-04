# Documentation Index — Chaos Theory Sports Analytics

This folder holds peer-review and hypothesis documentation. Code and results live in the repo root and `data/`.

---

## Main documents

| Document | Purpose |
|----------|---------|
| **[REVIEW_RESPONSE.md](REVIEW_RESPONSE.md)** | **Hypothesis answers** (H1–H6) and **point-by-point response** to Associate Editor and Reviewers 1, 3, 5, 6. Use for the rebuttal letter and revision plan. |
| **[../HYPOTHESIS_PROOF.md](../HYPOTHESIS_PROOF.md)** | Full hypothesis proof: claim, evidence, verdict, and artifact locations for each of H1–H6. |
| **[../MANUSCRIPT_REVISION_CONTENT.md](../MANUSCRIPT_REVISION_CONTENT.md)** | Ready-to-insert manuscript text (P1–P6): methodology, data, hypothesis, theory, practical, documentation. |
| **[../README_TECHNICAL.md](../README_TECHNICAL.md)** | Methodology-to-code table (§1), pipeline flowchart (§2), feature-engineering justification (§3). Use for Methods and rebuttal. |
| **[../REVISION_CHECKLIST.md](../REVISION_CHECKLIST.md)** | Resubmission checklist: P1–P6, rebuttal items, evidence to generate. Tick as done. |
| **[../DATA_AVAILABILITY.md](../DATA_AVAILABILITY.md)** | Dataset citations (NHL, NBA, Premier League), Data availability statement template, how to cite code. |
| **[plots.md](plots.md)** | **Plots** — All figures in one doc: pipeline, phase space, forecast comparison, taxonomy, sample size, forecast-by-classification, LLE vs improvement, league summary. |

---

## Hypothesis answers (short)

- **H1** Pipeline validity — **Supported** (synthetic + pipeline in `chaos_modified.m`).
- **H2** NBA all stochastic — **Reported** (table from NBA run when available).
- **H3** NHL chaos / generalization — **Supported** (Team 52 and others; LLE + 0-1 test).
- **H4** LLE vs 0-1 consistency — **Supported** (Team 52).
- **H5** Multi-metric design — **Supported** (14 univariate series; README_TECHNICAL §3).
- **H6** Classification informs forecasting — **Partially supported** (`prove_hypothesis.m`, Chaos vs Random by team; full forecast-by-classification table to be added).

Summary file: `data/results/hypothesis_proof_summary.txt`.

---

## Results and validation (where to find evidence)

All under **`data/results/`**:

| File | Content |
|------|---------|
| `hypothesis_proof_summary.txt` | Short hypothesis verdicts |
| `LLE_validation_report.txt` | LLE checks (logistic, white noise, Team 52 consistency) |
| `LLE_reviewer6_results.txt` | Team 52 LLE + Reviewer #6 chaos sentence |
| `chaos_classification_results.txt` | Team 52 0-1 test = chaotic |
| `LLE_test_cases_summary.txt` | Multiple teams + synthetic LLE |
| `prove_hypothesis_results.txt` | Chaos vs Random baseline (full text by team) |
| `prove_hypothesis_summary.csv` | Chaos vs Random: team_id, n, rmse_chaos, rmse_random, improvement_pct |
| `prove_hypothesis_validation_report.txt` | Validation of prove_hypothesis outputs |
| `REVIEWER6_SUMMARY.txt` | Reviewer #6 text and pointers |
| `LLE_test_team*.txt`, `LLE_test_synthetic_*.txt` | Per-case LLE |

---

## Repo layout (relevant to docs)

- **Root:** `chaos_modified.m`, `phasechaos.m`, `run_chaos_octave.m`, `prove_hypothesis.m`, `compute_LLE_reviewer6.py`, `run_LLE_test_cases.py`, `validate_LLE_results.py`, `validate_prove_hypothesis.py`, `process_data_folder.py`, `chaos_config.m`, `CONTEXT_FOR_AGENT.md`.
- **data/raw/** — Raw CSVs (NHL, etc.).
- **data/processed/** — e.g. `clean_game.csv` (Date, HomeTeam, AwayTeam, FTHG, FTAG).
- **data/results/** — All result and validation files above. See [data/results/README.md](../data/results/README.md) for a per-file list.
- **docs/** — This folder; REVIEW_RESPONSE.md, README.md.

---

## Quick commands (evidence generation)

```bash
# Process raw → clean_game.csv
python3 process_data_folder.py data/raw

# LLE Team 52 + Reviewer #6 text
python3 compute_LLE_reviewer6.py

# All LLE test cases
python3 run_LLE_test_cases.py

# Validate LLE
python3 validate_LLE_results.py

# Chaos vs Random baseline (five teams), writes results + summary CSV
octave prove_hypothesis.m

# Validate prove_hypothesis results
python3 validate_prove_hypothesis.py

# Chaos classification (Octave, no MATLAB)
octave run_chaos_octave.m
```
