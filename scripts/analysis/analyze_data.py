import boxplot_generator as bp_gen

def generate_boxplots():
    boxplot = bp_gen.boxplot_generator("../../results/results_*.csv",
                                       {'Distro': 'Operating System','Version': 'Python Version','RPi': 'Raspberry Pi Model'})
    boxplot.generate_boxplot_files_for_each_group()

def main(): 
    generate_boxplots()

    # Generate "multi"-bar plot
    # Kruskal ¿test?
    # Create summary table

if __name__ == '__main__':
    main()