#!/usr/bin/env python3
"""Visualize the distribution of Genotype Quality (GQ) values with a broken x-axis."""

import argparse
import sys
from pathlib import Path

import pandas as pd
import matplotlib.pyplot as plt


def extract_gq(field_10):
    """Extract GQ (last colon-separated value) from the genotype field."""
    parts = str(field_10).split(":")
    try:
        return float(parts[-1])
    except (ValueError, IndexError):
        return None


def main():
    parser = argparse.ArgumentParser(
        description="Plot the distribution of Genotype Quality (GQ) values with a broken x-axis."
    )
    parser.add_argument("file", type=Path, help="Path to the input file (whitespace-separated)")
    parser.add_argument(
        "-o", "--output",
        type=Path,
        default=Path("gq_distribution.png"),
        help="Output image path (default: gq_distribution.png)",
    )
    parser.add_argument(
        "--bins", type=int, default=50,
        help="Number of histogram bins for the low-GQ panel (default: 50)"
    )
    parser.add_argument(
        "--break-low", type=float, default=200,
        help="Upper bound of the left (low-GQ) panel (default: 200)"
    )
    parser.add_argument(
        "--break-high", type=float, default=9900,
        help="Lower bound of the right (high-GQ) panel (default: 9900)"
    )
    args = parser.parse_args()

    if not args.file.exists():
        sys.exit(f"Error: file not found: {args.file}")

    df = pd.read_csv(
        args.file,
        sep=r"\s+",
        header=None,
        comment="#",
        engine="python",
    )

    if df.shape[1] < 10:
        sys.exit(f"Error: file has only {df.shape[1]} columns; need at least 10.")

    gq_series = df[9].apply(extract_gq).dropna()

    if gq_series.empty:
        sys.exit("Error: no valid GQ values found in column 10.")

    # Summary stats
    print(f"Total rows parsed:    {len(df)}")
    print(f"Rows with valid GQ:   {len(gq_series)}")
    print(f"GQ min / max:         {gq_series.min():.1f} / {gq_series.max():.1f}")
    print(f"GQ mean / median:     {gq_series.mean():.1f} / {gq_series.median():.1f}")
    n_low = (gq_series <= args.break_low).sum()
    n_high = (gq_series >= args.break_high).sum()
    print(f"Variants <= {args.break_low}:    {n_low}")
    print(f"Variants >= {args.break_high}:   {n_high}")

    # Two subplots side-by-side, sharing y-axis
    fig, (ax_low, ax_high) = plt.subplots(
        1, 2, sharey=True,
        figsize=(11, 5),
        gridspec_kw={"width_ratios": [4, 1], "wspace": 0.05},
    )

    # Left panel: low-GQ histogram
    low_data = gq_series[gq_series <= args.break_low]
    ax_low.hist(low_data, bins=args.bins, edgecolor="black", alpha=0.75)
    ax_low.set_xlim(0, args.break_low)
    ax_low.set_xlabel("Genotype Quality (GQ)")
    ax_low.set_ylabel("Count")

    # Right panel: high-GQ cluster (use fewer bins since it's a narrow range)
    high_data = gq_series[gq_series >= args.break_high]
    ax_high.hist(high_data, bins=10, edgecolor="black", alpha=0.75)
    ax_high.set_xlim(args.break_high, gq_series.max() * 1.001)

    # Hide the spines between the two axes to suggest a break
    ax_low.spines["right"].set_visible(False)
    ax_high.spines["left"].set_visible(False)
    ax_high.tick_params(left=False)

    # Diagonal "break" marks
    d = 0.015  # size of the diagonal lines in axes coords
    kwargs = dict(transform=ax_low.transAxes, color="k", clip_on=False, linewidth=1)
    ax_low.plot((1 - d, 1 + d), (-d, +d), **kwargs)
    ax_low.plot((1 - d, 1 + d), (1 - d, 1 + d), **kwargs)
    kwargs.update(transform=ax_high.transAxes)
    ax_high.plot((-d * 4, +d * 4), (-d, +d), **kwargs)  # *4 because right panel is narrower
    ax_high.plot((-d * 4, +d * 4), (1 - d, 1 + d), **kwargs)

    # Threshold lines on the low-GQ panel only
    for t, color in zip([10, 20, 30, 50], ["#999", "#777", "#555", "#222"]):
        if t <= args.break_low:
            ax_low.axvline(t, color=color, linestyle="--", linewidth=1, alpha=0.7)
            ax_low.text(t, ax_low.get_ylim()[1] * 0.95, f"GQ={t}", rotation=90,
                        va="top", ha="right", fontsize=8, color=color)

    fig.suptitle(f"GQ Distribution ({len(gq_series):,} variants)")
    fig.tight_layout()
    fig.savefig(args.output, dpi=150)
    print(f"\nPlot saved to: {args.output}")


if __name__ == "__main__":
    main()
