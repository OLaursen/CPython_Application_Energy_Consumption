#!/usr/bin/env python3
import matplotlib.pyplot as plt

class generator:
    
    def __init__(self, dataframe, labels):
        self.groups_to_labels = labels
        self.groups = list(self.groups_to_labels.keys())
        self.dataframe = dataframe

    def plot_boxplot(self, group):
        group_values = self.dataframe[group].unique()
        grouped_data = self.dataframe.groupby(by=group)

        fig, ax = plt.subplots(figsize=(12, 7))

        boxplot = ax.boxplot([grouped_data.get_group(val)['Total Energy Consumption'].values for val in group_values], 
                                labels=group_values,
                                patch_artist=True,
                                showfliers=False,
                                widths=0.5)

        for box in boxplot['boxes']:
            box.set(facecolor='white', edgecolor='black', linewidth=1.5)

        # Mean text
        for i in range (len(group_values)):
            val = group_values[i]
            group_df = grouped_data.get_group(val)
            mean_val = group_df['Total Energy Consumption'].mean()
            x_pos = i + 1
            ax.text(x_pos, mean_val, f'μ={mean_val:.2f}', horizontalalignment='center', verticalalignment='bottom', color='blue', fontsize='medium')
        
        
        ax.grid(True, axis='y', linestyle=':', linewidth=2, alpha=0.6)
        #ax.set_title(f'Total Energy Consumption Boxplot grouped by {self.groups_to_labels[group]}', size='large')
        ax.set_ylabel('Energy Consumption [J]', size='large')
        ax.set_xlabel(self.groups_to_labels[group], size='large')
        plt.tight_layout()

        output_path = f'./figures/energy-consumption-boxplot_by_{group}.png'
        plt.savefig(output_path, dpi=600)
        plt.close(fig)

    def generate_boxplot_figures_for_each_group(self):
            for group in self.groups:
                self.plot_boxplot(group)
