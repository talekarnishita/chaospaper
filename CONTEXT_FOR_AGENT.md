# Context for New Agent (chaospaper)

**Repo:** Chaos theory applied to sports performance analytics (MATLAB + Python). Peer-review documentation and code revamp are in place for resubmission.

---

## What the repo does
- **MATLAB:** Classify team/metric time series as non-stationary, stochastic, chaotic, or periodic (stationarity → Schreiber denoising → surrogate test → 0-1 test). Optional nonlinearity tests (Keenan, Ramsey, Teräsvirta, Tsay) on denoised data.
- **Python:** Forecasting (e.g. `runcode.ipynb`, `neurips forecasting/`); Lyapunov referenced there, not in the MATLAB chaos path.
- **Python script:** `process_data_folder.py` — standardizes CSV columns to Date, HomeTeam, AwayTeam, FTHG, FTAG and date format DD/MM/YYYY; reads from a folder (e.g. `data/raw`), writes to `data/processed/` with prefix `clean_`.

---

## Key files
| File | Role |
|------|------|
| `chaos_config.m` | Shared config: 14 sports-metric column names and paths (`data/raw`, `data/results`, `data/denoised`, `data/nonlinear_results`). |
| `phasechaos.m` | Batch driver: reads CSVs from `cfg.folder_raw`, runs `chaos_modified` per column, writes results and denoised CSVs. |
| `chaos_modified.m` | Core pipeline: stationarity (e.g. ADF), Schreiber denoising, surrogate (AAFT) + permutation entropy, 0-1 test; contains `phasespace`, `noiserSchreiber`, `petropy`, `z1test`, `surrogate`. |
| `finalenonlinear.m` | Runs nonlinearity tests (`NonlinTst`) on denoised CSVs from `cfg.folder_denoised`; writes to `cfg.folder_nonlinear`. |
| `README_TECHNICAL.md` | Methodology-to-code table (§1), pipeline flowchart (§2), feature-engineering justification (§3). Use for Methods/rebuttal. |
| `MANUSCRIPT_REVISION_CONTENT.md` | Ready-to-insert manuscript text for peer review (P1–P6): methodology, data, hypothesis, theory, practical, documentation. |
| `process_data_folder.py` | Standard-library only. Run: `python3 process_data_folder.py [input_folder]` (default `data/`; use `data/raw` for raw CSVs). |
| `compute_LLE_reviewer6.py` | Computes Largest Lyapunov Exponent (LLE) for Team 52 FTHG; prints Reviewer #6 chaos/stochastic text; saves to `data/results/LLE_reviewer6_results.txt`. Requires numpy. |
| `run_LLE_test_cases.py` | Runs 7 LLE test cases (Team 52 FTHG/FTAG, Teams 6/14/19 FTHG, logistic map, white noise); saves each to `data/results/LLE_test_<id>.txt` and `LLE_test_cases_summary.txt`. |
| `validate_LLE_results.py` | Validates LLE: theoretical vs Rosenstein (logistic map), white noise, Team 52 LLE vs 0-1 test; writes `data/results/LLE_validation_report.txt`. |
| `run_chaos_octave.m` | Octave-only driver: loads `clean_game.csv` (built-ins), filters Team 52, sorts by date, runs `chaos_modified` in vector mode. Use when MATLAB is not installed. |
| `HYPOTHESIS_PROOF.md` | Full hypothesis proof: H1–H6 with evidence and verdicts; points to `data/results/` artifacts. |
| `test_cases_LLE_reviewer6.md` | Test-case doc for LLE and Reviewer #6 text (NHL, synthetic chaos/stochastic). |
| `prove_hypothesis.m` | Chaos vs Random baseline for 5 teams (52, 6, 14, 19, 24); writes `data/results/prove_hypothesis_results.txt` and `prove_hypothesis_summary.csv`. |
| `validate_prove_hypothesis.py` | Validates prove_hypothesis summary; writes `data/results/prove_hypothesis_validation_report.txt`. |
| `docs/REVIEW_RESPONSE.md` | Hypothesis answers (H1–H6) and point-by-point response to Associate Editor and Reviewers 1, 3, 5, 6. Use for rebuttal. |
| `docs/README.md` | Documentation index: REVIEW_RESPONSE, HYPOTHESIS_PROOF, MANUSCRIPT_REVISION_CONTENT, results layout. |
| `REVISION_CHECKLIST.md` | Resubmission checklist: P1–P6, rebuttal items, evidence to generate. |
| `DATA_AVAILABILITY.md` | Dataset citations, Data availability statement template, how to cite code. |
| `data/results/README.md` | Per-file list of outputs in data/results/. |

---

## Data layout
- **`data/raw/`** — Raw CSVs (e.g. NHL `game.csv`; also game_goals, game_plays, etc.). `phasechaos.m` and `chaos_config` expect team CSVs with the 14 metrics here (or set paths in `chaos_config.m`).
- **`data/processed/`** — Output of `process_data_folder.py` (e.g. `clean_game.csv`: Date, HomeTeam, AwayTeam, FTHG, FTAG).
- **`data/results/`** — Chaos classification from `phasechaos.m`; LLE and Reviewer #6 outputs; hypothesis and prove_hypothesis. Key files: `LLE_reviewer6_results.txt`, `chaos_classification_results.txt`, `LLE_test_cases_summary.txt`, `LLE_validation_report.txt`, `REVIEWER6_SUMMARY.txt`, `hypothesis_proof_summary.txt`, `prove_hypothesis_results.txt`, `prove_hypothesis_summary.csv`, `prove_hypothesis_validation_report.txt`. Per-case LLE: `LLE_test_team52_FTHG.txt`, etc.
- **`data/denoised/`** — Denoised CSVs from `phasechaos.m`; input for `finalenonlinear.m`.
- **`data/nonlinear_results/`** — Nonlinearity test output from `finalenonlinear.m`.

---

## Important details
- **Embedding dimension:** In the main chaos path it is *not* set by FNN; the 0-1 test is used without phase-space reconstruction. FNN is only used inside the surrogate routine for PPS/TS. See README_TECHNICAL §1.
- **Feature engineering:** No single composite formula; 14 metrics are processed as separate univariate series (multi-metric validation). See README_TECHNICAL §3.
- **NonlinTst:** Called by `finalenonlinear.m` but not in the repo (external/toolbox).
- **Remotes:** `origin` = Manojh23/chaospaper; `myfork` = talekarnishita/chaospaper. Push to `myfork` for your fork.
- **Octave (no MATLAB):** Use `run_chaos_octave.m` for 0-1 classification; it reads `data/processed/clean_game.csv` with built-ins, filters Team 52, calls `chaos_modified(y, ...)`. `chaos_modified.m` has guards for Octave (no `istable`, no `adftest`; assumes stationary when adftest missing).
- **LLE:** Uses built-in Rosenstein implementation (no nolds). LLE > 0 → chaos; LLE ≤ 0 → stochastic. Primary chaos classification is 0-1 test + surrogate; LLE is supporting evidence for Reviewer #6.
- **Hypothesis proof:** See `HYPOTHESIS_PROOF.md` for H1–H6; short summary in `data/results/hypothesis_proof_summary.txt`. Rebuttal: `docs/REVIEW_RESPONSE.md` (hypothesis answers + Editor/Reviewers 1,3,5,6). Gaps: NBA classification table (H2), full forecast-by-classification table (H6); `prove_hypothesis_summary.csv` supports H6 partially.

---

## Quick commands (for next agent)
```bash
# Process raw CSVs → clean_game.csv (dates + sort)
python3 process_data_folder.py data/raw

# LLE for Team 52 + Reviewer #6 text (saves to data/results/)
python3 compute_LLE_reviewer6.py

# All LLE test cases (teams + synthetic)
python3 run_LLE_test_cases.py

# Validate LLE (theoretical, consistency)
python3 validate_LLE_results.py

# Chaos vs Random baseline (five teams; writes results + summary CSV)
octave prove_hypothesis.m

# Validate prove_hypothesis results
python3 validate_prove_hypothesis.py

# Chaos classification (Octave; no MATLAB)
octave run_chaos_octave.m
```

Use this file to bring a new agent up to speed quickly.
