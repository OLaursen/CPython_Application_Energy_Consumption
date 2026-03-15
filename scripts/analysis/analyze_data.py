import boxplot_generator as bp_gen
import multi_barplot as mb_gen
import summary_table_generator as st_gen
import scatterplot_generator as sc_gen
import dataframe_generator as df_gen
# make plot/figure generator and use different methods to create boxplot and scatterplot
def generate_boxplots(df):
    labels = {'Distro': 'Operating System','Version': 'Python Version','RPi': 'Raspberry Pi Model'}
    boxplot = bp_gen.generator(df,labels)
    boxplot.generate_boxplot_figures_for_each_group()

def generate_summary_table(df):
    outfile = "../../results/summary_table.csv"
    summary_table = st_gen.generator(df, outfile)
    summary_table.generate_summary_table_and_save_csv()

def generate_avg_energy_scatterplot(df):
    outfile = "./figures/avg_energy_scatterplot.png"
    scatter_plot = sc_gen.generator(df, outfile)
    scatter_plot.avg_energy_scatterplot()
    
def generate_barplot(df):
    outfile = "./figures/consumption-barplot.png"
    barplot = mb_gen.generator(df, outfile)
    barplot.generate_barplot()

def main(): 
    df = df_gen.generator("../../results/results_*.csv").dataframe

    generate_summary_table(df)
    generate_avg_energy_scatterplot(df)
    generate_boxplots(df)
    generate_barplot(df)
    
if __name__ == '__main__':
    main()