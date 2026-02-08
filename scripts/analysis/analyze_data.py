import boxplot_generator as bp_gen
import summary_table_generator as st_gen
import dataframe_generator as df_gen
# make plot/figure generator and use different methods to create boxplot and scatterplot
def generate_boxplots(df):
    labels = {'Distro': 'Operating System','Version': 'Python Version','RPi': 'Raspberry Pi Model'}
    boxplot = bp_gen.boxplot_generator(df,labels)
    boxplot.generate_boxplot_figures_for_each_group()

def generate_summary_table(df):
    outfile = "../../results/summary_table.csv"
    summary_table = st_gen.summary_table_generator(df)
    summary_table.generate_summary_table_and_save_csv(outfile)

def generate_scatterplot(df):
    outfile = "../../results/scatterplot.csv"
    scatter_plot = st_gen.summary_table_generator(df, outfile)
    scatter_plot.avg_energy_scatterplot(outfile)
def main(): 
    df = df_gen.dataframe_generator("../../results/results_*.csv").dataframe


    generate_scatterplot(df)
    #generate_summary_table(df)
    #generate_boxplots(df)
    
    # Generate "multi"-bar plot or scatter plot

if __name__ == '__main__':
    main()