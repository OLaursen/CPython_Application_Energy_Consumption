#!/usr/bin/env python3
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.markers import MarkerStyle

class summary_table_generator:
    def __init__(self, dataframe, outfile):
        self.dataframe = dataframe
        self.output_filename = outfile

    def generate_summary_table_and_save_csv(self, outfile):
        #If file exists dont include header and instead append
        self.dataframe.sort_values(['RPi','Distro', 'Version']).to_csv(self.output_filename, index=False)

    def generate_scatterplot(self, outfile, mode, unit):
        df = self.dataframe
        # X Time(s) Y Energy (J)
        cmap = {'Manjaro':'Green', 'Ubuntu':'Orange', 'FreeBSD':'Red', 'Alpine':'Blue'}
        #Marker map used for pyversions
        mmap = {'3.13.7': '^', '3.12.11': 's', '3.11.13': 'o', '3.10.18': 'd', '3.9.23': 'p'}

        fig, ax = plt.subplots(figsize=(9,6))
        for (distro, rpi, pythonversion), sub in df.groupby(['Distro', 'RPi', 'Version']):
            base_marker = mmap.get(pythonversion)
            base_marker_color = cmap.get(distro)
            

            if rpi == 'RPi3B+':
                #Split color marker
                ax.scatter(
                    sub['Duration'],
                    sub[mode],
                    marker = MarkerStyle(base_marker, fillstyle='left'),
                    facecolors = base_marker_color,
                    s=70,
                )
                ax.scatter(
                    sub['Duration'],
                    sub[mode],
                    marker = MarkerStyle(base_marker, fillstyle='right'),
                    facecolors = 'black',
                    s=70,
                )
            else:
                ax.scatter(
                    sub['Duration'],
                    sub[mode],
                    marker = base_marker,
                    facecolors = base_marker_color,
                    s=70,
                )
        
        ax.set_title(f'{mode} [{unit}] and Runtime(S) per combination of OS, Python version and Pi Model')
        ax.set_xlabel('Duration (s)')
        ax.set_ylabel(f'{mode} [{unit}]')
        ax.grid()

        # Generate legend
        handles, labels = ax.get_legend_handles_labels()
        by_label = dict(zip(labels, handles))
        ax.legend(by_label.values(), by_label.keys(), fontsize=9)

        plt.tight_layout()
        plt.show()

    def total_energy_scatterplot(self, outfile):
        self.generate_scatterplot_png(outfile, 'Total Energy Consumption', 'J' )
    
    def avg_energy_scatterplot(self, outfile):
        self.generate_scatterplot_png(outfile, 'Average', 'W')
