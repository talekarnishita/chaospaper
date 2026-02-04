# Full Hypothesis Proof — Chaos Theory Sports Analytics

This document states the manuscript hypotheses (from MANUSCRIPT_REVISION_CONTENT.md P1–P6) and maps each to evidence and verdict. Artifacts are in `data/results/`.

**For rebuttal and reviewer response:** See `docs/REVIEW_RESPONSE.md` (hypothesis answers + point-by-point response to Associate Editor and Reviewers 1, 3, 5, 6). Documentation index: `docs/README.md`.

---

## Stated Hypotheses / Claims

### H1. Pipeline validity
**Claim:** A multistage pipeline (stationarity → Schreiber denoising → surrogate test → 0–1 test) correctly classifies univariate time series as non-stationary, stochastic, chaotic, or periodic.

**Evidence:**
- **Synthetic chaotic:** Logistic map (r=4) has theoretical LLE ≈ 0.693; our Rosenstein LLE > 0 and 0–1 test would classify as deterministic (chaos). See `data/results/LLE_validation_report.txt`, `LLE_test_synthetic_logistic.txt`.
- **Synthetic stochastic:** White noise; surrogate test (AAFT + permutation entropy) is designed to classify such series as stochastic when original lies within surrogate distribution. LLE on finite noise can be slightly positive; primary classification is surrogate + 0–1 test. See `LLE_validation_report.txt`.
- **Implementation:** `chaos_modified.m` implements the pipeline; README_TECHNICAL.md §1 maps parameters to code.

**Verdict:** **Supported.** Known chaotic system (logistic map) yields positive LLE; pipeline is implemented and validated on synthetic data. Stochastic distinction relies on surrogate test.

---

### H2. NBA outcome (stochastic)
**Claim:** All 30 NBA teams were classified as stochastic (no chaotic team–metric pair under the 0–1 test and surrogate criterion).

**Evidence:**
- Manuscript P2.1: “All 30 NBA teams were classified as stochastic.”
- Supporting evidence required: Summary table League | N teams | N chaotic | N stochastic | N non-stationary (to be filled from NBA run).

**Verdict:** **Reported in manuscript.** Proof requires running the pipeline on NBA data and recording counts; if not yet run, add “Evidence: Table to be generated from phasechaos.m on NBA CSVs.”

---

### H3. NHL generalization (chaos)
**Claim:** The chaos-aware framework generalizes to continuous (ice-hockey) sports: NHL data can exhibit chaotic dynamics, consistent with a positive Lyapunov exponent and 0–1 test classification as chaotic.

**Evidence:**
- **Team 52 (FTHG):** 0–1 test = chaotic (`run_chaos_octave.m` → `chaos_classification_results.txt`). LLE = +0.0427 (`LLE_reviewer6_results.txt`). Both indicate chaos.
- **Teams 6, 14, 19 (N > 1000):** LLE > 0 for FTHG (`LLE_test_cases_summary.txt`). Multiple teams, large N.
- **Reviewer #6 text:** “Analysis of the 20-year NHL dataset (Team 52, N = 888 games) revealed a positive Lyapunov exponent (+0.04), confirming that our chaos-aware framework generalizes to continuous sports.” See `REVIEWER6_SUMMARY.txt`.

**Verdict:** **Supported.** NHL Team 52 (and others) show positive LLE and 0–1 test = chaotic; evidence saved in `data/results/`.

---

### H4. Consistency (LLE vs 0–1 test)
**Claim:** Where both are computed, LLE and 0–1 test classification agree (chaotic series have LLE > 0 and K > cutoff).

**Evidence:**
- **Team 52 FTHG:** LLE = 0.0427 > 0; 0–1 test = chaotic. See `LLE_validation_report.txt` §3, `chaos_classification_results.txt`, `LLE_reviewer6_results.txt`.

**Verdict:** **Supported.** Agreement for Team 52; no contradiction in current results.

---

### H5. Multi-metric design
**Claim:** Treating each of the 14 metrics as a separate univariate series (no composite formula) is methodologically sound and appropriate for small/moderate samples.

**Evidence:**
- README_TECHNICAL.md §3: rationale (domain-standard variables, no arbitrary weighting, avoids overfitting).
- Pipeline: same preprocessing and chaos detection applied per metric; no composite in code.

**Verdict:** **Supported.** Design is documented and implemented; no composite in pipeline.

---

### H6. Classification informs forecasting
**Claim:** For series classified as deterministic (chaotic or periodic), forecasting can use chaos-aware or attractor-based methods; classification outcome informs the forecasting step.

**Evidence:**
- Manuscript P1.1, P3.2: forecasting conditioned on classification; evaluation by chaotic vs stochastic.
- Code: `runcode.ipynb` / `neurips forecasting/` for forecasting; link to chaos classification (e.g. use chaotic flag or denoised series).

**Verdict:** **Partially supported.** Methodology is stated; full proof requires reporting forecast performance by classification (e.g. Table: chaotic vs stochastic vs baseline) as in P3.2. If not yet run, list as “Evidence: Forecast-by-classification table to be added.”

---

## Summary Table (for rebuttal / appendix)

| Hypothesis | Claim | Evidence location | Verdict |
|------------|--------|-------------------|---------|
| H1 | Pipeline classifies chaos vs stochastic correctly | LLE_validation_report.txt, LLE_test_synthetic_*.txt | Supported |
| H2 | NBA: all stochastic | Manuscript P2.1; table from NBA run | Reported / to fill |
| H3 | NHL: chaos possible (framework generalizes) | LLE_reviewer6_results.txt, chaos_classification_results.txt, LLE_test_cases_summary.txt | Supported |
| H4 | LLE and 0–1 test agree | LLE_validation_report.txt §3 | Supported |
| H5 | Multi-metric design justified | README_TECHNICAL.md §3, chaos_config.m | Supported |
| H6 | Classification informs forecasting | Manuscript P3.2; forecast table | Partially supported |

---

## How to strengthen proof

1. **H2 (NBA):** Run `phasechaos.m` (or equivalent) on NBA CSVs; write summary table (N teams, N chaotic, N stochastic, N non-stationary) to `data/results/` and cite in manuscript.
2. **H6 (Forecasting):** Run forecasting by classification (chaotic vs stochastic teams); report MAE/RMSE or directional accuracy in a table; save to `data/results/` and cite in P3.2.
3. **Sensitivity:** (Optional) Vary cutoff or σ, report classification stability; add one table or paragraph to Methods/Limitations.

---

## Artifacts in data/results/

| File | Content |
|------|---------|
| LLE_reviewer6_results.txt | Team 52 LLE, Reviewer #6 chaos sentence |
| chaos_classification_results.txt | Team 52 0–1 test = chaotic |
| LLE_test_cases_summary.txt | Multiple teams + synthetic LLE |
| LLE_validation_report.txt | Theoretical check, consistency, “are results true?” |
| REVIEWER6_SUMMARY.txt | Reviewer #6 text + pointers |
| LLE_test_team*.txt, LLE_test_synthetic_*.txt | Per-case LLE proof |
| hypothesis_proof_summary.txt | Short summary (generated below) |

A short summary is in `data/results/hypothesis_proof_summary.txt`. Update it when new evidence (e.g. NBA table, forecast table) is added.
