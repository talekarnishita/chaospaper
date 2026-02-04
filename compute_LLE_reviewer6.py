#!/usr/bin/env python3
"""
Compute Largest Lyapunov Exponent (LLE) for NHL Team 52 time series and print
Reviewer #6 rebuttal text. Uses data/processed/clean_game.csv (Team 52, FTHG),
chronological. Requires: numpy (pip install numpy). Uses built-in Rosenstein LLE.
"""
import csv
import sys
from pathlib import Path

# Default paths (run from project root)
PROJECT_ROOT = Path(__file__).resolve().parent
CSV_PATH = PROJECT_ROOT / "data" / "processed" / "clean_game.csv"
RESULTS_DIR = PROJECT_ROOT / "data" / "results"
TARGET_TEAM_ID = 52
COLUMN = "FTHG"

# LLE threshold: positive => chaos; else stochastic
LLE_CHAOS_THRESHOLD = 0.0


def load_team_series(csv_path, target_team_id, column_name):
    """Load CSV, filter for team, sort by date, return 1D series and N."""
    rows = []
    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames or []
        for key in ("Date", "HomeTeam", "AwayTeam", column_name):
            if key not in fieldnames:
                raise ValueError(f"Missing column: {key}")
        for r in reader:
            try:
                ht = int(r["HomeTeam"])
                at = int(r["AwayTeam"])
                val = float(r[column_name])
            except (ValueError, KeyError):
                continue
            if ht == target_team_id or at == target_team_id:
                date_str = r["Date"].strip()
                rows.append((date_str, val))

    if not rows:
        return [], 0

    # Parse DD/MM/YYYY for sorting
    def sort_key(item):
        s = item[0]
        if not s:
            return (9999, 99, 99)
        parts = s.split("/")
        if len(parts) != 3:
            return (9999, 99, 99)
        try:
            d, m, y = int(parts[0]), int(parts[1]), int(parts[2])
            return (y, m, d)
        except ValueError:
            return (9999, 99, 99)

    rows.sort(key=sort_key)
    series = [v for _, v in rows]
    return series, len(series)


def _lyap_r_rosenstein(y, emb_dim=10, lag=1, min_tsep=None, trajectory_len=20):
    """
    Largest Lyapunov Exponent via Rosenstein et al. (numpy only, no nolds).
    y: 1D array; returns LLE (slope of log divergence vs time).
    """
    import numpy as np
    y = np.asarray(y, dtype=float).ravel()
    n = len(y)
    if min_tsep is None:
        min_tsep = emb_dim * lag
    # Delay embedding: rows = [y_i, y_{i+lag}, ..., y_{i+(emb_dim-1)*lag}]
    m = n - (emb_dim - 1) * lag - trajectory_len
    if m < 10:
        trajectory_len = max(1, (n - (emb_dim - 1) * lag - 10) // 2)
        m = n - (emb_dim - 1) * lag - trajectory_len
    if m < 2:
        return 0.0
    # Build embedded vectors (each row is one state)
    emb = np.zeros((m + trajectory_len, emb_dim))
    for d in range(emb_dim):
        emb[:, d] = y[d * lag : d * lag + m + trajectory_len]
    # For each reference i, find nearest neighbor j with |i-j| >= min_tsep
    trajectory_len = min(trajectory_len, m - 1)
    if trajectory_len < 1:
        return 0.0
    log_d = np.zeros(trajectory_len)
    count = np.zeros(trajectory_len)
    for i in range(m):
        ref = emb[i]
        best_j, best_d = None, np.inf
        for j in range(m):
            if abs(j - i) < min_tsep:
                continue
            d = np.linalg.norm(emb[j] - ref)
            if d > 1e-14 and d < best_d:
                best_d, best_j = d, j
        if best_j is None:
            continue
        for k in range(trajectory_len):
            if i + k >= len(emb) or best_j + k >= len(emb):
                break
            dk = np.linalg.norm(emb[i + k] - emb[best_j + k])
            if dk > 1e-14:
                log_d[k] += np.log(dk)
                count[k] += 1
    for k in range(trajectory_len):
        if count[k] > 0:
            log_d[k] /= count[k]
        else:
            log_d[k] = np.nan
    valid = ~np.isnan(log_d) & (count > 0)
    if np.sum(valid) < 3:
        return 0.0
    k_vals = np.arange(trajectory_len, dtype=float)[valid]
    s_vals = log_d[valid]
    # Slope of <log d(k)> vs k = LLE
    slope = np.polyfit(k_vals, s_vals, 1)[0]
    return float(slope)


def compute_LLE(series):
    """Compute Largest Lyapunov Exponent (Rosenstein et al., numpy only)."""
    try:
        import numpy as np
    except ImportError:
        print("ERROR: Install numpy: pip install numpy", file=sys.stderr)
        sys.exit(1)
    y = np.asarray(series, dtype=float)
    if y.ndim > 1:
        y = y.ravel()
    n = len(y)
    trajectory_len = min(20, max(1, n // 10))
    emb_dim = max(2, min(10, n // 20))
    lle = _lyap_r_rosenstein(
        y,
        emb_dim=emb_dim,
        lag=1,
        min_tsep=None,
        trajectory_len=trajectory_len,
    )
    return float(lle)


def main():
    if not CSV_PATH.is_file():
        print(f"ERROR: CSV not found: {CSV_PATH}", file=sys.stderr)
        sys.exit(1)

    series, n = load_team_series(CSV_PATH, TARGET_TEAM_ID, COLUMN)
    if n < 100:
        print(f"ERROR: Too few points for Team {TARGET_TEAM_ID} ({n}). Need ≥100.", file=sys.stderr)
        sys.exit(1)

    lle = compute_LLE(series)
    lines = []
    lines.append("Largest Lyapunov Exponent (LLE): {:.4f}".format(lle))
    lines.append("")

    if lle > LLE_CHAOS_THRESHOLD:
        lines.append("Result: Chaos (LLE > 0)")
        lines.append("")
        lines.append("--- Text for Reviewer #6 (Chaos) ---")
        n_str = f"N = {n} games" if n < 1000 else f"N > 1000 games"
        lle_str = f"+{lle:.2f}" if lle >= 0.01 else f"+{lle:.3f}"
        msg = (
            f'Analysis of the 20-year NHL dataset (Team {TARGET_TEAM_ID}, {n_str}) '
            f'revealed a positive Lyapunov exponent ({lle_str}), confirming that our '
            'chaos-aware framework generalizes to continuous sports.'
        )
        lines.append(msg)
    else:
        lines.append("Result: Stochastic (LLE ≈ 0 or negative)")
        lines.append("")
        lines.append("--- Text for Reviewer #6 (Stochastic) ---")
        msg = (
            "The extended 20-year analysis confirmed the stochastic nature of the sport, "
            "consistent with our NBA findings."
        )
        lines.append(msg)

    lines.append("")
    lines.append("--- Summary ---")
    lines.append(f"Team ID: {TARGET_TEAM_ID}  |  Games: {n}  |  LLE: {lle:.4f}")

    out_text = "\n".join(lines)
    print(out_text)

    # Save to data/results/
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    out_file = RESULTS_DIR / "LLE_reviewer6_results.txt"
    out_file.write_text(out_text, encoding="utf-8")
    print("")
    print(f"(Saved to {out_file})")


if __name__ == "__main__":
    main()
