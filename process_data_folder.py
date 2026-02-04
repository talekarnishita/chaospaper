#!/usr/bin/env python3
"""
Process CSV files in the data folder: standardize columns (Date, HomeTeam, AwayTeam, FTHG, FTAG)
and date format (DD/MM/YYYY), then save to data/processed/ with prefix clean_.
Uses only the Python standard library (no pandas required).
"""

import csv
import re
import sys
from datetime import datetime
from pathlib import Path

# Default: data/; override with first arg, e.g. python3 process_data_folder.py data/raw
DATA_DIR = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("data")
PROCESSED_DIR = DATA_DIR.parent / "processed" if DATA_DIR.name == "raw" else DATA_DIR / "processed"

# Flexible column name patterns (case-insensitive); first match wins per role.
DATE_PATTERNS = [
    r"^date$",
    r"^dates?$",
    r"match.?date",
    r"game.?date",
    r"date_time",
    r"datetime",
]
HOME_TEAM_PATTERNS = [
    r"^home.?team$",
    r"^hometeam$",
    r"^home$",
    r"^host$",
    r"^home_?team$",
    r"home_team_id",
    r"home_team",
]
AWAY_TEAM_PATTERNS = [
    r"^away.?team$",
    r"^awayteam$",
    r"^away$",
    r"^visitor$",
    r"^guest$",
    r"^away_?team$",
    r"away_team_id",
    r"away_team",
]
HOME_GOALS_PATTERNS = [
    r"^fthg$",
    r"^hg$",
    r"^home.?goals?$",
    r"^homegoals?$",
    r"^home_?g$",
    r"^goals?.?home$",
    r"home_goals",
]
AWAY_GOALS_PATTERNS = [
    r"^ftag$",
    r"^ag$",
    r"^away.?goals?$",
    r"^awaygoals?$",
    r"^away_?g$",
    r"^goals?.?away$",
    r"away_goals",
]

# Common date formats to try (dayfirst where ambiguous).
DATE_FORMATS = [
    "%d/%m/%Y",
    "%Y-%m-%d",
    "%m/%d/%Y",
    "%d-%m-%Y",
    "%Y/%m/%d",
    "%d %b %Y",
    "%d %B %Y",
    "%b %d, %Y",
    "%B %d, %Y",
    "%Y-%m-%d %H:%M:%S",
    "%Y-%m-%dT%H:%M:%SZ",
    "%Y-%m-%dT%H:%M:%S",
]


def _match_column(col_name, patterns):
    """Return True if col_name (case-insensitive, stripped) matches any pattern."""
    if not isinstance(col_name, str) or not col_name.strip():
        return False
    norm = re.sub(r"\s+", " ", col_name.strip().lower())
    for pat in patterns:
        if re.search(pat, norm, re.IGNORECASE):
            return True
    return False


def find_column(columns, patterns):
    """Return the first column name that matches any of the patterns, else None."""
    for c in columns:
        if _match_column(str(c), patterns):
            return c
    return None


def parse_date_to_ddmmyyyy(value):
    """Parse a date string and return DD/MM/YYYY; invalid -> empty string."""
    if value is None or str(value).strip() == "":
        return ""
    s = str(value).strip()
    for fmt in DATE_FORMATS:
        try:
            dt = datetime.strptime(s, fmt)
            return dt.strftime("%d/%m/%Y")
        except ValueError:
            continue
    return ""


def _date_sort_key(row):
    """Return a comparable value for sorting by Date (DD/MM/YYYY). Empty date -> last."""
    s = (row.get("Date") or "").strip()
    if not s:
        return (datetime.max,)
    try:
        dt = datetime.strptime(s, "%d/%m/%Y")
        return (dt,)
    except ValueError:
        return (datetime.max,)


def safe_int(value):
    """Convert to int; invalid -> empty string for CSV."""
    if value is None or str(value).strip() == "":
        return ""
    try:
        return int(float(str(value).replace(",", ".")))
    except (ValueError, TypeError):
        return ""


def process_csv(filepath):
    """
    Read CSV, map columns to Date, HomeTeam, AwayTeam, FTHG, FTAG,
    standardize date to DD/MM/YYYY, save to data/processed/clean_<name>.csv.
    Returns True if successful. Checks header first so large files without
    required columns are skipped without reading.
    """
    try:
        with open(filepath, newline="", encoding="utf-8", errors="replace") as f:
            reader = csv.DictReader(f)
            cols = list(reader.fieldnames or [])
            if not cols:
                print("  Empty or no header")
                return False
            date_col = find_column(cols, DATE_PATTERNS)
            home_team_col = find_column(cols, HOME_TEAM_PATTERNS)
            away_team_col = find_column(cols, AWAY_TEAM_PATTERNS)
            home_goals_col = find_column(cols, HOME_GOALS_PATTERNS)
            away_goals_col = find_column(cols, AWAY_GOALS_PATTERNS)
            required = {
                "Date": date_col,
                "HomeTeam": home_team_col,
                "AwayTeam": away_team_col,
                "FTHG": home_goals_col,
                "FTAG": away_goals_col,
            }
            missing = [k for k, v in required.items() if v is None]
            if missing:
                print(f"  Missing columns: {missing}")
                return False
            rows = list(reader)
    except Exception as e:
        print(f"  Read error: {e}")
        return False

    out_rows = []
    for r in rows:
        out_rows.append({
            "Date": parse_date_to_ddmmyyyy(r.get(date_col, "")),
            "HomeTeam": (r.get(home_team_col, "") or "").strip(),
            "AwayTeam": (r.get(away_team_col, "") or "").strip(),
            "FTHG": safe_int(r.get(home_goals_col, "")),
            "FTAG": safe_int(r.get(away_goals_col, "")),
        })

    # Sort by Date so trajectory is chronological for chaos detection (empty dates last).
    out_rows.sort(key=_date_sort_key)

    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)
    out_name = f"clean_{filepath.name}"
    out_path = PROCESSED_DIR / out_name
    fieldnames = ["Date", "HomeTeam", "AwayTeam", "FTHG", "FTAG"]
    try:
        with open(out_path, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(out_rows)
    except Exception as e:
        print(f"  Write error: {e}")
        return False
    return True


def main():
    if not DATA_DIR.is_dir():
        print(f"Data folder not found: {DATA_DIR.absolute()}")
        return

    csv_files = sorted(
        f for f in DATA_DIR.iterdir()
        if f.is_file() and f.suffix.lower() == ".csv"
    )
    if not csv_files:
        print(f"No CSV files found in {DATA_DIR.absolute()}")
        return

    print(f"Found {len(csv_files)} CSV file(s) in {DATA_DIR}/")
    processed = []
    failed = []

    for f in csv_files:
        print(f"Processing: {f.name}")
        if process_csv(f):
            processed.append(f.name)
            print(f"  -> Saved to {PROCESSED_DIR}/clean_{f.name}")
        else:
            failed.append(f.name)

    print()
    print("--- Summary ---")
    print(f"Successfully processed: {len(processed)}")
    for name in processed:
        print(f"  - {name} -> clean_{name}")
    if failed:
        print(f"Failed or skipped: {len(failed)}")
        for name in failed:
            print(f"  - {name}")


if __name__ == "__main__":
    main()
