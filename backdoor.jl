using Graphs

function mdfs(G, F, u, visited, N)
  visited[u] = true
  for v in N(G, u)
    if !(v in F) && !visited[v]
      mdfs(G, F, v, visited, N)
    end
  end
end

function search(G, S, F, N)
    visited = falses(nv(G))
    for s in S
        if !visited[s]
            mdfs(G, F, s, visited, N)
        end
    end
    return Set{Int64}(findall(any, visited))
end

function mbb(G, v, edgetype, Z, X, PCP, visited, reachable)
  visited[2*v+edgetype] = true
  reachable[v] = true
  if !(v in Z)
    for u in outneighbors(G, v)
        if !visited[2*u] && !(v in X && u in PCP)
            mbb(G, u, 0, Z, X, PCP, visited, reachable)
        end
    end
  end

  if (edgetype == 0 && (v in Z)) || (edgetype == 1 && !(v in Z))
    for u in inneighbors(G, v)
        if !visited[2*u+1] && !(u in X && v in PCP)
            mbb(G, u, 1, Z, X, PCP, visited, reachable)
        end
    end
  end
end

function bbsearch(G, S, T, Z, PCP)
    visited = falses(2*nv(G)+1)
    reachable = falses(nv(G))
    for s in S
        for e in [0,1]
            if !visited[2*s+e]
                mbb(G, s, e, Z, S, PCP, visited, reachable)
            end
        end
    end
    for t in T
        if reachable[t]
            return false
        end
    end
    return true
end

function naivesearch(G, S, T, EF, ET)
    visited = falses(2*nv(G)+1)
    reachable = falses(nv(G))
    for s in S
        for e in [0,1]
            if !visited[2*s+e]
                mbb(G, s, e, Set{Int64}(), EF, ET, visited, reachable)
            end
        end
    end
    for t in T
        if reachable[t]
            return false
        end
    end
    return true
end

function pcp(G, X, Y)
    return intersect(setdiff(search(G, X, X, outneighbors), X), search(G, Y, X, inneighbors))
end

function dpcp(G, X, Y)
    return search(G, pcp(G, X, Y), Set{Int64}(), outneighbors)
end

function backdoor(G, X, Y, I, R)
    PCP = pcp(G, X, Y)
    adj = setdiff(intersect(search(G, union(union(X, Y), I), Set{Int64}(), inneighbors), R), union(union(X, Y), dpcp(G, X, Y)))
    if bbsearch(G, X, Y, adj, PCP)
        return adj
    end
    return false
end

function naive(G, X, Y, I, R)
    if naivesearch(G, X, Y, Set{Int64}(vertices(G)), X)
        return Set{Int64}()
    else
        return false
    end
end


function backdoorplus(G, X, Y, I, R)
    PCP = pcp(G, X, Y)
    adj = setdiff(intersect(search(G, union(union(X, Y), I), Set{Int64}(), inneighbors), R), union(union(X, Y), dpcp(G, X, Y)))
    if bbsearch(G, X, Y, adj, PCP)
        return adj
    end
    if naivesearch(G, X, Y, Set{Int64}(vertices(G)), X)
        return Set{Int64}()
    end
    return false
end
