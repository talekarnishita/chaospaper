#!/usr/bin/env python3
"""
Run multiple LLE test cases for proof: NHL teams/metrics + synthetic chaotic/stochastic.
Saves each result to data/results/ and writes a summary. Requires: numpy.
"""
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent
CSV_PATH = PROJECT_ROOT / "data" / "processed" / "clean_game.csv"
RESULTS_DIR = PROJECT_ROOT / "data" / "results"
LLE_CHAOS_THRESHOLD = 0.0

# Import from main LLE script
sys.path.insert(0, str(PROJECT_ROOT))
from compute_LLE_reviewer6 import load_team_series, compute_LLE


def synthetic_logistic_map(n=2000, r=4.0, x0=0.1):
    """Logistic map x_{n+1} = r*x*(1-x). r=4 is chaotic (LLE ~0.693)."""
    import numpy as np
    x = x0
    series = [x]
    for _ in range(n - 1):
        x = r * x * (1 - x)
        series.append(x)
    return series


def synthetic_white_noise(n=2000, seed=42):
    """Gaussian white noise (stochastic). Expected LLE ≈ 0 or negative."""
    import numpy as np
    np.random.seed(seed)
    return list(np.random.randn(n))


def run_one_nhl(csv_path, team_id, column, case_name):
    """Load NHL team series, compute LLE, return (lle, n, lines)."""
    series, n = load_team_series(csv_path, team_id, column)
    if n < 100:
        return None, n, ["SKIP: too few points ({})".format(n)]
    lle = compute_LLE(series)
    n_str = "N = {} games".format(n) if n < 1000 else "N > 1000 games"
    result = "Chaos (LLE > 0)" if lle > LLE_CHAOS_THRESHOLD else "Stochastic (LLE ≤ 0)"
    lines = [
        "Test case: {}".format(case_name),
        "Source: NHL clean_game.csv | Team {} | {}".format(team_id, column),
        "Games: {}".format(n),
        "",
        "Largest Lyapunov Exponent (LLE): {:.4f}".format(lle),
        "Result: {}".format(result),
        "",
        "--- Reviewer #6 (if chaos) ---",
        "Analysis of the 20-year NHL dataset (Team {}, {}) revealed a positive "
        "Lyapunov exponent (+{:.2f}), confirming that our chaos-aware framework "
        "generalizes to continuous sports.".format(team_id, n_str, lle) if lle > 0 else "(N/A)",
        "",
        "--- Reviewer #6 (if stochastic) ---",
        "The extended 20-year analysis confirmed the stochastic nature of the sport, "
        "consistent with our NBA findings.",
    ]
    return lle, n, lines


def run_one_synthetic(kind, n, case_name):
    """Generate synthetic series, compute LLE, return (lle, n, lines)."""
    if kind == "logistic":
        series = synthetic_logistic_map(n=n)
        expected = "Chaos (LLE ~0.69)"
    elif kind == "white_noise":
        series = synthetic_white_noise(n=n)
        expected = "Stochastic (LLE ≈ 0 or negative)"
    else:
        return None, 0, ["Unknown synthetic: {}".format(kind)]
    lle = compute_LLE(series)
    result = "Chaos (LLE > 0)" if lle > LLE_CHAOS_THRESHOLD else "Stochastic (LLE ≤ 0)"
    lines = [
        "Test case: {}".format(case_name),
        "Source: Synthetic | {} | n={}".format(kind, n),
        "Expected: {}".format(expected),
        "",
        "Largest Lyapunov Exponent (LLE): {:.4f}".format(lle),
        "Result: {}".format(result),
        "",
        "Proof: {} series yields LLE {:.4f} ({}).".format(
            kind.replace("_", " "), lle, "consistent with chaos" if lle > 0 else "consistent with stochastic"
        ),
    ]
    return lle, n, lines


def main():
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)

    # Define all test cases: (case_id, description, runner_args)
    cases = [
        # NHL: Team 52 (main rebuttal team)
        ("team52_FTHG", "NHL Team 52 FTHG (home goals)", ("nhl", 52, "FTHG")),
        ("team52_FTAG", "NHL Team 52 FTAG (away goals)", ("nhl", 52, "FTAG")),
        # NHL: High-game teams (N > 1000)
        ("team6_FTHG", "NHL Team 6 FTHG", ("nhl", 6, "FTHG")),
        ("team14_FTHG", "NHL Team 14 FTHG", ("nhl", 14, "FTHG")),
        ("team19_FTHG", "NHL Team 19 FTHG", ("nhl", 19, "FTHG")),
        # Synthetic: known chaotic
        ("synthetic_logistic", "Logistic map r=4 (chaotic)", ("synthetic", "logistic", 2000)),
        # Synthetic: known stochastic
        ("synthetic_white_noise", "White noise (stochastic)", ("synthetic", "white_noise", 2000)),
    ]

    if not CSV_PATH.is_file():
        print("ERROR: CSV not found:", CSV_PATH, file=sys.stderr)
        sys.exit(1)

    summary_rows = []
    for case_id, description, args in cases:
        if args[0] == "nhl":
            _, team_id, column = args
            lle, n, lines = run_one_nhl(CSV_PATH, team_id, column, description)
        else:
            _, kind, n_syn = args
            lle, n, lines = run_one_synthetic(kind, n_syn, description)

        out_text = "\n".join(lines)
        out_file = RESULTS_DIR / "LLE_test_{}.txt".format(case_id)
        out_file.write_text(out_text, encoding="utf-8")
        print("Saved:", out_file.name)

        if lle is not None:
            result = "Chaos" if lle > LLE_CHAOS_THRESHOLD else "Stochastic"
            summary_rows.append((case_id, description, n, lle, result))

    # Write summary
    summary_lines = [
        "LLE Test Cases Summary",
        "=======================",
        "",
        "Case ID                  | N      | LLE      | Result",
        "-------------------------|--------|----------|------------",
    ]
    for case_id, desc, n, lle, result in summary_rows:
        summary_lines.append("{:25} | {:6} | {:8.4f} | {}".format(case_id, n, lle, result))
    summary_lines.extend([
        "",
        "Interpretation: LLE > 0 => Chaos; LLE ≤ 0 => Stochastic.",
        "",
        "Individual results: data/results/LLE_test_<case_id>.txt",
    ])
    summary_file = RESULTS_DIR / "LLE_test_cases_summary.txt"
    summary_file.write_text("\n".join(summary_lines), encoding="utf-8")
    print("Saved:", summary_file.name)
    print("")
    print(summary_file.read_text(encoding="utf-8"))


if __name__ == "__main__":
    main()
