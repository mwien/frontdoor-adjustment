# Efficient algorithms for Frontdoor-Adjustment
  The files run_instances.jl contains a function testinstances(type), which for type = "find" outputs for each instance a frontdoor-adjustment set if it exists and for type = "enumerate" returns a set of all frontdoor-adjustment sets.

  For this it calls the functions findfrontdoor and enumeratefrontdoor in file frontdoor.jl, which are implementations of the algorithms presented in the paper "Finding Front-Door Adjustment Sets in Linear Time". 

  The instances should be specified as follows: The first line contains the number of variables $n$ and edges $m$. The second line contains the vertices (separated by spaces) in X, the third in Y, the fourth in I and the fifth in R. Then follow $m$ lines containing two variables $A$ and $B$ indicating the edge $A \rightarrow B$. It is assumed that the variables/vertices are numbered from $1$ to $n$.
