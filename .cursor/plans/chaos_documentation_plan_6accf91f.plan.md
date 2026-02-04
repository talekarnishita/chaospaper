---
name: Chaos Documentation Plan
overview: "A three-phase plan to produce reviewer-facing documentation: (1) three documentation layers (workflow diagram, mathematical mapping table, validation logic), (2) execution of the BMad Technical prompt (methodology-to-code table, Mermaid flowchart, feature-engineering justification), and (3) where to place each artifact (README, Rebuttal Letter, Methods)."
todos: []
isProject: false
---

# Chaos Theory Project: Documentation Plan for Peer Review

## Codebase Summary (Findings)

- **[phasechaos.m](phasechaos.m)** (159 lines): Batch script (header: "classify_all_teams.m") that reads CSVs from a folder, defines `columns_to_process` (14 sports metrics: FTGoalsFor, FTGoalsAgainst, TeamGS, TeamGC, etc.), and for **each column** calls `chaos_modified(y, [], 'adf', 'schreiber', 0, 'AAFT', 'downsample', 0.5)`. It does **not** combine metrics into one formula; it processes columns individually.
- **[chaos_modified.m](chaos_modified.m)** (1288 lines): Core pipeline. Contains: stationarity test (e.g. ADF), Schreiber denoising (`noiserSchreiber`), surrogate test (AAFT/CPP + permutation entropy), then 0-1 test (`z1test`) with data-dependent cutoff. Also embeds: `phasespace(x,dim,tau)` (used inside Schreiber with `dim=3`, `tau=1`), `petropy`, and inside the **surrogate** code path, `embedsig(...,'DimAlg','fnn')` for PPS/TS methods only. **Embedding dimension (m)** is **not** set by FNN in the main chaos classification path; FNN is only used when generating PPS/TS surrogates. Lyapunov exponents are not computed in the MATLAB chaos path (they appear only in Python notebooks under `neurips forecasting/`).
- **[finalenonlinear.m](finalenonlinear.m)** (65 lines): Reads denoised CSVs, loops over the same column names, and calls `NonlinTst(y)` to get Ramsey, Keenan, Terasvirta, Tsay p-values. **NonlinTst** is not present in the repo (likely toolbox or external file); the table will cite the call site and argument.

---

## Phase 1: The Three Documentation Layers

### 1. Workflow Diagram (Visual — Reviewer #3)

**Goal:** One diagram: Raw Data → Preprocessing → Chaos Detection → Forecasting.

**Content to capture:**

- **Raw data:** CSV/XLS per team; columns = sports metrics (see `columns_to_process` in [phasechaos.m](phasechaos.m) lines 39–40).
- **Preprocessing:** Stationarity test (e.g. ADF) → Schreiber denoising → optional oversampling/downsampling (all in [chaos_modified.m](chaos_modified.m)).
- **Nonlinearity (optional branch):** Keenan (and other) tests via `NonlinTst` in [finalenonlinear.m](finalenonlinear.m) (lines 49–56).
- **Chaos detection:** Surrogate test (AAFT, permutation entropy) → if not stochastic: 0-1 test, K vs cutoff → classification (chaotic / periodic). Phase-space reconstruction (`phasespace`) is used inside Schreiber and inside surrogate (PPS/TS) with FNN for embedding.
- **Forecasting:** Attractor/neural net (Python: e.g. `runcode.ipynb`, `neurips forecasting/`); Lyapunov referenced there, not in the main MATLAB chaos script.

**Deliverable:** A single Mermaid flowchart (or diagram) that matches the above and can be pasted into the README.

### 2. Mathematical Mapping Table (Technical — Reviewer #5)

**Goal:** Map scientific concepts to code: variable names, default/calculation, and code references.

**Primary source:** [chaos_modified.m](chaos_modified.m). **Secondary:** [phasechaos.m](phasechaos.m) (call arguments, column list), [finalenonlinear.m](finalenonlinear.m) (NonlinTst, Keenan).

**Concepts and code (to be turned into a Markdown table):**


| Concept                         | Variable/Location                                                  | Default/Calculation                                        | Code reference                                            |
| ------------------------------- | ------------------------------------------------------------------ | ---------------------------------------------------------- | --------------------------------------------------------- |
| **Embedding delay**             | `tau` in `phasespace(x,dim,tau)`                                   | Default `1` if empty                                       | chaos_modified.m ~682–695, 704                            |
| **Embedding dimension**         | `dim` in `phasespace(x,dim,tau)`                                   | Default `2` if empty; in Schreiber `K+L+1` → 3             | chaos_modified.m ~666–678, 541 (noiserSchreiber: K=1,L=1) |
| **Embedding dimension (FNN)**   | Used only in surrogate: `embedsig(sig,'DimAlg','fnn')`; output `m` | Computed by FNN when method is PPS or TS                   | chaos_modified.m ~991–998, 1041–1047                      |
| **Schreiber denoising**         | `noiserSchreiber(x,K,L,r,repeat,auto)`                             | K=1, L=1, r=std(x), repeat=1; then y(10:end-10)            | chaos_modified.m 92–98, 405–489                           |
| **K-statistic cutoff**          | `cutoff`                                                           | 0.00005455*length(y)+0.422, cap 0.99                       | chaos_modified.m 217–221                                  |
| **0-1 test noise**              | `sigma`                                                            | 0.5                                                        | chaos_modified.m 51–52, 231 (z1test(y,sigma))             |
| **Permutation entropy**         | `petropy(y,n,tau,method,accu)`                                     | n=5, tau=1 for output; n=8, tau=1 for surrogate comparison | chaos_modified.m 223, 150/165/186                         |
| **Keenan / nonlinearity tests** | `NonlinTst(y)`                                                     | Returns Ramsey, Keenan, Terasvirta, Tsay p-values          | finalenonlinear.m 49–56                                   |


**Critical for Reviewer #5:** In the **main** chaos classification path, embedding dimension is **not** chosen by FNN: the 0-1 test is used without phase-space reconstruction. FNN is used **only** inside the surrogate generator for PPS/TS methods. The table must state this explicitly.

### 3. Validation Logic (Scientific — Reviewer #6)

**Goal:** Justify how metrics are combined/used so it does not read as "arbitrary."

**Current implementation:** There is **no** single composite formula in code that merges the 14 sports columns into one index. The pipeline:

- Selects a fixed set of **columns** (goals, points, form, streaks, etc.) as domain-relevant features.
- Processes **each column separately** through the same pipeline (stationarity → denoising → surrogate → 0-1 test).

**Justification narrative to document:**

- **Column set:** The 14 variables are standard performance/outcome metrics (goals for/against, points, form, streaks, differentials). Using them as separate univariate series is a form of **multi-metric analysis** rather than ad hoc combination; each series is tested for chaos independently, which is appropriate for small datasets and avoids arbitrary weighting.
- **Preprocessing chain:** Stationarity and denoising (Schreiber) are standard before nonlinear analysis; the cutoff is **data-length-dependent** (linear in N), which addresses sample-size sensitivity.
- **Dimensionality:** Keeping one dimension per series (no composite index) avoids introducing an unspecified composite formula and keeps the methodology interpretable. If the paper or rebuttal refers to a "composite index" or "Eq. 4," the text should be aligned with what the code actually does (per-column analysis and/or a clearly defined composite, if added later).

**Deliverable:** A short technical paragraph for the Data Preprocessing / Methods section and for the Rebuttal (Reviewer #6).

---

## Phase 2: The BMad Technical Prompt — Task Mapping

The three tasks in the user's BMad prompt map to the following concrete steps.

### Task 1: Methodology-to-Code Table (Reviewer #5)

- **Analyze:** [chaos_modified.m](chaos_modified.m) (phasespace, noiserSchreiber, petropy, z1test, cutoff, sigma, surrogate/embedsig); [finalenonlinear.m](finalenonlinear.m) (NonlinTst, column names).
- **Produce:** Markdown table with columns: Scientific Concept, MATLAB Variable Name, Default Value/Calculation Method, Code Reference (line or snippet).
- **Answer explicitly:** "Embedding dimension (m) is **not** determined by FNN in the main chaos classification; it is used only in the surrogate routine for PPS/TS via `embedsig(...,'DimAlg','fnn')`. The main path uses the 0-1 test without phase-space reconstruction."

### Task 2: Algorithmic Flowchart (Reviewer #3)

- **Base:** Flow implied by [chaos_modified.m](chaos_modified.m) and [phasechaos.m](phasechaos.m).
- **Mermaid flowchart:** Start (Raw Data: CSV/XLS) → Preprocessing & feature access (read columns; stationarity; Schreiber; optional downsampling) → Nonlinearity test (optional: Keenan etc. via finalenonlinear.m) → Phase-space / chaos (surrogate test → if not stochastic: 0-1 test, cutoff, "Is Chaotic?" diamond: K > cutoff) → Forecasting (Python/Attractor/Neural net). Use Mermaid syntax rules (no spaces in node IDs, quoted labels for special characters).

### Task 3: "Net Attribute" / Feature Engineering Justification (Reviewer #6)

- **Review:** [phasechaos.m](phasechaos.m) (columns_to_process, per-column loop) and [chaos_modified.m](chaos_modified.m) (single-vector pipeline).
- **Write:** One paragraph stating that (1) the pipeline uses a defined set of domain-relevant sports metrics as **separate** univariate series, (2) each series is preprocessed and tested for chaos independently to avoid arbitrary weighting and to suit small samples, and (3) this amounts to multi-metric validation rather than an unspecified composite, with optional note that a composite index could be defined explicitly (e.g. in a future Eq. 4) if the manuscript mentions one.

---

## Phase 3: Where to Use the Outputs


| Output                            | Destination                                                 | Action                                                                                                                                      |
| --------------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **Mermaid flowchart**             | [README.md](README.md)                                      | Paste the Mermaid code block; GitHub renders it. Ensure it looks like a clear pipeline/decision flow.                                       |
| **Methodology-to-Code table**     | Rebuttal Letter (Reviewer #5)                               | Paste under the response that says implementation parameters are clarified in the revised manuscript.                                       |
| **Feature-engineering paragraph** | Paper Methods (Data Preprocessing) + Rebuttal (Reviewer #6) | Frame the metric choice and per-column analysis as dimensionality and interpretability choices for high-variance, small-sample sports data. |


---

## Technical Debt

Items to track for maintainability, reproducibility, and alignment with the paper. Address as part of documentation or future refactors.


| Category                     | Item                            | Location / Notes                                                                                                                                                                                                                                                                        |
| ---------------------------- | ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Missing dependency**       | `NonlinTst` not in repo         | [finalenonlinear.m](finalenonlinear.m) calls it (line 51); Keenan/Ramsey/Terasvirta/Tsay tests. Add implementation or document required toolbox/script.                                                                                                                                 |
| **Hardcoded paths**          | Windows absolute paths          | [phasechaos.m](phasechaos.m) 23–27: `E:\chaosgrandfinale\teams2_perspective`, `correctdenoising`, `denoising2`. [finalenonlinear.m](finalenonlinear.m) 2–5: `E:\chaosgrandfinale\denoising2`, `tooscaredResults`. Replace with config variable or relative paths for portability.       |
| **Naming / consistency**     | Script name vs header           | [phasechaos.m](phasechaos.m) file name does not match header comment "classify_all_teams.m". Align name or header for clarity.                                                                                                                                                          |
| **Monolithic file**          | Single 1288-line file           | [chaos_modified.m](chaos_modified.m) embeds `petropy`, `z1test`, `noiserSchreiber`, `phasespace`, `radnearest`, `surrogate` (and subfunctions). Consider splitting into separate .m files or a +package for readability and testing.                                                    |
| **Duplicated configuration** | Column list in two places       | `columns_to_process` in [phasechaos.m](phasechaos.m) (39–40) and `colNames` in [finalenonlinear.m](finalenonlinear.m) (14–16). Centralize (e.g. shared config or function) to avoid drift.                                                                                              |
| **Cutoff provenance**        | Empirical cutoff formula        | [chaos_modified.m](chaos_modified.m) 218–221: cutoff = 0.00005455*length(y)+0.422. Comment references "cutoff_fit.mat" but code uses inline expression. Document origin (e.g. regression source) in code or Methods.                                                                    |
| **Split pipeline**           | Chaos vs Lyapunov / forecasting | Main chaos classification is MATLAB ([chaos_modified.m](chaos_modified.m)); Lyapunov and attractor/neural net live in Python (`neurips forecasting/`, runcode.ipynb). Document interface (e.g. denoised CSV) and ensure paper narrative matches.                                        |
| **FNN usage**                | FNN only in surrogate path      | Embedding dimension from FNN is used only for PPS/TS surrogates ([chaos_modified.m](chaos_modified.m) ~991, 1045). Main 0-1 path does not use phase-space reconstruction. Either document as design choice or consider exposing FNN/tau for optional phase-space analysis in main path. |


---

## Implementation Notes

1. **NonlinTst:** Not in the repo. The table should cite [finalenonlinear.m](finalenonlinear.m) (lines 49–56) and note that the implementation of NonlinTst (Keenan, etc.) is external/toolbox unless you add it.
2. **Lyapunov:** Not in the MATLAB chaos path. If the paper claims Lyapunov in the "chaos detection" step, either (a) point to the Python forecasting notebooks where it is used, or (b) clarify in the diagram that Lyapunov belongs to the forecasting/attractor part.
3. **"Eq. 4" / composite:** There is no in-code composite formula. If the manuscript has an "Eq. 4" for a composite index, either add that formula and implement it in the script or align the text with per-column analysis only.
4. **File roles:** For Reviewer #5, the **implementation** details (tau, dim, FNN, cutoff, sigma) are in **chaos_modified.m**; **phasechaos.m** is the batch driver and defines which columns and which arguments are passed to `chaos_modified`.

This plan, when executed (e.g. by running the BMad prompt with the listed files in context), yields the three artifacts and their placement as in Phase 3.
