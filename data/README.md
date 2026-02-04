# Data folder

- **`raw/`** — Raw team CSV files (used by `phasechaos.m` and `process_data_folder.py`).
- **`processed/`** — Cleaned CSVs from `process_data_folder.py` (columns: Date, HomeTeam, AwayTeam, FTHG, FTAG).
- **`results/`** — Chaos classification results from `phasechaos.m` (e.g. `*_results.txt`).
- **`denoised/`** — Denoised CSVs from `phasechaos.m` (input for `finalenonlinear.m`).
- **`nonlinear_results/`** — Nonlinearity test results from `finalenonlinear.m`.

Place your raw team CSV files in `raw/` (or set paths in `chaos_config.m`).
