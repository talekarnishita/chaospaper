# Results folder

Outputs from chaos classification, LLE, prove_hypothesis, and validation scripts. All paths are relative to the project root.

| File | Content |
|------|---------|
| `chaos_classification_results.txt` | Team 52: 0-1 test classification (chaotic). From `run_chaos_octave.m` / `phasechaos.m`. |
| `hypothesis_proof_summary.txt` | Short hypothesis verdicts (H1–H6). See [HYPOTHESIS_PROOF.md](../../HYPOTHESIS_PROOF.md). |
| `LLE_reviewer6_results.txt` | Team 52 LLE + Reviewer #6 chaos sentence. From `compute_LLE_reviewer6.py`. |
| `LLE_test_cases_summary.txt` | Summary of LLE test cases (teams + synthetic). From `run_LLE_test_cases.py`. |
| `LLE_test_synthetic_logistic.txt` | LLE for logistic map (synthetic chaos). |
| `LLE_test_synthetic_white_noise.txt` | LLE for white noise (synthetic stochastic). |
| `LLE_test_team14_FTHG.txt` | LLE for Team 14 FTHG. |
| `LLE_test_team19_FTHG.txt` | LLE for Team 19 FTHG. |
| `LLE_test_team52_FTAG.txt` | LLE for Team 52 FTAG. |
| `LLE_test_team52_FTHG.txt` | LLE for Team 52 FTHG. |
| `LLE_test_team6_FTHG.txt` | LLE for Team 6 FTHG. |
| `LLE_validation_report.txt` | LLE validation: logistic map, white noise, Team 52 vs 0-1 test. From `validate_LLE_results.py`. |
| `prove_hypothesis_results.txt` | Chaos vs Random baseline: full text output per team. From `prove_hypothesis.m`. |
| `prove_hypothesis_summary.csv` | Chaos vs Random: team_id, n, n_test, rmse_chaos, rmse_random, improvement_pct, best_dim, best_delay. |
| `prove_hypothesis_validation_report.txt` | Validation of prove_hypothesis summary (coverage, RMSE, improvement formula). From `validate_prove_hypothesis.py`. |
| `REVIEWER6_SUMMARY.txt` | Reviewer #6 chaos sentence and pointers. |

Full documentation: [docs/README.md](../../docs/README.md), [README.md](../../README.md).
