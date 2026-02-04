#!/usr/bin/env python3
"""
Validate prove_hypothesis results: RMSE sanity, improvement formula, test-case coverage.
Reads data/results/prove_hypothesis_summary.csv (written by prove_hypothesis.m).
Writes data/results/prove_hypothesis_validation_report.txt.
"""
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent
RESULTS_DIR = PROJECT_ROOT / "data" / "results"
SUMMARY_CSV = RESULTS_DIR / "prove_hypothesis_summary.csv"
REPORT_PATH = RESULTS_DIR / "prove_hypothesis_validation_report.txt"

# Expected team IDs from prove_hypothesis.m team_list
EXPECTED_TEAMS = [52, 6, 14, 19, 24]
IMPROVEMENT_TOL = 0.02  # allow 0.02% rounding in improvement_pct


def parse_summary():
    """Parse prove_hypothesis_summary.csv; return list of dicts."""
    if not SUMMARY_CSV.is_file():
        return None
    rows = []
    with open(SUMMARY_CSV, encoding="utf-8") as f:
        header = f.readline().strip().split(",")
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split(",")
            if len(parts) < 8:
                continue
            rows.append({
                "team_id": int(parts[0]),
                "n": int(parts[1]),
                "n_test": int(parts[2]),
                "rmse_chaos": float(parts[3]),
                "rmse_random": float(parts[4]),
                "improvement_pct": float(parts[5]),
                "best_dim": int(parts[6]),
                "best_delay": int(parts[7]),
            })
    return rows


def improvement_from_rmse(rmse_random, rmse_chaos):
    if rmse_random <= 0:
        return 0.0
    return (rmse_random - rmse_chaos) / rmse_random * 100.0


def run_validation():
    lines = []
    lines.append("Prove Hypothesis — Validation Report")
    lines.append("=" * 60)
    lines.append("")

    if not SUMMARY_CSV.is_file():
        lines.append("SUMMARY FILE NOT FOUND: {}".format(SUMMARY_CSV))
        lines.append("Run first: octave prove_hypothesis.m")
        return "\n".join(lines)

    rows = parse_summary()
    if not rows:
        lines.append("SUMMARY FILE EMPTY or unparseable.")
        return "\n".join(lines)

    rmse_ok = True
    formula_ok = True

    # 1. Test-case coverage
    lines.append("1. TEST-CASE COVERAGE")
    lines.append("-" * 50)
    found_ids = {r["team_id"] for r in rows}
    missing = set(EXPECTED_TEAMS) - found_ids
    extra = found_ids - set(EXPECTED_TEAMS)
    if not missing and not extra:
        lines.append("   All expected teams present: {}.".format(EXPECTED_TEAMS))
        lines.append("   VALID.")
    else:
        if missing:
            lines.append("   MISSING teams: {}.".format(sorted(missing)))
        if extra:
            lines.append("   EXTRA teams: {}.".format(sorted(extra)))
        lines.append("   CHECK.")
    lines.append("")

    # 2. RMSE sanity
    lines.append("2. RMSE SANITY (positive, finite)")
    lines.append("-" * 50)
    rmse_ok = True
    for r in rows:
        if r["rmse_chaos"] <= 0 or r["rmse_random"] <= 0:
            lines.append("   Team {}: invalid RMSE (chaos={}, random={}).".format(
                r["team_id"], r["rmse_chaos"], r["rmse_random"]))
            rmse_ok = False
    if rmse_ok:
        lines.append("   All RMSE values positive and finite.")
        lines.append("   VALID.")
    else:
        lines.append("   FAIL.")
    lines.append("")

    # 3. Improvement formula consistency
    lines.append("3. IMPROVEMENT FORMULA (improvement_pct = (Random - Chaos) / Random * 100)")
    lines.append("-" * 50)
    formula_ok = True
    for r in rows:
        computed = improvement_from_rmse(r["rmse_random"], r["rmse_chaos"])
        diff = abs(r["improvement_pct"] - computed)
        if diff > IMPROVEMENT_TOL:
            lines.append("   Team {}: stored={:.4f}%, computed={:.4f}%, diff={:.4f}.".format(
                r["team_id"], r["improvement_pct"], computed, diff))
            formula_ok = False
    if formula_ok:
        lines.append("   Stored improvement_pct matches formula within {}%.".format(IMPROVEMENT_TOL))
        lines.append("   VALID.")
    else:
        lines.append("   CHECK (rounding or script mismatch).")
    lines.append("")

    # 4. Summary table
    lines.append("4. RESULTS SUMMARY")
    lines.append("-" * 50)
    lines.append("   {:>8} {:>6} {:>6} {:>10} {:>10} {:>10} {:>6} {:>6}".format(
        "team_id", "n", "test", "rmse_chaos", "rmse_random", "improve%", "dim", "delay"))
    for r in rows:
        lines.append("   {:>8} {:>6} {:>6} {:>10.4f} {:>10.4f} {:>10.2f} {:>6} {:>6}".format(
            r["team_id"], r["n"], r["n_test"], r["rmse_chaos"], r["rmse_random"],
            r["improvement_pct"], r["best_dim"], r["best_delay"]))
    lines.append("")

    # 5. Verdict
    lines.append("5. VALIDATION VERDICT")
    lines.append("-" * 50)
    all_ok = rmse_ok and formula_ok and not missing
    if all_ok:
        lines.append("   PASS: Coverage, RMSE sanity, and improvement formula checks passed.")
    else:
        lines.append("   CHECK: One or more checks failed (see above).")
    lines.append("")

    return "\n".join(lines)


def main():
    report = run_validation()
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(report, encoding="utf-8")
    print(report)
    print("(Saved to {})".format(REPORT_PATH))


if __name__ == "__main__":
    main()
