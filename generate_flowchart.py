#!/usr/bin/env python3
"""
Generate pipeline flowchart (Figure 1 for manuscript — Reviewer #3).
Output: fig_pipeline.png
Run from project root: python3 generate_flowchart.py
Requires: pip install matplotlib
"""
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
except ImportError:
    raise SystemExit('matplotlib required. Install with: pip install matplotlib')

def main():
    fig, ax = plt.subplots(1, 1, figsize=(7, 9))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 14)
    ax.set_aspect('equal')
    ax.axis('off')

    def add_box(y, text, color='lightblue'):
        b = mpatches.FancyBboxPatch((1.5, y - 0.35), 7, 0.7, boxstyle="round,pad=0.02",
                                    facecolor=color, edgecolor='black', linewidth=1)
        ax.add_patch(b)
        ax.text(5, y, text, ha='center', va='center', fontsize=8)

    def add_arrow(y_from, y_to):
        ax.annotate('', xy=(5, y_to + 0.35), xytext=(5, y_from - 0.35),
                    arrowprops=dict(arrowstyle='->', color='black', lw=1.5))

    y = 13
    add_box(y, 'Raw Data (CSV per team)')
    prev = y
    y -= 1.2
    add_arrow(prev, y)
    add_box(y, 'Preprocessing: Stationarity (e.g. ADF)')
    prev, y = y, y - 1.2
    add_arrow(prev, y)
    add_box(y, 'Schreiber Denoising')
    prev, y = y, y - 1.2
    add_arrow(prev, y)
    add_box(y, 'Surrogate Test (AAFT, permutation entropy)')
    prev, y = y, y - 1.2
    add_arrow(prev, y)
    add_box(y, 'Optional: Oversampling / Downsample')
    prev, y = y, y - 1.2
    add_arrow(prev, y)
    add_box(y, '0-1 Test: K-statistic vs cutoff')
    prev, y = y, y - 1.2
    add_arrow(prev, y)
    add_box(y, 'Classification: Chaotic / Periodic / Stochastic', 'lightyellow')
    prev, y = y, y - 1.2
    add_arrow(prev, y)
    add_box(y, 'Optional: Nonlinearity (Keenan etc. in finalenonlinear.m)', 'wheat')
    prev, y = y, y - 1.2
    add_arrow(prev, y)
    add_box(y, 'Forecasting: Attractor / Neural Net', 'lightgreen')

    ax.set_title('Pipeline: Chaos Classification and Forecasting (Figure 1 — Reviewer #3)', fontsize=10)
    plt.tight_layout()
    plt.savefig('fig_pipeline.png', dpi=300, bbox_inches='tight')
    plt.close()
    print('Saved fig_pipeline.png')

if __name__ == '__main__':
    main()
