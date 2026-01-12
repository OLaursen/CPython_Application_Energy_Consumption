#!/bin/bash
# Run this script with desired Python Versions as Argument (e.g., ./run_benchmarks.sh 3.9.23)

# Function to run benchmarks on a specific Python version
run_benchmarks() {
    PYENV=$1
    PYTHON_BIN="~/.pyenv/versions/$PYENV/bin/python"
    $PYTHON_BIN -m pyperformance run --benchmark=2to3, chamelon, docutils, html5lib, tornado_http, async_generators, async_tree_none, async_tree_cpu_io_mixed, async_tree_memoization, float, nbody, pidigits, regex_compile, regex_dna, json_dumps, json_loads, pickle_list, pickle_dict, python_startup, python_startup_no_site, genshi_txt, mako -o $PYENV.json
}

# Script finds path to desired Python version
#Make it so that it finds the correct pyenv binary
run_benchmarks $1

echo "Benchmarking complete for $1."
