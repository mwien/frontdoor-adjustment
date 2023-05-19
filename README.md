# Linear-Time Algorithms for Front-Door Adjustment in Causal Graphs

This repository is the official implementation of [Linear-Time Algorithms for Front-Door Adjustment in Causal Graphs](https://arxiv.org/abs/2211.16468). In particular, it contains the code to replicate the experimental results discussed in the paper.

As we compare algorithms in Julia, Python (ours and the ones given by Jeong et al.) and JavaScript, quite a few things have to be set up. This directory, however, should contain everything necessary except for:
- A Julia installation with dependencies specified below.
- A Python 3 installation with dependencies specified below.
- A Node.js and npm installation with dependencies specified below.

Installation of the dependencies:
- Run ```pip install -r requirements_py.txt``` and ```julia requirements.jl``` in this directory. 
- Run ```cat requirements_js.txt | xargs npm install``` in ```external/dagitty/jslib``` (our JavaScript implementation needs Dagitty to run, of which we provide a fork under ```external/dagitty```; see https://github.com/jtextor/dagitty for the original dagitty package).
- Run ```pip install -r requirements_py.txt``` in ```external/FrontdoorAdjustmentSets/``` (this contains the code by Jeong et al., slightly modified to integrate with our experiments; see the original package here: https://github.com/CausalAILab/FrontdoorAdjustmentSets).

The Julia file ```time_experiments.jl``` starts the run time comparison of the various algorithms (it can be called via command line by ```julia time_experiments.jl```). The results are written to ```results/timeresults.ans``` and ```results/timefullresults.ans```. Running the full experiments takes a few days. 

In case there are errors it may help to check for each of the programs separately if it runs correctly. Below is a short description, how to do that for each by calling the given command from this directory:

- findpy: ```python3 frontdoor.py instances/1.in```
- minpy: ```python3 minimal.py instances/1.in```
- jtbpy: ```python3 external/FrontdoorAdjustmentSets/main.py find external/FrontdoorAdjustmentSets/graphs/fig1a.txt```
- findjs: ```node external/dagitty/jslib/dagitty-node.js instances/1.in```
- minjs: ```node external/dagitty/jslib/dagitty-node-min.js instances/1.in```
- findjl: ```julia exec_run.jl frontdoor findjl instances/1.in```
- minjl: ```julia exec_run.jl frontdoor minjl instances/1.in```

In case you are not able to run one of the programs, you can remove them from the algorithms list (line 4 of ```time_experiments.jl```), so that only at least the other programs/methods are executed. 

The experiments concerning the size of the maximal/minimal FD set and the ratio of identified instances can be started by running ```julia ratio_experiments.jl``` and should need no further setup. The results are written to ```results/ratioresults.ans```.

The plots of all experimental results and the raw experimental data (in text files) are provided under ```results/plotsandresults/```.

The results of your runs will be stored in ```results/```.
