# Revision checklist — Resubmission

Use this checklist to track manuscript and rebuttal progress. Source: [MANUSCRIPT_REVISION_CONTENT.md](MANUSCRIPT_REVISION_CONTENT.md) (P1–P6), [docs/REVIEW_RESPONSE.md](docs/REVIEW_RESPONSE.md).

---

## P1: Methodology clarity

- [ ] **Abstract / Introduction** — State multistage workflow and chaos-aware forecasting model explicitly; add one-sentence description of nonlinearity assessment (surrogate + 0-1 test; optional Keenan etc.).
- [ ] **Methods — Nonlinearity assessment** — Insert paragraph on surrogate test (AAFT, permutation entropy) and optional Keenan/Ramsey/Teräsvirta/Tsay; add table Test → Role.
- [ ] **Methods — Multistage workflow** — Restructure into: Data and metrics → Preprocessing → Nonlinearity and chaos detection → Forecasting.
- [ ] **Figure 1 (flowchart)** — Add pipeline flowchart from [README_TECHNICAL.md](README_TECHNICAL.md) §2 (Raw data → Preprocessing → Surrogate → 0-1 test → Classification → Optional nonlinearity → Forecasting).
- [ ] **Methods — Implementation parameters** — Add subsection or Supplementary Table S1: embedding delay τ, embedding dimension, Schreiber (K, L, r), K-statistic cutoff, 0-1 test σ, permutation entropy (n, τ). Source: README_TECHNICAL §1.

---

## P2: Dataset

- [ ] **Dataset citation** — Cite NHL/NBA/Premier League data sources in Methods (Data). See [DATA_AVAILABILITY.md](DATA_AVAILABILITY.md).
- [ ] **Data details** — Expand Data subsection: sources, time span, 14 variables (list from chaos_config.m / README_TECHNICAL §3), processing (stationarity, Schreiber, per-metric).
- [ ] **Sample size** — Add table N per team/league; state that short series (e.g. N ≈ 38) are reported and discussed in Limitations.
- [ ] **Data availability statement** — Add to manuscript; template in [DATA_AVAILABILITY.md](DATA_AVAILABILITY.md).

---

## P3: Hypothesis and counterexamples

- [ ] **Classification outcomes** — Add subsection “Classification outcomes and counterexamples”: report chaotic/stochastic/non-stationary by league/team; list counterexample teams and brief explanation.
- [ ] **NBA outcome** — State clearly: all 30 NBA teams classified as stochastic (no chaos under our pipeline). Add summary table League | N teams | N chaotic | N stochastic | N non-stationary when NBA run is done (H2).
- [ ] **Forecasting by classification** — Add subsection “Forecasting performance by classification”: table Chaos vs Random (or baseline) by team; cite `prove_hypothesis_summary.csv`. Full forecast-by-classification table (chaotic vs stochastic teams) when available (H6).

---

## P4: Theory and feature engineering

- [ ] **Feature engineering (no composite)** — State in Methods: 14 metrics as separate univariate series; no single composite formula; rationale in README_TECHNICAL §3. If manuscript has “Eq. (4)” composite, either define and implement it or align text with per-metric only.
- [ ] **Limitations** — Add: single pipeline (embedding, denoising, surrogate); alternative methods may yield different classifications; theoretical justification for chaos in sports remains limited.

---

## P5: Practical validation and robustness

- [ ] **Practical validation** — State in Limitations: real-world validation (betting, coaching, match prediction) was not performed; future work.
- [ ] **Robustness claim** — Soften Abstract/Results: chaos-aware forecasting improves over baseline for some teams (cite prove_hypothesis results); not “strong robustness” globally; sample and league limit generalisation.

---

## P6: Documentation (Reviewer #3)

- [ ] **Eq. (2)** — Add explanation after Eq. (2): define each symbol; one sentence on role (e.g. 0-1 test transformation, K-statistic).
- [ ] **Flowchart** — See P1 (Figure 1).
- [ ] **Keenan / short series** — In Methods: Keenan may not detect complex nonlinearity; for short series, tests have limited power. In Limitations: short series → interpret classification with caution.

---

## Rebuttal letter

- [ ] **Associate Editor** — Confirm each reviewer point addressed one by one; acknowledge limited data and partial hypothesis validation.
- [ ] **Reviewer #1** — Dataset citation and data details (see P2).
- [ ] **Reviewer #3** — Sensitivity to initial conditions; flowchart; Eq. (2); Keenan limitations; short series (see P6).
- [ ] **Reviewer #5** — Methodology in Abstract/Intro; implementation parameters; partial validation and counterexamples; robustness wording (see P1, P3, P5).
- [ ] **Reviewer #6** — Inconsistent results (NBA vs NHL); sample size; no ad hoc composite (14 univariate metrics); partial/practical validation; theory and evidence (see [docs/REVIEW_RESPONSE.md](docs/REVIEW_RESPONSE.md) Part F).

---

## Evidence to generate (optional)

- [ ] **NBA classification table** — Run `phasechaos.m` on NBA CSVs; fill table League | N teams | N chaotic | N stochastic | N non-stationary; save to `data/results/` and cite (H2).
- [ ] **Forecast-by-classification table** — Report forecast performance (e.g. MAE/RMSE) by chaotic vs stochastic teams; add to Results and H6 evidence (H6).

---

*Tick items as done. Cross-reference MANUSCRIPT_REVISION_CONTENT.md and docs/REVIEW_RESPONSE.md for exact insert text.*
