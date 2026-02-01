#!/usr/bin/env Version3

import glob
from typing import List
import pandas as pd
import matplotlib.pyplot as plt

def parse_filename():
    files = glob.glob("../../results/results_*.csv")
    return files if files else None

class boxplot_generator:
    
    def __init__(self, path_pattern, groups_and_labels): # Could add a data loader as a parameter that exposes (load_data/discover_result_files)
        self.path_pattern = path_pattern
        self.group_to_label = groups_and_labels
        self.groups = list(groups_and_labels.keys())
        self.create_dataframe()

    def discover_result_files(self):
        files = glob.glob(self.path_pattern)
        if not files:
            print("No benchmark CSV files found. Cannot generate boxplots.")
            return
        return files

    def create_dataframe(self):
        files = self.discover_result_files()
        result_data = [pd.read_csv(f) for f in files]
        self.dataframe = pd.concat(result_data, ignore_index=False)

    def plot_boxplot(self, group):
        group_values = self.dataframe[group].unique()
        grouped_data = self.dataframe.groupby(by=group)

        fig, ax = plt.subplots(figsize=(10, 6))

        boxplot = ax.boxplot([grouped_data.get_group(val)['Total Energy Consumption'].values for val in group_values], 
                             labels=group_values, patch_artist=True, showfliers=False)

        for box in boxplot['boxes']:
            box.set(facecolor='white', edgecolor='black', linewidth=1.5)

        # Mean text
        for i in range (len(group_values)):
            val = group_values[i]
            group_df = grouped_data.get_group(val)
            mean_val = group_df['Total Energy Consumption'].mean()
            x_pos = i + 1
            ax.text(x_pos, mean_val, f'{mean_val:.2f}', horizontalalignment='center', verticalalignment='bottom', color='blue')
        # Zoom y-axis
        all_vals = self.dataframe['Total Energy Consumption'].values
        y_min, y_max = all_vals.min(), all_vals.max()
        pad = 0.05 * (y_max - y_min)
        ax.set_ylim(y_min - pad, y_max + pad)
        
        ax.grid(True, axis='y', linestyle='--', linewidth=0.5, color='grey', alpha=0.6)
        ax.set_title(f'Energy Consumption Boxplot by {self.group_to_label[group]}')
        ax.set_ylabel('Total Energy Consumption (Joules)')
        ax.set_xlabel(self.group_to_label[group])
        plt.tight_layout()

        output_path = f'./figures/energy-consumption-boxplot_by_{group}.png'
        plt.savefig(output_path, dpi=150)
        plt.close(fig)

    def generate_boxplot_files_for_each_group(self):
            for group in self.groups:
                self.plot_boxplot(group)
