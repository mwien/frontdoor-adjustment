using Graphs

include("graph_utils.jl")
include("frontdoor.jl")

function inunion(w, sets...)
    for S in sets
        w in S && return true
    end
    return false
end

function genvisit(G, v, prevedge, visited, result, rules)
    # init = -1 and 0,1 encode edge orientation
    prevedge != -1 && (visited[2*v+prevedge] = true)
    for nextedge in [0, 1]  
        nextedge == 0 && (neighbors = outneighbors(G, v))
        nextedge == 1 && (neighbors = inneighbors(G, v))
        
        for w in neighbors
            r = rules(prevedge, nextedge, v, w)
            "yield" in r && (result[w] = true)
            !visited[2*w + nextedge] && ("continue" in r) && genvisit(G, w, nextedge, visited, result, rules)
        end
    end
end

function gensearch(G, S, rules)
    visited = falses(2*nv(G) + 1)
    result = falses(nv(G))
    for v in S
        genvisit(G, v, -1, visited, result, rules)
    end
    return Set{Int64}(findall(any, result))
end

function Za_rules(thisedge, nextedge, v, w, X, Y, Zii)
    ops = []
    if thisedge in [-1, 1] && nextedge == 1
        !inunion(w, X, Y, Zii) && push!(ops, "continue")
        w in Zii && push!(ops, "yield")
    end
    return ops
end

function Zxy_rules(thisedge, nextedge, v, w, X, Y, I, Za)
    ops = []
    if thisedge in [-1, 0] && nextedge == 0
        !inunion(w, X, Y, I, Za) && push!(ops, "continue")
        w in Za && push!(ops, "yield") 
    end
    return ops
end

function Zzy_rules(thisedge, nextedge, v, w, X, I, Zxy, Za)
    ops = []
    if thisedge in [-1, 1] && nextedge == 1
        !inunion(w, X, I, Zxy) && push!(ops, "continue")
        w in Za && push!(ops, "yield")
    end

    if thisedge in [0, 1] && nextedge == 0
        !(w in X) && !inunion(v, I, Za) && push!(ops, "continue")
        w in Za && !inunion(v, I, Za) && push!(ops, "yield")
    end

    if thisedge == 0 && nextedge == 1
        inunion(v, I, Za) && !inunion(w, X, I, Zxy) && push!(ops, "continue")
        inunion(v, I, Za) && w in Za && push!(ops, "yield") 
    end
    return ops
end

function minimal_frontdoor(G, X, Y, I, R)
    Zii = frontdoor(G, X, Y, I, R)
    Zii == false && return false 
    Za = gensearch(G, Y, (prev, next, v, w) -> Za_rules(prev, next, v, w, X, Y, Zii))
    Zxy = gensearch(G, X, (thisedge, nextedge, v, w) -> Zxy_rules(thisedge, nextedge, v, w, X, Y, I, Za))
    Zzy = gensearch(G, union(I, Zxy), (thisedge, nextedge, v, w) -> Zzy_rules(thisedge, nextedge, v, w, X, I, Zxy, Za))
    
    return union(I, Zxy, Zzy)
end



