# Data folder

- **`raw/`** — Raw team CSV files (used by `phasechaos.m` and `process_data_folder.py`).
- **`processed/`** — Cleaned CSVs from `process_data_folder.py` (columns: Date, HomeTeam, AwayTeam, FTHG, FTAG).
- **`results/`** — Chaos classification from `phasechaos.m`; LLE outputs (`LLE_reviewer6_results.txt`, `LLE_test_*.txt`, `LLE_validation_report.txt`); prove_hypothesis results (`prove_hypothesis_results.txt`, `prove_hypothesis_summary.csv`, `prove_hypothesis_validation_report.txt`); `hypothesis_proof_summary.txt`, `REVIEWER6_SUMMARY.txt`. See [results/README.md](results/README.md) or project root [README.md](../README.md) for the full list.
- **`denoised/`** — Denoised CSVs from `phasechaos.m` (input for `finalenonlinear.m`).
- **`nonlinear_results/`** — Nonlinearity test results from `finalenonlinear.m`.

Place your raw team CSV files in `raw/` (or set paths in `chaos_config.m`).
