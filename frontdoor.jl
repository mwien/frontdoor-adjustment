using Graphs

include("utils.jl")

function modbb(G, X, v, edgetype, visited, continuelater, forbidden)
  visited[2*v+edgetype] = true
  push!(forbidden, v)
  if !(v in X)
    for u in outneighbors(G, v)
      if !visited[2*u]
        modbb(G, X, u, 0, visited, continuelater, forbidden)
      end
    end
  end

  if (edgetype == 0 && v in X) || (edgetype == 1 && !(v in X))
    for u in inneighbors(G, v)
      if u in forbidden && !visited[2*u+1]
        modbb(G, X, u, 1, visited, continuelater, forbidden)
      elseif !visited[2*u+1]
        continuelater[u] = true
      end
    end
  end

  if continuelater[v] && !visited[2*v+1]
    modbb(G, X, v, 1, visited, continuelater, forbidden)
  end
end

function findi(G, X, C)
  H = copy(G)
  removeout!(H, X)
  reachable = reach(H, X, Set{Integer}())
  return setdiff(C, reachable)
end

function findii(G, X, Y, Zi)
  visited = falses(2*nv(G) + 1)
  continuelater = falses(nv(G))
  forbidden = setdiff(Set{Integer}(vertices(G)), Zi)
  for y in Y
    for edgetype in [0,1]
      modbb(G, X, y, edgetype, visited, continuelater, forbidden)
    end
  end

  return setdiff(Zi, forbidden)
end

function findfrontdoor(G, X, Y, I, R)
  C = intersect(setdiff(Set(vertices(G)), union(X, Y)), R)
  Zi = findi(G, X, C)
  Zii = findii(G, X, Y, Zi)
  if issubset(I, Zii) && checkfirst(G, X, Y, Zii)
    return Zii
  else
    return false
  end
end


function enumeratefrontdoor(G, X, Y, I, R, type, res)
  if findfrontdoor(G, X, Y, I, R) != false
    if issetequal(I, R) 
      if type == "print"
        println(I)
      end
      if type == "set"
        push!(res, copy(I))
      end
    else
      v = first(setdiff(R, I))
      push!(I, v)
      enumeratefrontdoor(G, X, Y, I, R, type, res)
      delete!(I, v)
      delete!(R, v)
      enumeratefrontdoor(G, X, Y, I, R, type, res)
      push!(R, v)
    end
  end
end
