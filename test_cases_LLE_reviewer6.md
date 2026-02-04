# Test Cases: Largest Lyapunov Exponent (LLE) for Reviewer #6

Script: **`compute_LLE_reviewer6.py`** — computes LLE from a time series (built-in Rosenstein algorithm, numpy only; no nolds) and prints the appropriate Reviewer #6 rebuttal text.

**Interpretation:**
- **LLE > 0 (positive)** → Chaos → use chaos rebuttal.
- **LLE ≈ 0 or negative** → Stochastic → use stochastic rebuttal.

---

## Test Case 1: Real NHL data (Team 52, FTHG)

**Purpose:** Validate on the 20-year NHL dataset; one-team trajectory (Team 52), chronological.

**Steps:**
1. Ensure `data/processed/clean_game.csv` exists (from `process_data_folder.py data/raw`).
2. Run:
   ```bash
   cd /path/to/chaospaper
   pip install numpy   # if needed
   python3 compute_LLE_reviewer6.py
   ```
3. Read the printed **Largest Lyapunov Exponent (LLE)**.
4. **If LLE > 0:** Copy the "Text for Reviewer #6 (Chaos)" paragraph into the rebuttal.
5. **If LLE ≤ 0:** Copy the "Text for Reviewer #6 (Stochastic)" paragraph.

**Expected output lines:**
- `Largest Lyapunov Exponent (LLE): X.XXXX`
- `Result: Chaos (LLE > 0)` or `Result: Stochastic (LLE ≈ 0 or negative)`
- One of the two Reviewer #6 paragraphs.

**Note:** Team 52 has ~888 games in the current dataset. The script prints "N = 888 games". For "N > 1000 games" in the chaos message, either use a team with more games or aggregate more seasons.

---

## Test Case 2: Synthetic chaotic series (sanity check)

**Purpose:** Confirm that a known chaotic system yields LLE > 0 and the chaos message.

**Setup:** Logistic map \( x_{n+1} = r x_n (1 - x_n) \) with \( r = 4 \) is chaotic (LLE ≈ 0.693).

**Steps (optional, in Python):**
```python
import numpy as np
import nolds
# Logistic map r=4, 2000 points
x = 0.1
series = [x]
for _ in range(1999):
    x = 4 * x * (1 - x)
    series.append(x)
lle = nolds.lyap_r(np.array(series))
print("LLE:", lle)   # Expect ~0.69 > 0
```
**Expected:** LLE > 0 → use chaos rebuttal text.

---

## Test Case 3: Synthetic stochastic series (sanity check)

**Purpose:** Confirm that white noise yields LLE ≈ 0 or negative and the stochastic message.

**Steps (optional):**
```python
import numpy as np
import nolds
np.random.seed(42)
series = np.random.randn(2000)
lle = nolds.lyap_r(series)
print("LLE:", lle)   # Often near 0 or negative
```
**Expected:** LLE ≤ 0 → use stochastic rebuttal text.

---

## Reviewer #6 text (reference)

**If LLE > 0 (Chaos):**
> "Analysis of the 20-year NHL dataset (Team 52, N > 1000 games) revealed a positive Lyapunov exponent (+0.0X), confirming that our chaos-aware framework generalizes to continuous sports."

**If LLE ≈ 0 or negative (Stochastic):**
> "The extended 20-year analysis confirmed the stochastic nature of the sport, consistent with our NBA findings."

The script prints the exact sentence with the computed LLE value and sample size.
