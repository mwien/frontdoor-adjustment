import sys
import networkx as nx
import time
import gc

# some helpers
def readgraph(file):
    f = open(file, "r")
    n, m = map(int, f.readline().split())
    X = {x-1 for x in map(int, f.readline().split())}
    Y = {y-1 for y in map(int, f.readline().split())}
    I = {i-1 for i in map(int, f.readline().split())}
    R = {r-1 for r in map(int, f.readline().split())}
    G = nx.DiGraph()
    G.add_nodes_from(range(n))
    for i in range(m):
        a, b = map(int, f.readline().split())
        G.add_edge(a-1, b-1)
    f.close()
    return G, X, Y, I, R

def classicbb(G, Z, X, v, edgetype, visited, reachable):
    visited[2*v+edgetype] = True
    reachable[v] = True
    if v not in Z and v not in X:
        for u in G.successors(v):
            if not visited[2*u]:
                classicbb(G, Z, X, u, 0, visited, reachable)

    if (edgetype == 0 and v in Z) or (edgetype == 1 and v not in Z):
        for u in G.predecessors(v):
            if not visited[2*u+1]:
                classicbb(G, Z, X, u, 1, visited, reachable)

def reach(G, X, Z):
    visited = [False] * (2*len(G.nodes) + 1)
    reachable = [False] * (len(G.nodes))
    for x in X:
        for edgetype in [0,1]:
            if not visited[2*x + edgetype]:
                classicbb(G, Z, X, x, edgetype, visited, reachable)
    return {i for i, x in enumerate(reachable) if x}

def modbb(G, X, v, edgetype, visited, continuelater, forbidden):
    visited[2*v+edgetype] = True
    forbidden[v] = True
    if v not in X:
        for u in G.successors(v):
            if not visited[2*u]:
                modbb(G, X, u, 0, visited, continuelater, forbidden)

    if (edgetype == 0 and v in X) or (edgetype == 1 and v not in X):
        for u in G.predecessors(v):
            if forbidden[u] and not visited[2*u+1]:
                modbb(G, X, u, 1, visited, continuelater, forbidden)
            elif not visited[2*u+1]:
                continuelater[u] = True

    if continuelater[v] and not visited[2*v+1]:
        modbb(G, X, v, 1, visited, continuelater, forbidden)

def dfs(G, Z, u, visited):
    visited[u] = True 
    for v in G.successors(u):
        if v not in Z and not visited[v]:
            dfs(G, Z, v, visited)

# frontdoor stuff
def checkfirst(G, X, Y, Z):
    visited = [False] * len(G.nodes)
    for x in X:
        if not visited[x]:
            dfs(G, Z, x, visited)
    for y in Y:
        if visited[y]:
            return False
    return True

def finda(G, X, R):
    # TODO: just dont do the copy!!! modify classicbb
    # H = G.copy()
    # edges = list(H.out_edges(X))
    # H.remove_edges_from(edges)
    reachable = reach(G, X, set())
    return R.difference(reachable)

def findab(G, X, Y, Za):
    visited = [False] * (2*len(G.nodes)+1)
    continuelater = [False] * len(G.nodes)
    sv = set(G.nodes).difference(Za)
    forbidden = [x in sv for x in range(len(G.nodes))]
    for y in Y:
        for edgetype in [0, 1]:
            modbb(G, X, y, edgetype, visited, continuelater, forbidden)
    return Za.difference({i for i, x in enumerate(forbidden) if x})

def frontdoor(G, X, Y, I, R, debug=False):
    Za = finda(G, X, R)
    #print(Za)
    Zab = findab(G, X, Y, Za)
    #print(Zab)
    if I.issubset(Zab) and checkfirst(G, X, Y, Zab):
        return Zab
    else:
        return False

def fdenumerate(G, X, Y, I, R, type, res):
    if frontdoor(G, X, Y, I, R) is not False:
        if set(I) == R:
            if type == "print":
                print(list(I))
            if type == "set":
                res.append(I.copy())
        else:
            v = R.difference(I).pop()
            I.add(v)
            enumerate(G, X, Y, I, R, type, res)
            I.remove(v)
            R.remove(v)
            enumerate(G, X, Y, I, R, type, res)
            R.add(v)


if __name__ == "__main__":
    G, X, Y, I, R = readgraph(sys.argv[1])
    gc.collect()
    start_time = time.time()
    result = frontdoor(G, X, Y, I, R)
    end_time = time.time()
    if result == False:
        print("no")
    else:
        result = {r + 1 for r in result}
        print(*result) 
    print(end_time - start_time)

