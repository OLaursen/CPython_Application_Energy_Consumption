#!/usr/bin/env python3

class summary_table_generator:
    def __init__(self, dataframe, outfile):
        self.dataframe = dataframe
        self.output_filename = outfile

    def generate_summary_table_and_save_csv(self):
        #If file exists dont include header and instead append
        self.dataframe.sort_values(['RPi','Distro', 'Version']).to_csv(self.output_filename, index=False)

    

