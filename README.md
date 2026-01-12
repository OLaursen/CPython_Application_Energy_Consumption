## Python Application Energy Consumption
This is the companion repository for the thesis *"Python Application Energy Consumption: Investigating Operating System, Python Version and Hardware Impact on the Energy Consumption of Application Benchmarks"*.

The repository contains all the code used to run the experiment for measuring the energy consumption of application benchmarks presented in the thesis. 

The repository also contains all results reported in the thesis.

For the full insctruction set for running the experiment, see the wiki found on this page.

The contents herein are made freely available under the MIT license.

All the code herein was written with some assistance from ChatGPT.


## Experiment notes
- Needs to have enable ssh mounted in the disk image
- - Enable ssh - use PaswordAuthentication
- Also have to set password and user if ssh'ing

### Pyperformance benchmarks used in the experiment
2to3, chamelon, docutils, html5lib, tornado_http, async_generators, async_tree_none, async_tree_cpu_io_mixed, async_tree_memoization, float, nbody, pidigits, regex_compile, regex_dna, json_dumps, json_loads, pickle_list, pickle_dict, python_startup, python_startup_no_site, genshi_txt, mako

#### On controller pc ensure that:
otii-tcp-client and paramiko is installed. 


