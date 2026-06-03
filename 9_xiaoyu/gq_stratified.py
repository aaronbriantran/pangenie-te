#!/usr/bin/env python3
"""Visualize the distribution of Genotype Quality (GQ) values, stratified by MEI class."""

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


def classify_mei(element):
    """Group MEI subfamilies into broader classes.

    Returns 'Alu' for all Alu subfamilies (Alu, AluS, AluY, FLAM_C, etc.),
    'L1/SVA' for LINE-1 and SVA elements,
    or None for other elements (HERVs, LTRs, etc.) which we skip.
    """
    e = str(element)
    if e.startswith("Alu") or e.startswith("FLAM") or e.startswith("FRAM"):
        return "Alu"
    if e.startswith("L1") or e.startswith("SVA"):
        return "L1/SVA"
    return None


def plot_broken_hist(ax_low, ax_high, data, bins, break_low, break_high,
                     color, label):
    """Draw a histogram across a broken x-axis on two shared-y axes."""
    low = data[data <= break_low]
    high = data[data >= break_high]
    ax_low.hist(low, bins=bins, edgecolor="black", alpha=0.7,
                color=color, label=label)
    ax_high.hist(high, bins=10, edgecolor="black", alpha=0.7, color=color)


def finalize_break(ax_low, ax_high, break_low, break_high, xmax):
    """Apply axis break cosmetics to a pair of subplots."""
    ax_low.set_xlim(0, break_low)
    ax_high.set_xlim(break_high, xmax * 1.001)
    ax_low.spines["right"].set_visible(False)
    ax_high.spines["left"].set_visible(False)
    ax_high.tick_params(left=False)

    d = 0.015
    kwargs = dict(transform=ax_low.transAxes, color="k", clip_on=False, linewidth=1)
    ax_low.plot((1 - d, 1 + d), (-d, +d), **kwargs)
    ax_low.plot((1 - d, 1 + d), (1 - d, 1 + d), **kwargs)
    kwargs.update(transform=ax_high.transAxes)
    ax_high.plot((-d * 4, +d * 4), (-d, +d), **kwargs)
    ax_high.plot((-d * 4, +d * 4), (1 - d, 1 + d), **kwargs)


def main():
    parser = argparse.ArgumentParser(
        description="Plot GQ distribution stratified by MEI class (Alu vs L1/SVA)."
    )
    parser.add_argument("file", type=Path, help="Path to the input file (whitespace-separated)")
    parser.add_argument(
        "-o", "--output",
        type=Path,
        default=Path("gq_distribution_by_class.png"),
        help="Output image path (default: gq_distribution_by_class.png)",
    )
    parser.add_argument("--bins", type=int, default=50, help="Histogram bins for low-GQ panel")
    parser.add_argument("--break-low", type=float, default=200,
                        help="Upper bound of left panel (default: 200)")
    parser.add_argument("--break-high", type=float, default=9900,
                        help="Lower bound of right panel (default: 9900)")
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

    if df.shape[1] < 14:
        sys.exit(f"Error: file has only {df.shape[1]} columns; need at least 14.")

    df["gq"] = df[9].apply(extract_gq)
    df["mei_class"] = df[13].apply(classify_mei)
    df = df.dropna(subset=["gq", "mei_class"])

    if df.empty:
        sys.exit("Error: no rows with valid GQ and a recognized MEI class.")

    # Summary per class
    print(f"Total rows with valid GQ + classified MEI: {len(df)}")
    for cls in ["Alu", "L1/SVA"]:
        sub = df[df["mei_class"] == cls]["gq"]
        if len(sub):
            print(f"\n{cls}:")
            print(f"  n:                 {len(sub)}")
            print(f"  GQ min / max:      {sub.min():.1f} / {sub.max():.1f}")
            print(f"  GQ mean / median:  {sub.mean():.1f} / {sub.median():.1f}")

    # Build a 2x2 grid: rows = classes, columns = low/high GQ panels
    xmax = df["gq"].max()
    fig, axes = plt.subplots(
        2, 2, sharey="row",
        figsize=(11, 8),
        gridspec_kw={"width_ratios": [4, 1], "wspace": 0.05, "hspace": 0.35},
    )

    class_colors = {"Alu": "#4C72B0", "L1/SVA": "#C44E52"}

    for row, cls in enumerate(["Alu", "L1/SVA"]):
        ax_low, ax_high = axes[row]
        sub = df[df["mei_class"] == cls]["gq"]

        if sub.empty:
            ax_low.text(0.5, 0.5, f"No {cls} data", ha="center", va="center",
                        transform=ax_low.transAxes)
            continue

        plot_broken_hist(ax_low, ax_high, sub, args.bins,
                         args.break_low, args.break_high,
                         color=class_colors[cls], label=cls)
        finalize_break(ax_low, ax_high, args.break_low, args.break_high, xmax)

        ax_low.set_ylabel("Count")
        ax_low.set_title(f"{cls}  (n = {len(sub):,})", loc="left")

        # Threshold markers
        for t, tc in zip([10, 20, 30, 50], ["#999", "#777", "#555", "#222"]):
            if t <= args.break_low:
                ax_low.axvline(t, color=tc, linestyle="--", linewidth=1, alpha=0.6)

    # Only label x-axis on bottom row
    axes[1, 0].set_xlabel("Genotype Quality (GQ)")

    fig.suptitle("GQ Distribution by MEI Class", fontsize=13, y=0.995)
    fig.savefig(args.output, dpi=150, bbox_inches="tight")
    print(f"\nPlot saved to: {args.output}")


if __name__ == "__main__":
    main()
