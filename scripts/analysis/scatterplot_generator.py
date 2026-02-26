#!/usr/bin/env python3
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.lines as line
from matplotlib.markers import MarkerStyle

class generator:
    def __init__(self, dataframe, outfile):
        self.dataframe = dataframe
        self.output_filename = outfile
        # Graph styling
        self.os_to_color = {'Manjaro':'Green', 'Ubuntu':'Orange', 'FreeBSD':'Red', 'Alpine':'Blue'}
        self.version_to_shape = {'3.13.7': '^', '3.12.11': 's', '3.11.13': 'o', '3.10.18': 'd', '3.9.23': 'p'} 

    def generate_summary_table_and_save_csv(self, outfile):
        #If file exists dont include header and instead append
        self.dataframe.sort_values(['RPi','Distro', 'Version']).to_csv(self.output_filename, index=False)

    def legend_header(self, header):
        return line.Line2D([0], [0], linestyle='None', marker=None, color='none', label=header)

    def generate_scatterplot(self, outfile, title_and_unit, mode, unit):
        df = self.dataframe
        cmap = self.os_to_color
        mmap = self.version_to_shape

        fig, ax = plt.subplots(figsize=(16,9))
        for (distro, rpi, pythonversion), sub in df.groupby(['Distro', 'RPi', 'Version']):
            base_marker = mmap.get(pythonversion)
            base_marker_color = cmap.get(distro)

            if rpi == 'RPi3B+':
                ax.scatter(
                    sub['Duration'],
                    sub[mode],
                    marker = MarkerStyle(base_marker, fillstyle='left'),
                    facecolors = base_marker_color,
                    edgecolors='black',
                    s=100,
                )
                ax.scatter(
                    sub['Duration'],
                    sub[mode],
                    marker = MarkerStyle(base_marker, fillstyle='right'),
                    facecolors = 'black',
                    s=100,
                )
            else:
                ax.scatter(
                    sub['Duration'],
                    sub[mode],
                    marker = base_marker,
                    facecolors = base_marker_color,
                    edgecolors='black',
                    s=100,
                )
        
        ax.set_title(f'{title_and_unit} and Runtime(S) per combination of OS, Python version and Pi Model')
        ax.set_xlabel('Duration (s)')
        ax.set_ylabel(f'{mode} [{unit}]')
        ax.grid()
        # Legend
        ## Markers
        os_legend_items = [line.Line2D([0],[0], marker='o', color='w', label=distro, markerfacecolor=color, markeredgecolor='black', markersize=9) for distro, color in cmap.items()]
        python_legend_items = [line.Line2D([0],[0], marker=marker, color='black', linestyle='None', label=f'Python {version}', markersize=9) for version, marker in mmap.items()]
        rpi_legend_items = [line.Line2D([0],[0], linestyle='none', marker=MarkerStyle('o', fillstyle='right'), color='black', label=f'RPi3B+', markersize=9),
                            line.Line2D([0],[0], linestyle='none', marker='o', color='black', label=f'RPi4B', markersize=9)]
        
        legend_items = ([self.legend_header('Raspberry Pi Model')] + rpi_legend_items + [self.legend_header('Operating System')] + os_legend_items
                        + [self.legend_header('Python Version')] + python_legend_items)

        # Add legend items
        ax.legend(
            handles=legend_items,
            loc='lower right',
            fontsize=9,
            frameon=True,
            labelspacing=0.6,
            handlelength=1.5
        )

        plt.tight_layout()
        plt.savefig(outfile, dpi=150)
        plt.close(fig)


    def total_energy_scatterplot(self, outfile):
        self.generate_scatterplot(outfile,'Total Energy Consumption [J]','Total Energy Consumption', 'J' )
    
    def avg_energy_scatterplot(self, outfile):
        self.generate_scatterplot(outfile,'Avg. Energy Consumption [W]' ,'Average', 'W')
