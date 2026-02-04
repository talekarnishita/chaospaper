# Plots — Hypothesis Validation and Review Figures

This document lists all figures produced by `generate_plots.m` (Octave) and `generate_flowchart.py` (Python). Paths are relative to the project root. Regenerate with:

- **`octave generate_plots.m`** → `fig1_attractor.png` … `fig8_league_summary.png`
- **`python3 generate_flowchart.py`** → `fig_pipeline.png`

---

## Pipeline (Figure 1 — Reviewer #3)

![Pipeline flowchart](../fig_pipeline.png)

**fig_pipeline.png** — Pipeline: Raw Data → Preprocessing (stationarity) → Schreiber Denoising → Surrogate Test → 0-1 Test → Classification → Optional Nonlinearity → Forecasting.

---

## Phase Space and Forecast (Team 52)

![Phase space Team 52](../fig1_attractor.png)

**fig1_attractor.png** — Reconstructed phase space (Team 52). Delay-1 embedding: x(t), x(t+1), x(t+2); smoothed goals.

![Forecast comparison Team 52](../fig2_forecast.png)

**fig2_forecast.png** — Forecasting performance (Team 52, last 50 test games). Actual (black), Chaos k-NN model (red), Random baseline mean-last-5 (blue dashed).

---

## Taxonomy and Sample Size

![Model utility taxonomy](../fig3_taxonomy.png)

**fig3_taxonomy.png** — Diagnostic taxonomy: % improvement over baseline by team. Green: chaos model helps; grey: baseline better.

![Sample size per team](../fig4_sample_size.png)

**fig4_sample_size.png** — Sample size (N games) per NHL team.

---

## Forecast by Classification and Contrast

![Forecast by classification](../fig5_forecast_by_class.png)

**fig5_forecast_by_class.png** — Mean % improvement by regime: Chaotic (improvement > 0) vs Stochastic (improvement ≤ 0). (H6)

![Phase space Team 6](../fig6_attractor_team6.png)

**fig6_attractor_team6.png** — Reconstructed phase space (Team 6 — baseline outperforms chaos model). Contrast with Team 52.

---

## LLE and League Summary

![LLE vs forecast utility](../fig7_LLE_vs_improvement.png)

**fig7_LLE_vs_improvement.png** — LLE by team; bar colour = forecast utility (green: chaos helps, grey: baseline better). (H4)

![League comparison](../fig8_league_summary.png)

**fig8_league_summary.png** — League comparison (R6): NHL Chaotic / NHL Stochastic; NBA (all stochastic).

---

*Generated figures live in the project root. See [README.md](../README.md) § Visualization for run instructions.*
