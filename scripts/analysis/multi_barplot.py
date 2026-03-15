import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.patches import Patch

class generator:
    def __init__(self, df, outfile):
        self.df = df
        self.outfile = outfile

    def generate_barplot(self):
        df = self.df
        pis = sorted(df['RPi'].unique())
        pythons = sorted(df['Version'].unique(), key=lambda x: list(map(int, x.split('.'))))
        distros = sorted(df['Distro'].unique())

        if '3.9' in pythons:
            pythons.remove('3.9')
            pythons = ['3.9'] + pythons

        colors = {
            'Alpine': 'blue',
            'Ubuntu': 'orange',
            'FreeBSD': 'red',
            'Manjaro': 'green'
        }

        x_positions = []
        values = []
        x_groups = []
        current = 0
        gap = 1.0
        width = 1.0

        for pi in pis:
            for pv in pythons:
                distro_vals = []
                for d in distros:
                    subset = df[(df['RPi'] == pi) & (df['Version'] == pv) & (df['Distro'] == d)]
                    if not subset.empty:
                        distro_vals.append((d, subset["Total Energy Consumption"].iloc[0]))
                for d in distros:
                    x_positions.append(current)
                    values.append(next(v for dd, v in distro_vals if dd == d))
                    x_groups.append((pi, pv))
                    current += 1
                current += 0.3
            current += gap

        group_centers = {}
        for idx, (pi, pv) in enumerate(x_groups):
            group_centers.setdefault((pi, pv), []).append(x_positions[idx])

        ticks = []
        labels = []
        for pi in pis:
            for pv in pythons:
                positions = group_centers.get((pi, pv), [])
                if positions:
                    ticks.append(np.mean(positions))
                    labels.append(f"{pv}")

        fig, ax = plt.subplots(figsize=(max(12, current * 0.2), 6))

        ylim = (0, max(values) * 1.15)
        ax.set_ylim(ylim)

        for idx, xpos in enumerate(x_positions):
            pi, pv = x_groups[idx]
            d = df[(df['RPi'] == pi) & (df['Version'] == pv) & (df['Total Energy Consumption'] == values[idx])]['Distro'].iloc[0]
            ax.bar(xpos, values[idx], width=width, color=colors[d], edgecolor='black')

        ax.set_xticks(ticks)
        ax.set_xticklabels(labels, rotation=35, ha='right')

        ax.grid(True, axis='y', linestyle=':', linewidth=0.5, alpha=0.6)

        divider_positions = []
        pos = 0
        for pi in pis:
            count = sum(1 for g in x_groups if g[0] == pi)
            pos += count + 1.5
            divider_positions.append(pos - 0.5)
            pos += gap
        for dpos in divider_positions[:-1]:
            ax.axvline(dpos, color='grey', linestyle='--', linewidth=1)

        pi_centers = []
        pos = 0
        for pi in pis:
            count = sum(1 for g in x_groups if g[0] == pi)
            center = pos + (count - 1) / 2
            pi_centers.append((center, pi))
            pos += count + gap
        for xctr, pi in pi_centers:
            ax.text(xctr, ylim[1] * 0.97, pi, ha='center', va='top', fontsize='medium')

        ax.set_ylabel('Energy Consumption [J]', size='large')
        #ax.set_title("Total energy consumption [J] grouped by Raspberry Pi and Python version")

        handles = [Patch(facecolor=colors[d], label=d) for d in distros]
        ax.legend(handles=handles, title='OS', loc='upper center', bbox_to_anchor=(0.5, -0.2), ncol=4)

        plt.tight_layout()
        fig.savefig(self.outfile, dpi=600)


