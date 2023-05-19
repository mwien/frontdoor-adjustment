import networkx as nx
import frontdoor as fd
from functools import partial
import sys
import time
import gc

def inunion(w, *sets):
    for S in sets:
        if w in S:
            return True
    return False

def genvisit(G, v, prevedge, visited, result, rules):
    # init = -1 and 0,1 encode edge orientation
    if prevedge != -1:
        visited[2*v+prevedge] = True
    for nextedge in [0, 1]:
        if nextedge == 0: 
            neighbors = G.successors(v)
        if nextedge == 1:
            neighbors = G.predecessors(v)
        for w in neighbors:
            r = rules(prevedge, nextedge, v, w)
            if "yield" in r:
                result[w] = True
            if not visited[2*w + nextedge] and "continue" in r:
                genvisit(G, w, nextedge, visited, result, rules)

def gensearch(G, S, rules):
    visited = [False] * (2*len(G.nodes))
    result = [False] * len(G.nodes)
    for v in S:
        genvisit(G, v, -1, visited, result, rules)
    return {i for i, x in enumerate(result) if x}

def Za_rules(thisedge, nextedge, v, w, X, Y, Zii):
    ops = []
    if thisedge in [-1, 1] and nextedge == 1:
        if not inunion(w, X, Y, Zii): 
            ops.append("continue")
        if w in Zii:
            ops.append("yield")
    return ops

def Zxy_rules(thisedge, nextedge, v, w, X, Y, I, Za):
    ops = []
    if thisedge in [-1, 0] and nextedge == 0:
        if not inunion(w, X, Y, I, Za):
            ops.append("continue")
        if w in Za: 
            ops.append("yield") 
    return ops

def Zzy_rules(thisedge, nextedge, v, w, X, I, Zxy, Za):
    ops = []
    if thisedge in [-1, 1] and nextedge == 1:
        if not inunion(w, X, I, Zxy):
            ops.append("continue")
        if w in Za:
            ops.append("yield")

    if thisedge in [0, 1] and nextedge == 0:
        if w not in X and not inunion(v, I, Za):
            ops.append("continue")
        if w in Za and not inunion(v, I, Za):
            ops.append("yield")

    if thisedge == 0 and nextedge == 1:
        if inunion(v, I, Za) and not inunion(w, X, I, Zxy): 
            ops.append("continue")
        if inunion(v, I, Za) and w in Za:
            ops.append("yield") 
    return ops

def minimal_frontdoor(G, X, Y, I, R):
    Zii = fd.frontdoor(G, X, Y, I, R)
    if Zii == False:
        return False
    Za = gensearch(G, Y, partial(Za_rules, X = X, Y = Y, Zii = Zii))
    Zxy = gensearch(G, X, partial(Zxy_rules, X = X, Y = Y, I = I, Za = Za))
    Zzy = gensearch(G, I.union(Zxy), partial(Zzy_rules, X = X, I = I, Zxy = Zxy, Za = Za))
    return I.union(Zxy).union(Zzy)

if __name__ == "__main__":
    G, X, Y, I, R = fd.readgraph(sys.argv[1])
    gc.collect()
    start_time = time.time()
    result = minimal_frontdoor(G, X, Y, I, R)
    end_time = time.time()
    if result == False:
        print("no")
    else:
        result = {r + 1 for r in result}
        print(*result) 
    print(end_time - start_time)
