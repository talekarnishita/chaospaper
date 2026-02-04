# Manuscript Revision Content (Peer Review Response)

This file contains ready-to-insert or adapt text, tables, and figure references for the chaos-theory sports analytics manuscript. Follow the order P1–P6. Source artifacts: [README_TECHNICAL.md](README_TECHNICAL.md), [README.md](README.md), [chaos_config.m](chaos_config.m).

---

## P1: Methodology clarity

### 1.1 Abstract / Introduction — Chaos-aware forecasting model

**Affected:** Abstract; Introduction (last paragraph); Methods (Forecasting).

**Insert (adapt as needed):**

> We apply a multistage pipeline: raw performance metrics are preprocessed (stationarity test, Schreiber denoising), then classified as non-stationary, stochastic, or chaotic (surrogate test plus 0–1 test). Classification informs the forecasting step: for series classified as deterministic (chaotic or periodic), we use [attractor-based reconstruction / a neural forecasting model / hybrid approach]; implementation is provided in `runcode.ipynb` (see Data and Code Availability). We do not combine metrics into a single composite; each of the 14 variables is treated as a separate univariate series and passed through the same pipeline.

**Supporting evidence:** Code reference or appendix figure for the forecast pipeline; one-sentence model description.

---

### 1.2 Methods — Nonlinearity assessment

**Affected:** Methods (Preprocessing / Chaos detection).

**Insert:**

> Nonlinearity and stochasticity are assessed as follows. (1) **Surrogate test:** We generate amplitude-adjusted Fourier transform (AAFT) surrogates and compare permutation entropy of the original series to the surrogate distribution; if the original lies within the surrogate range, the series is classified as stochastic. (2) **Optional nonlinearity tests:** For denoised series we also compute Keenan’s test, Ramsey’s RESET, Teräsvirta’s test, and Tsay’s test (via `NonlinTst`), yielding p-values for nonlinearity; these complement but do not replace the surrogate-based classification. See Table [X] for the mapping of each test to its role.

**Table (insert as Table in manuscript):** Test name → Role

| Test | Role |
|------|------|
| Surrogate (AAFT) + permutation entropy | Stochastic vs deterministic classification |
| Keenan | Nonlinearity (linearity vs nonlinearity) |
| Ramsey (RESET) | Specification / nonlinearity |
| Teräsvirta | Smooth transition nonlinearity |
| Tsay | Threshold-type nonlinearity |

**Source:** [README_TECHNICAL.md](README_TECHNICAL.md) §1; [finalenonlinear.m](finalenonlinear.m).

---

### 1.3 Methods — Multistage workflow and flowchart

**Affected:** Abstract; Methods (structure).

**Restructure Methods** into four subsections:

1. **Data and metrics** — Raw data sources, time span, and the 14 performance metrics (list from [chaos_config.m](chaos_config.m) or README_TECHNICAL §3: FTGoalsFor, FTGoalsAgainst, TeamGS, TeamGC, TeamPoints, MatchWeek, TeamFormPts, WinStreak3, WinStreak5, LossStreak3, LossStreak5, TeamGD, TeamDiffPts, TeamDiffFormPts). Each metric is analysed as a separate univariate time series.
2. **Preprocessing** — Stationarity test (e.g. ADF); Schreiber denoising; optional oversampling check and downsampling.
3. **Nonlinearity and chaos detection** — Surrogate test (AAFT, permutation entropy); if not stochastic, 0–1 test with data-dependent cutoff; classification (non-stationary / stochastic / chaotic / periodic). Optional Keenan/Ramsey/Terasvirta/Tsay on denoised data.
4. **Forecasting** — Description of the forecasting model and how it uses (or does not use) the classification outcome.

**Figure (pipeline flowchart):** Use the flowchart from [README.md](README.md) or [README_TECHNICAL.md](README_TECHNICAL.md) §2 as **Figure 1** (or equivalent). Export the Mermaid block to an image or redraw in the manuscript style. Caption example: “Pipeline: raw data → preprocessing (stationarity, Schreiber denoising) → chaos detection (surrogate test, 0–1 test) → optional nonlinearity tests → forecasting.”

---

### 1.4 Methods — Critical parameters (implementation table)

**Affected:** Methods (Chaos detection; Preprocessing).

**Insert** a short subsection “Implementation parameters” or a table (e.g. Supplementary Table S1) with the following. Source: [README_TECHNICAL.md](README_TECHNICAL.md) §1.

| Parameter | Symbol / name | Value or formula | Note |
|-----------|----------------|------------------|------|
| Embedding delay | τ | 1 (default) | Used in phase-space reconstruction (e.g. inside Schreiber denoising). |
| Embedding dimension | dim | 2 (default in phase-space); K+L+1 = 3 in Schreiber (K=1, L=1) | FNN is used only for PPS/TS surrogate generation, not in the main chaos classification path. |
| Schreiber denoising | K, L, r, repeat | K=1, L=1, r=std(x), repeat=1; then end trimming y(10:end-10) | Geometrical noise reduction (Schreiber 1993). |
| K-statistic cutoff | cutoff | 0.00005455×N + 0.422, capped at 0.99 | Data-length-dependent; N = series length. |
| 0–1 test noise (Dawes–Freeland) | σ | 0.5 | Improves distinction chaotic vs strange non-chaotic. |
| Permutation entropy (output) | n, τ | n=5, τ=1 | For reported entropy. Surrogate comparison uses n=8, τ=1. |

**Important:** In the main classification path, embedding dimension is *not* set by False Nearest Neighbours; the 0–1 test is used without phase-space reconstruction. FNN is used only inside the surrogate generator when the method is PPS or TS.

---

## P2: Dataset inadequacy

### 2.1 NBA outcome and chaotic vs non-stationary

**Affected:** Results; Discussion.

**Insert in Results:**

> All 30 NBA teams were classified as stochastic (or non-chaotic) across the metrics and pipeline settings used. No team–metric pair was classified as chaotic under the 0–1 test and surrogate criterion.

**Insert in Discussion:**

> The absence of chaotic classification in the NBA data may reflect (a) a genuine lack of low-dimensional chaos in the chosen metrics over the sample period, (b) sensitivity to sample size or denoising, or (c) the conservative nature of the surrogate test. We distinguish “stochastic” (original permutation entropy within the surrogate distribution) from “non-stationary” (failure of the stationarity test); classification is performed in that order so that non-stationary series are excluded before surrogate testing. Thus, “stochastic” here means stationary but consistent with a linear stochastic process under the AAFT null.

**Supporting evidence:** Summary table: League | N teams | N chaotic | N stochastic | N non-stationary (fill with your counts).

---

### 2.2 Sample size (Premier League, minimum N)

**Affected:** Methods (Data); Results; Limitations.

**Insert in Methods (Data):**

> Series length N varies by team and league (e.g. Premier League teams have up to 38 match-weeks per season). Where N is small, we report it explicitly; the K-statistic cutoff is data-length-dependent (see Implementation parameters), and classification should be interpreted with caution for short series (see Limitations).

**Insert in Results:** Report N per team or per league in a table (e.g. “N (observations per team)” column).

**Insert in Limitations:**

> Chaos detection and surrogate tests require adequate series length; recommendations in the literature vary (e.g. [cite 0–1 test or surrogate papers]). Our cutoff is linear in N with a cap. For short series (e.g. N ≈ 38), false positives or false negatives in chaos vs stochastic classification cannot be ruled out.

**Supporting evidence:** Table of N per team or league; 1–2 citations on minimum N for the 0–1 test or surrogate tests.

---

### 2.3 Dataset citations and data availability

**Affected:** Methods (Data); Data availability.

**Insert in Methods (Data):**

> Data were obtained from [NBA source, e.g. official stats API or dataset citation] and [Premier League / football source]. Time span: [start year]–[end year]. Variables (14 per team): FTGoalsFor, FTGoalsAgainst, TeamGS, TeamGC, TeamPoints, MatchWeek, TeamFormPts, WinStreak3, WinStreak5, LossStreak3, LossStreak5, TeamGD, TeamDiffPts, TeamDiffFormPts (see also README_TECHNICAL §3 and repository `chaos_config.m`).

**Data availability statement (template):**

> The data that support the findings of this study are available from [source]. Processed series and classification results are available from the authors upon reasonable request. Code is available at [repository URL or DOI].

---

## P3: Hypothesis validation

### 3.1 Classification outcomes and counterexamples

**Affected:** Results; Discussion.

**Insert subsection “Classification outcomes and counterexamples”:**

> We report classification outcomes by league and, where relevant, by team. Table [X] summarises counts (chaotic / stochastic / non-stationary). [If applicable:] Teams [list] were classified as chaotic for at least one metric, contrary to [initial hypothesis / league-level expectation]; possible explanations include [data length, choice of metric, league structure]. Teams [list] were classified as stochastic despite [hypothesis]; we discuss implications in Discussion.

**Supporting evidence:** Table or list of “counterexample” teams with classification and a short suggested explanation.

---

### 3.2 Forecasting performance by classification

**Affected:** Results (Forecasting); Methods (Evaluation).

**Insert in Methods (Evaluation):**

> We evaluate forecasting performance using [e.g. MAE, RMSE, or directional accuracy] over [horizon]. We compare (1) a baseline ([e.g. naive forecast or AR model]), (2) forecasts conditioned on chaos classification (e.g. separate models or features for chaotic vs stochastic teams), and (3) [any other variant]. Results are reported by classification (chaotic vs stochastic) where sample size permits.

**Insert subsection “Forecasting performance by classification”:**

> Table [X] reports [MAE/RMSE/directional accuracy] by classification (chaotic vs stochastic) and versus the baseline. [One sentence: e.g. “Chaos-based forecasting [outperformed / did not outperform] the baseline on average; the small number of chaotic teams limits generalisation.”]

**Supporting evidence:** Table: Classification (chaotic / stochastic) | Metric (e.g. MAE) | Baseline metric | Note. Forecast results for at least two teams (ideally one chaotic, one stochastic) and a baseline.

---

## P4: Theoretical justification

### 4.1 Feature engineering (Net Attribute / Eq. 4)

**Affected:** Methods (Data / Preprocessing); Discussion.

**If using per-metric analysis only (no composite formula):**

> We do not combine the 14 metrics into a single composite index. Each metric is treated as a separate univariate time series and passed through the same preprocessing and chaos-detection pipeline. This multi-metric design uses domain-standard performance and outcome variables, avoids arbitrary weighting, and is appropriate for small or moderate samples where a single composite could overfit (see README_TECHNICAL §3).

**If using a composite “Net Attribute” or “Eq. 4”:**

> We define the composite performance index (Eq. 4) as [formal equation]. Rationale: [e.g. dimensionality reduction for small samples, or citation]. Sensitivity: we varied [weighting or formula] and report the impact on classification rates in Supplementary [X].

**Supporting evidence:** One paragraph on rationale; optional sensitivity table (alternative formulations vs classification rate).

---

### 4.2 Alternative formulations and theoretical foundation

**Affected:** Discussion; Limitations.

**Insert in Discussion:**

> Our pipeline uses a single choice of embedding (default τ=1, dim=2 or Schreiber K+L+1=3), denoising (Schreiber), and surrogate (AAFT). Alternative embedding methods (e.g. FNN for dimension, first zero of autocorrelation for delay), other denoising methods, or other surrogate tests may yield different classifications; we did not systematically explore these. The link between low-dimensional chaos in an underlying dynamical system and the observed univariate series is indirect; our 0–1 test and surrogate framework address the latter.

**Insert in Limitations:**

> We use a single pipeline; alternatives may yield different chaos/stochastic classifications. Theoretical justification for chaos in sports performance remains limited; our results are conditional on the chosen metrics and tests.

---

## P5: Practical validation

### 5.1 Real-world validation

**Affected:** Discussion; Limitations.

**Insert in Limitations:**

> Real-world validation (e.g. betting accuracy, coaching decisions, or match outcome prediction) was not performed. Future work could include backtesting or expert evaluation to assess practical utility.

---

### 5.2 Forecasting for multiple teams and baseline comparison

**Affected:** Results (Forecasting); Discussion.

**Insert:**

> We extended forecasting to [at least two teams, ideally one chaotic and one stochastic]. Table [X] compares forecast accuracy (e.g. MAE/RMSE) with and without using chaos classification. [One sentence conclusion:] Chaos-based forecasting [does / does not] outperform the baseline in this sample; [brief caveat on sample size or generalisation].

**Supporting evidence:** Forecast results for 2+ teams; comparison with baseline; short conclusion on utility of chaos classification.

---

## P6: Documentation gaps

### 6.1 Equation 2

**Affected:** Methods.

**Insert** immediately after Equation 2:

> where [define each symbol]. This equation describes [e.g. the 0–1 test transformation / the embedding map]. [One sentence on its role in the pipeline.]

**Supporting evidence:** Nomenclature list or in-text definitions for all symbols in Eq. 2.

---

### 6.2 Pipeline flowchart figure

**Affected:** Methods.

**Insert:** Use the pipeline flowchart from [README.md](README.md) or [README_TECHNICAL.md](README_TECHNICAL.md) §2 as a manuscript figure (e.g. Figure 1). If “chaos sensitivity” refers to parameter sensitivity, add a small table or figure: e.g. cutoff or σ vs classification outcome (optional).

---

### 6.3 Keenan’s test limitations

**Affected:** Methods (Nonlinearity tests); Limitations.

**Insert in Methods** when introducing Keenan (and Teräsvirta, Tsay):

> Keenan’s test is designed to detect nonlinearity in a linear baseline; interpretation may be limited for highly complex nonlinearity or very short series. Teräsvirta and Tsay tests address smooth and threshold-type nonlinearity respectively.

**Insert in Limitations:**

> For short series, Keenan (and related) tests may have limited power; negative results do not rule out nonlinearity.

---

## Artifacts quick reference

| Artifact | Use |
|----------|-----|
| [README_TECHNICAL.md](README_TECHNICAL.md) §1 | Methods: implementation parameters table or supplementary. |
| [README_TECHNICAL.md](README_TECHNICAL.md) §2 | Methods: pipeline flowchart figure. |
| [README_TECHNICAL.md](README_TECHNICAL.md) §3 | Methods/Discussion: feature-engineering rationale; Eq. 4 clarification. |
| [README.md](README.md) | Methods: column list, configuration; same flowchart source. |
| [chaos_config.m](chaos_config.m) | List of 14 metrics and default paths. |

---

*End of revision content. Apply in priority order P1→P6 and tick off roadmap rows as done.*
