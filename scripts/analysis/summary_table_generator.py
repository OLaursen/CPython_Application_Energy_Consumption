#!/usr/bin/env python3
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.markers import MarkerStyle

class generator:
    def __init__(self, dataframe, outfile):
        self.dataframe = dataframe
        self.outfile = outfile

    def generate_summary_table_and_save_csv(self):
        #If file exists dont include header and instead append
        self.dataframe.sort_values(['RPi','Distro', 'Version']).to_csv(self.outfile, index=False)

