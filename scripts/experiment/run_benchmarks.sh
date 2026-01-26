#!/bin/bash

# Run benchmarks for a specified Python version using pyperformance
# ./run_benchmarks.sh <python-version>
# Example usage: ./run_benchmarks.sh 3.10.18 


PYTHON_VERSION=$1
PYTHON_BIN="$HOME/.pyenv/versions/$PYTHON_VERSION/bin/python"
# Check if pyenv with given version is installed as well as pyperformance
if ! pyenv versions --bare | grep -q "^$PYTHON_VERSION$"; then
    echo "Python version $PYTHON_VERSION is not installed via pyenv."
    exit 1
fi


$PYTHON_BIN -m pyperformance run --benchmark=2to3,docutils,html5lib,tornado_http,async_generators,float,nbody,pidigits,regex_compile,json_dumps,json_loads,pickle_list,python_startup -o $PYTHON_VERSION.json
echo "Benchmarking complete for $PYTHON_VERSION."