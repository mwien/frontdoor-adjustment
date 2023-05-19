using Graphs

include("graph_utils.jl")

function bdbb(G, Z, X, v, edgetype, visited, reachable)
    visited[2*v+edgetype] = true
    reachable[v] = true
    if !(v in Z) && !(v in X)
        for u in outneighbors(G, v)
            if !visited[2*u]
                bdbb(G, Z, X, u, 0, visited, reachable)
            end
        end
    end

    if (edgetype == 0 && (v in Z)) || (edgetype == 1 && !(v in Z))
        for u in inneighbors(G, v)
            if !visited[2*u+1]
                bdbb(G, Z, X, u, 1, visited, reachable)
            end
        end
    end
end

function reachbd(G, X, Z)
    visited = falses(2*nv(G) + 1)
    reachable = falses(nv(G))
    for x in X
        for edgetype in [0,1]
            if !visited[2*x + edgetype]
                bdbb(G, Z, X, x, edgetype, visited, reachable)
            end
        end
    end
    return Set{Int64}(findall(any, reachable))
end

function modbb(G, X, v, edgetype, visited, continuelater, forbidden)
    visited[2*v+edgetype] = true
    forbidden[v] = true
    if !(v in X)
        for u in outneighbors(G, v)
            if !visited[2*u]
                modbb(G, X, u, 0, visited, continuelater, forbidden)
            end
        end
    end

    if (edgetype == 0 && v in X) || (edgetype == 1 && !(v in X))
        for u in inneighbors(G, v)
            if forbidden[u] && !visited[2*u+1]
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

function finda(G, X, R)
    reachable = reachbd(G, X, Set{Integer}())
    return setdiff(R, reachable)
end

function findab(G, X, Y, Za)
    visited = falses(2*nv(G) + 1)
    continuelater = falses(nv(G))
    save = setdiff(Set{Integer}(vertices(G)), Za)
    forbidden = [x in save for x in 1:nv(G)] 
        for y in Y
            for edgetype in [0,1]
                modbb(G, X, y, edgetype, visited, continuelater, forbidden)
            end
        end

        return setdiff(Za, Set{Int64}(findall(any, forbidden)))
    end

# could make this even faster by using bool arrays instead of sets
function frontdoor(G, X, Y, I, R, debug = false)
    Za = finda(G, X, R)
    debug && println(sort(collect(Za)))
    Zab = findab(G, X, Y, Za)
    debug && println(sort(collect(Zab)))
    if issubset(I, Zab) && checkfirst(G, X, Y, Zab)
        return Zab
    else
        return false
    end
end


function enumerate(G, X, Y, I, R, type, res)
    if frontdoor(G, X, Y, I, R) != false
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
            enumerate(G, X, Y, I, R, type, res)
            delete!(I, v)
            delete!(R, v)
            enumerate(G, X, Y, I, R, type, res)
            push!(R, v)
        end
    end
end

