# Efficient algorithms for Front-Door Adjustment
  The files ```run_instances.jl``` contains a function ```testinstances(type)```, which for ```type = "find"``` outputs for each instance a frontdoor-adjustment set if it exists and for ```type = "enumerate"``` returns a set of all frontdoor-adjustment sets.

  Hence, e.g., to run the algorithm for finding front-door adjustment sets, do 
  ```julia
  include("run_instances.jl")
  testinstances("find")
  ```
  in the Julia REPL.  


  Internally, the functions ```findfrontdoor``` and ```enumeratefrontdoor``` in file frontdoor.jl are called, which are implementations of the algorithms presented in the paper: Finding Front-Door Adjustment Sets in Linear Time; Marcel Wienöbst, Benito van der Zander, Maciej Liskiewicz (available on arXiv under https://arxiv.org/abs/2211.16468). The time complexity of ```findfrontdoor``` is $O(n+m)$ and ```enumeratefrontdoor``` has delay $O(n(n+m))$. 

  The instances should be specified as follows: The first line contains the number of variables $n$ and edges $m$. The second line contains the vertices (separated by spaces) in X, the third the ones in Y, the fourth those in I and the fifth those in R. Then follow $m$ lines containing two variables $A$ and $B$ indicating the edge $A \rightarrow B$. It is assumed that the variables/vertices are numbered from $1$ to $n$ and that the graph is acyclic.
