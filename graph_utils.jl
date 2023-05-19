using Graphs

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

function checksecond(G, X, Y, Z)
    H = copy(G)
    removeout!(H, X)
    reachable = reach(H, X, Set{Integer}())
    if isempty(intersect(reachable, Z))
        return true
    else
        return false
    end
end

function checkthird(G, X, Y, Z)
    H = copy(G)
    removeout!(H, Z)
    reachable = reach(H, Z, X)
    if isempty(intersect(reachable, Y))
        return true
    else
        return false
    end
end

function isfrontdoor(G, X, Y, I, R, Z)
    checkfirst(G, X, Y, Z) && checksecond(G, X, Y, Z) && checkthird(G, X, Y, Z)
end
