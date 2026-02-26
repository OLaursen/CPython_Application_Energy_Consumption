import glob
import pandas as pd

class generator:
    def __init__(self, csv_path_pattern):
        self.csv_path_pattern = csv_path_pattern
        self.create_dataframe()

    def read_csv_result_files(self):
        files = glob.glob(self.csv_path_pattern)
        if not files:
            print("No benchmark CSV files found. Cannot generate Dataframe")
            return
        return files
    
    def create_dataframe(self):
        files = self.read_csv_result_files()
        result_data = [pd.read_csv(f) for f in files]
        self.dataframe = pd.concat(result_data)

