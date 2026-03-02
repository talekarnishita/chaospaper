# Manuscript Changes Map — Chaos_Theory__Copy_.pdf

Where to make changes in the manuscript, cross-referenced to the revision checklist (P1–P6), reviewer responses, and generated figures.

**Sources:** [REVISION_CHECKLIST.md](../REVISION_CHECKLIST.md), [MANUSCRIPT_REVISION_CONTENT.md](../MANUSCRIPT_REVISION_CONTENT.md), [docs/REVIEW_RESPONSE.md](REVIEW_RESPONSE.md), [docs/plots_rebuttal.md](plots_rebuttal.md).

---

## Abstract (Page 1, lines 10–24)

| Change | Source | Figure |
|--------|--------|--------|
| State the multistage workflow explicitly: "stationarity → Schreiber denoising → surrogate test → 0-1 test → classification → forecasting" | P1.1 | — |
| Replace "demonstrates strong accuracy and robustness in chaotic environments" with a qualified claim: "improves over a naive baseline for some teams where chaos is detected" | P5.2 | — |
| Add one sentence naming the nonlinearity assessments (surrogate + 0-1 test; optional Keenan/Tsay/Terasvirta) | P1.1 | — |
| Add NHL alongside NBA and Premier League | P2, R6 | — |

---

## Section 1 — Introduction (Pages 1–2, lines 31–89)

| Change | Source |
|--------|--------|
| Restate hypothesis more carefully: "partially confirmed" — not all sports show chaos; NBA was stochastic | P3.1, R5 §3 |
| Soften "long-term predictions of chaotic time series" to acknowledge sensitivity to initial conditions limits predictability | P6, R3 §1 |
| Mention NHL dataset alongside NBA/Premier League | P2 |

---

## Section 3 — Dataset (Page 4, lines 126–157)

| Change | Source | Figure |
|--------|--------|--------|
| **Add NHL dataset subsection** (20-year, game-level, Team 52 etc.) with citation | P2.1, P2.3, R1 §2–3 | — |
| **Cite data sources properly** for NBA (API), Premier League (Kaggle), NHL | P2.3, `DATA_AVAILABILITY.md` | — |
| **Add table of N per team/league** — flag short series (N ≈ 38) | P2.2, R6 §2 | `fig4_sample_size.png` |
| **List 14 metrics** explicitly (from `chaos_config.m`) | P2.1, R1 §3 | — |
| **Add Data Availability statement** at end of section or at paper end | P2.3, `DATA_AVAILABILITY.md` | — |

---

## Section 4 — Proposed Methodology (Pages 4–7)

### 4.1 Chaos Detection Framework (Page 5, lines 185–198)

| Change | Source | Figure |
|--------|--------|--------|
| **Replace Fig 1** with the new pipeline flowchart | P1.3, P6.2, R3 §2 | `fig_pipeline.png` |
| Restructure into 4 subsections: Data & metrics → Preprocessing → Nonlinearity & chaos detection → Forecasting | P1.3 | — |

### 4.2 Multistage Workflow (Pages 5–7, lines 199–285)

| Change | Source |
|--------|--------|
| **Add implementation parameters table** after step descriptions (embedding delay τ=1, dim, Schreiber K=1/L=1, cutoff formula, σ=0.5, permutation entropy n/τ) | P1.4, R5 §2 |
| **Add explanation after Eq. (2)** — define each symbol in Terasvirta's equation, one sentence on its role | P6.1, R3 §3 |
| **Add caveat for Keenan's test** — may not detect complex nonlinearity; limited power on short series | P6.3, R3 §4–5 |
| **Add surrogate test description** as a distinct paragraph: AAFT surrogates + permutation entropy comparison → stochastic vs deterministic | P1.2, R5 §1 |
| **Add Test → Role table** (Surrogate/AAFT, Keenan, Ramsey, Terasvirta, Tsay) | P1.2 |

---

## Section 5 — Results (Pages 8–15)

### 5.1 NBA (Page 8, lines 287–301)

| Change | Source |
|--------|--------|
| **State clearly:** "All 30 NBA teams were classified as stochastic; no chaos detected" | P2.1, H2, R6 §1 |
| **Address "Net Attribute" (Eq. 4):** Either justify the composite formally OR state that the pipeline now treats 14 metrics individually (no composite) and align text accordingly | P4.1, R6 §3 |

### 5.2 Football / Premier League (Pages 9–11, lines 339–465)

| Change | Source |
|--------|--------|
| **Add sample size column to Table 2** and flag N ≈ 38 teams with a caveat | P2.2, R6 §2 |
| **Add "counterexamples" subsection:** teams classified chaotic despite expectations, or stochastic despite expectations; brief explanation | P3.1, R5 §3 |

### NEW subsection: 5.X NHL Results

| Change | Source | Figure |
|--------|--------|--------|
| **Add NHL classification results** — Team 52 chaotic (0-1 test), Teams 6/14/19 also analyzed | H3, R6 §1 | — |
| **Add LLE as supporting evidence** — positive LLE consistent with 0-1 test; caveat about white noise overlap | H3, H4 (qualified) | `fig7_LLE_vs_improvement.png` |
| **Add phase space attractor visualizations** | R3 §1, R5 §1 | `fig1_attractor.png` (Team 52), `fig6_attractor_team6.png` (Team 6 counterexample) |

### NEW subsection: 5.X Forecasting by Classification

| Change | Source | Figure |
|--------|--------|--------|
| **Add Chaos vs Random baseline comparison** — 5 teams (52, 6, 14, 19, 24), RMSE from `prove_hypothesis_summary.csv` | P3.2, P5.2, H6 | `fig2_forecast.png`, `fig3_taxonomy.png` |
| **Add forecast-by-classification summary** — mean improvement for chaotic regime vs stochastic regime | P3.2, R6 §4 | `fig5_forecast_by_class.png` |
| **Add league comparison** — NHL (mixed) vs NBA (all stochastic) | R6 §1 | `fig8_league_summary.png` |

### 5.3 Phase Space Plots (Pages 12–14)

| Change | Source | Figure |
|--------|--------|--------|
| **Add Team 52 (NHL) phase space** alongside existing PLA1 | H3 | `fig1_attractor.png` |
| **Add Team 6 phase space** as counterexample (baseline outperforms chaos model) | R5 §3 | `fig6_attractor_team6.png` |

---

## Section 6 — Conclusion (Pages 15–16, lines 579–595)

| Change | Source |
|--------|--------|
| **Soften claims:** "chaos-aware forecasting improves over baseline for some teams" not "accurate long-term predictions" globally | P5.2, R5 §4 |
| **Acknowledge partial validation:** hypothesis partially confirmed; NBA stochastic, NHL shows chaos for some teams; not all sports | P3.1, R6 §1 |
| **Add Limitations paragraph** (or new Section 6.1): single pipeline, short series caution, no real-world validation (betting/coaching), LLE is supporting evidence only, alternative methods may differ | P4.2, P5.1, P6.3 |
| **Add NHL** to future work alongside existing mention of "wider range of sports" | R6 |

---

## Figures to Insert

| Paper location | Figure file | Caption guidance (see `docs/plots_rebuttal.md`) |
|---|---|---|
| Section 4 (replace old Fig 1) | `fig_pipeline.png` | Pipeline flowchart (R3 §2) |
| Section 5 NHL results | `fig1_attractor.png` | Phase space Team 52 |
| Section 5 NHL results | `fig6_attractor_team6.png` | Phase space Team 6 (counterexample) |
| Section 5 Forecasting | `fig2_forecast.png` | Chaos vs baseline, Team 52 last 50 games |
| Section 5 Forecasting | `fig3_taxonomy.png` | % improvement by team (green/grey) |
| Section 5 Dataset | `fig4_sample_size.png` | N per team |
| Section 5 Forecasting | `fig5_forecast_by_class.png` | Mean improvement by regime |
| Section 5 LLE | `fig7_LLE_vs_improvement.png` | LLE by team (supporting evidence) |
| Section 5 or 6 | `fig8_league_summary.png` | NHL vs NBA league comparison |

---

## Priority Order

1. **Abstract + Conclusion** — soften robustness claims, add NHL, qualify
2. **Section 4 (Methods)** — new flowchart, parameters table, Eq. (2) explanation, surrogate description, Keenan caveat
3. **Section 3 (Dataset)** — add NHL, cite sources, list 14 metrics, sample size table
4. **Section 5 (Results)** — NHL results + LLE (qualified), counterexamples, forecast-by-classification with new figures
5. **New Limitations section** — short series, no practical validation, LLE caveat, single pipeline

---

*For exact insert text, see [MANUSCRIPT_REVISION_CONTENT.md](../MANUSCRIPT_REVISION_CONTENT.md) (P1–P6). For figure captions tied to reviewer comments, see [docs/plots_rebuttal.md](plots_rebuttal.md).*
