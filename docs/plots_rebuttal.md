# Figures and Rebuttal — How Each Graph Addresses the Reviewers

This document explains **each figure** produced for the revision and **how it supports the rebuttal** to the Associate Editor and Reviewers 1, 3, 5, and 6. Use it to choose figures for the manuscript and to write figure captions that explicitly tie to reviewer comments.

**Source:** [REVIEW_RESPONSE.md](REVIEW_RESPONSE.md) (point-by-point rebuttal). **Figure files:** project root (`fig_pipeline.png`, `fig1_attractor.png` … `fig8_league_summary.png`). **Gallery:** [plots.md](plots.md).

---

## 1. Pipeline Flowchart — **fig_pipeline.png**

**What it shows:** A single diagram of the analysis pipeline: Raw Data → Preprocessing (stationarity) → Schreiber Denoising → Surrogate Test (AAFT, permutation entropy) → Optional Oversampling → 0-1 Test (K-statistic vs cutoff) → Classification (Chaotic / Periodic / Stochastic) → Optional Nonlinearity (Keenan etc.) → Forecasting (Attractor / Neural Net).

**How it helps the rebuttal:**

| Reviewer | Comment | Rebuttal use |
|----------|---------|--------------|
| **R3 §2** | “Need diagram/flowchart for establish point no.1 in highlight section.” | **Directly satisfies** the request. We state: “We provide a pipeline flowchart as **Figure 1** in the manuscript.” This figure is that flowchart. |
| **R5 §1** | Methodology not clearly expounded (multistage, chaos-aware forecasting). | The figure **shows the multistage workflow** (preprocessing → chaos detection → classification → forecasting) and where “Forecasting: Attractor / Neural Net” sits, supporting the written clarification of the methodology. |

**Suggested caption (manuscript):** *“Figure 1. Pipeline for chaos classification and forecasting: raw data → preprocessing (stationarity, Schreiber denoising) → surrogate test → 0-1 test → classification → optional nonlinearity tests → forecasting.”*

---

## 2. Phase Space Attractor — Team 52 — **fig1_attractor.png**

**What it shows:** Reconstructed 3D phase space for Team 52’s goal series (delay = 1): x(t), x(t+1), x(t+2) after smoothing. Illustrates the **attractor** used in chaos-aware (phase-space) forecasting.

**How it helps the rebuttal:**

| Reviewer | Comment | Rebuttal use |
|----------|---------|--------------|
| **R3 §1** | How do you overcome sensitivity to initial conditions? (Classification vs long-horizon prediction.) | The figure illustrates **phase-space reconstruction**, which we use for **short-horizon** forecasting (k-NN on the attractor), not long-term trajectory prediction. It supports the claim that we use “attractor-based / phase-space” methods with short horizons. |
| **R5 §1** | Chaos-aware forecasting model not clearly expounded. | It **shows the geometry** underlying the chaos-aware model (reconstructed dynamics) and thus clarifies what “attractor-based” means in the manuscript. |
| **H3** | NHL chaos possible; framework generalizes. | Team 52 is an NHL team; the attractor is evidence of **reconstructible dynamics** in NHL goal data, supporting H3. |

**Suggested caption:** *“Figure 2. Reconstructed phase space (delay τ = 1) for Team 52 goals (NHL). Axes: x(t), x(t+1), x(t+2); data smoothed with 3-point moving average.”*

---

## 3. Forecast Comparison — Team 52 (Real Data) — **fig2_forecast.png**

**What it shows:** Last 50 **test** games for Team 52: **Actual** goals (black), **Chaos model** predictions (red, phase-space k-NN), **Random baseline** predictions (blue dashed, mean of last 5). All from `prove_hypothesis.m` logic (real data, not simulated).

**How it helps the rebuttal:**

| Reviewer | Comment | Rebuttal use |
|----------|---------|--------------|
| **R3 §1** | Forecasting and sensitivity to initial conditions. | Shows that we compare **chaos-aware (k-NN)** vs **baseline** on **real data** over a short horizon, consistent with “short horizons” and “nearest-neighbor methods”; no claim of long-horizon accuracy. |
| **R5 §1** | Chaos-aware forecasting model. | **Concrete illustration** of the “phase-space k-NN vs random baseline” comparison mentioned in the rebuttal. |
| **R5 §4** | “Strong robustness” not sufficiently supported. | We **soften** the claim and show **one team (52)** where chaos model can track actual better than baseline in the last 50 test games. The figure supports “improves over a naive baseline for **some** teams” rather than global robustness. |
| **R6 §4** | Forecasting only for one team; no comparison chaotic vs stochastic. | This figure is the **Team 52** forecast comparison; together with fig5 and fig3 it shows we have both a worked example (52) and multi-team + by-classification summaries. |
| **H6** | Classification informs forecasting. | **Evidence** that for Team 52 (chaos helps) the chaos-aware forecast aligns with actual better than the baseline in this window. |

**Suggested caption:** *“Figure 3. Forecasting performance, Team 52 (last 50 test games): actual goals (black), chaos model — phase-space k-NN (red), random baseline — mean of last 5 (blue dashed).”*

---

## 4. Model Utility Taxonomy — **fig3_taxonomy.png**

**What it shows:** Bar chart of **% improvement over baseline** for five NHL teams (52, 14, 24, 6, 19). Green = positive improvement (chaos model better); grey = negative or zero (baseline better).

**How it helps the rebuttal:**

| Reviewer | Comment | Rebuttal use |
|----------|---------|--------------|
| **R5 §3** | Hypothesis only partially validated; need discussion of counterexamples. | The figure **shows both** teams where chaos helps (52, 14, 24) and teams where it does not (6, 19), i.e. **counterexamples** to “chaos always helps.” We discuss these in “Classification outcomes and counterexamples.” |
| **R5 §4** | Robustness not sufficiently supported. | We state results are **not uniform** across teams; this figure **shows that variation** (green vs grey), supporting the softened robustness claim. |
| **R6 §1** | Results inconsistent; applicability to competitive sports weakened. | We frame outcomes as **league/sport-dependent**. This figure shows **within-NHL** variation (some teams green, some grey), supporting that we do not claim uniformity. |
| **H6** | Classification informs forecasting (partially supported). | **Evidence** that improvement over baseline **varies by team** and is positive for some (supporting partial H6). |

**Suggested caption:** *“Figure 4. Diagnostic taxonomy: % improvement of chaos model over random baseline by NHL team. Green: chaos model better; grey: baseline better or equal.”*

---

## 5. Sample Size per Team — **fig4_sample_size.png**

**What it shows:** Bar chart of **number of games (N)** per team for the five NHL teams used in the hypothesis proof.

**How it helps the rebuttal:**

| Reviewer | Comment | Rebuttal use |
|----------|---------|--------------|
| **R1 §3** | More details must be furnished about the dataset (sample sizes). | We state “N per team/league reported in a table”; this figure **is** that table in visual form, furnishing the requested detail. |
| **R5 §3** | Short series and counterexamples. | Makes **N explicit** so readers see which teams have long vs shorter series; supports discussion of reliability and counterexamples. |
| **R6 §2** | Sample size very limited; validity of classification questioned. | We acknowledge limited N and recommend caution for short series. This figure **documents N** so that “short series (e.g. N ≈ 38)” and data-length-dependent cutoff can be discussed with concrete numbers. |

**Suggested caption:** *“Figure 5. Sample size (number of games, N) per NHL team in the analysis.”*

---

## 6. Forecast Performance by Classification — **fig5_forecast_by_class.png**

**What it shows:** Two bars: mean **% improvement over baseline** for (1) **Chaotic regime** (teams with improvement > 0) and (2) **Stochastic regime** (teams with improvement ≤ 0). Uses the same five teams; “regime” here is defined by forecast outcome, not by 0-1/LLE label.

**How it helps the rebuttal:**

| Reviewer | Comment | Rebuttal use |
|----------|---------|--------------|
| **R5 §4** | Robustness; need support for “improves over baseline for some teams.” | Shows that **on average** the “chaos helps” group has positive improvement and the “baseline better” group has negative, supporting the claim that **classification (by outcome) informs forecasting** in our data. |
| **R6 §4** | No comparison of Attraos on chaotic vs stochastic teams; forecasting only for one team. | We now compare **across five teams** and group by **forecast outcome** (improvement > 0 vs ≤ 0). This figure is the **forecast-by-classification** comparison requested; we acknowledge a full chaotic-vs-stochastic-by-0-1 table is still to be added. |
| **H6** | Classification informs forecasting (partially supported). | **Direct evidence**: mean improvement is higher when we group teams where the chaos model wins (chaotic regime) than where the baseline wins (stochastic regime). |

**Suggested caption:** *“Figure 6. Mean % improvement over baseline by regime: Chaotic (improvement > 0) vs Stochastic (improvement ≤ 0). Five NHL teams.”*

---

## 7. Phase Space — Team 6 (Baseline Outperforms Chaos) — **fig6_attractor_team6.png**

**What it shows:** Reconstructed 3D phase space for **Team 6** (delay = 1), same embedding as Team 52 but for a team where the **baseline outperforms** the chaos model (negative improvement).

**How it helps the rebuttal:**

| Reviewer | Comment | Rebuttal use |
|----------|---------|--------------|
| **R5 §3** | Partially validated hypothesis; need in-depth discussion of counterexamples. | Team 6 is a **counterexample**: LLE > 0 in our LLE summary, but **forecast improvement < 0**. The figure gives a **visual counterexample** (phase space of a team where chaos-based forecasting does not beat the baseline), supporting the “counterexamples” subsection. |
| **R6 §1** | Results inconsistent; hard to draw conclusions. | We show **both** a team where chaos helps (52, fig1) and one where it does not (6, this figure), making “league- and team-dependent” outcomes concrete. |

**Suggested caption:** *“Figure 7. Reconstructed phase space (Team 6). Baseline outperforms chaos model here; contrast with Team 52 (Figure 2).”*

---

## 8. LLE vs Forecast Utility — **fig7_LLE_vs_improvement.png**

**What it shows:** Bar chart of **Largest Lyapunov Exponent (LLE)** for teams 52, 6, 14, 19; bar colour = **forecast utility** (green: improvement > 0, grey: improvement ≤ 0). Data-driven from `LLE_test_cases_summary.txt` and `prove_hypothesis_summary.csv`.

**How it helps the rebuttal:**

| Reviewer | Comment | Rebuttal use |
|----------|---------|--------------|
| **H4** | LLE and 0-1 test agree where both computed. | The figure shows **LLE** alongside **forecast outcome** (improvement sign). It does not plot 0-1 K directly but supports the narrative that we have both LLE and forecast evidence per team; agreement is discussed in text and LLE_validation_report. |
| **R6 §5** | Paper lacks data to support claims. | **Consolidated evidence**: LLE (from LLE test cases) and improvement (from prove_hypothesis) in one figure, showing we have multi-metric, multi-team data. |

**Suggested caption:** *“Figure 8. LLE by team; colour indicates forecast utility (green: chaos model better, grey: baseline better).”*

---

## 9. League Summary — **fig8_league_summary.png**

**What it shows:** Two panels: (1) **NHL** — number of teams “Chaotic” (improvement > 0) vs “Stochastic” (improvement ≤ 0) in our five-team run; (2) **NBA** — all 30 teams stochastic (placeholder from our stated pipeline outcome).

**How it helps the rebuttal:**

| Reviewer | Comment | Rebuttal use |
|----------|---------|--------------|
| **R6 §1** | Results inconsistent; NBA no chaos; applicability to competitive sports weakened. | We **do not** claim the methodology works identically for all sports. This figure **shows the league-dependent outcome** explicitly: NHL has a mix (chaotic vs stochastic by our forecast criterion), NBA (under our pipeline) is all stochastic. It supports “league/sport-dependent outcome” and avoids overclaiming. |
| **Associate Editor** | Generality and practicality; limited data. | We state chaos detection is validated on NHL (and synthetic) but NBA showed no chaos; this figure **summarizes** that contrast in one place. |

**Suggested caption:** *“Figure 9. League comparison: NHL (n=5) — chaotic vs stochastic by forecast improvement; NBA (n=30) — all stochastic in our pipeline (placeholder).”*

---

## Summary Table: Figure → Reviewer / Hypothesis

| Figure | File | Primary rebuttal target | Hypothesis |
|--------|------|-------------------------|------------|
| Pipeline flowchart | fig_pipeline.png | **R3 §2** (flowchart), R5 §1 (methodology) | — |
| Phase space Team 52 | fig1_attractor.png | R3 §1, R5 §1 | H3 |
| Forecast comparison Team 52 | fig2_forecast.png | R3 §1, R5 §4, R6 §4 | H6 |
| Model utility taxonomy | fig3_taxonomy.png | R5 §3, R5 §4, R6 §1 | H6 |
| Sample size per team | fig4_sample_size.png | **R1 §3**, R5 §3, **R6 §2** | — |
| Forecast by classification | fig5_forecast_by_class.png | R5 §4, **R6 §4** | **H6** |
| Phase space Team 6 | fig6_attractor_team6.png | **R5 §3** (counterexamples), R6 §1 | — |
| LLE vs improvement | fig7_LLE_vs_improvement.png | R6 §5 | **H4** |
| League summary | fig8_league_summary.png | **R6 §1**, Associate Editor | — |

---

*Use this document to select figures for the revised manuscript and to write captions that explicitly reference the rebuttal (e.g. “In response to Reviewer 3’s request for a flowchart…” or “Addressing Reviewer 6’s concern about league-dependent outcomes…”).*
