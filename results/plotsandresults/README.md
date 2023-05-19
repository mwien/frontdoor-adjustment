This folder contains a PDF ```plots/allplots.pdf``` with plots for all experiments performed for this paper. The title of each plot together with the explanation in the appendix should make the contents of each plot (and the parameter settings) sufficiently clear.

The folder also contains the raw results of the experiments in text files.

Note that the particular ratios in ratioexperiments.jl can differ from what you would get if you start ```julia ratio_experiments.jl``` as (i) during the experiments, the different choices for |X|,|Y| were tried at different times and later merged and (ii) the experiments were originally started at 8 vertices for |X|,|Y| randomly drawn between 1 and 3 (we removed these cases later as they do not make much sense, particularly for expected degree 10, which is simply not possible (the graph generator would always return the complete graph)). These differences are minor and the conclusions are of course unaltered.
