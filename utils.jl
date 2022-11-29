using Graphs

"""
    readinstance(file = stdin)

Read an instance for front-door from the standard input or a given file and return it.

"""
function readgraph(file = stdin)
    if file != stdin
        infile = open(file, "r")
    else
        infile = stdin
    end
    (n, m) = parse.(Int, split(readline(infile)))
    X = Set{Integer}(parse.(Int, split(readline(infile))))
    Y = Set{Integer}(parse.(Int, split(readline(infile))))
    I = Set{Integer}(parse.(Int, split(readline(infile))))
    R = Set{Integer}(parse.(Int, split(readline(infile))))
    G = SimpleDiGraph(n)
    for i = 1:m
        (a, b) = parse.(Int, split(readline(infile)))
        add_edge!(G, a, b)
    end
    if file != stdin
        close(infile)
    end
    return G, X, Y, I, R
end

function removeinc!(G, S)
  G.ne = 0
  for i = 1:nv(G)
    if i in S
      empty!(G.badjlist[i])
      G.ne += length(G.fadjlist[i])
    else 
      filter!(j->!(j in S), G.fadjlist[i])
      G.ne += length(G.fadjlist[i])
    end
  end
end

function removeout!(G, S)
  G.ne = 0
  for i = 1:nv(G)
    if i in S
      empty!(G.fadjlist[i])
      G.ne += length(G.fadjlist[i])
    else 
      filter!(j->!(j in S), G.badjlist[i])
      G.ne += length(G.fadjlist[i])
    end
  end
end


function classicbb(G, Z, v, edgetype, visited, reachable)
  visited[2*v+edgetype] = true
  push!(reachable, v)
  if !(v in Z)
    for u in outneighbors(G, v)
      if !visited[2*u]
        classicbb(G, Z, u, 0, visited, reachable)
      end
    end
  end

  if (edgetype == 0 && (v in Z)) || (edgetype == 1 && !(v in Z))
    for u in inneighbors(G, v)
      if !visited[2*u+1]
        classicbb(G, Z, u, 1, visited, reachable)
      end
    end
  end
end

function reach(G, X, Z)
  visited = falses(2*nv(G) + 1)
  reachable = Set{Integer}()
  for x in X
    for edgetype in [0,1]
      if !visited[2*x + edgetype]
        classicbb(G, Z, x, edgetype, visited, reachable)
      end
    end
  end
  return reachable
end

function dfs(G, Z, u, visited)
  visited[u] = true
  for v in outneighbors(G, u)
    if !(v in Z) && !visited[v]
      dfs(G, Z, v, visited)
    end
  end
end

function checkfirst(G, X, Y, Z)
  visited = falses(nv(G))
  for x in X
    if !visited[x]
      dfs(G, Z, x, visited)
    end
  end
  for y in Y
    if visited[y]
      return false
    end
  end
  return true
end
