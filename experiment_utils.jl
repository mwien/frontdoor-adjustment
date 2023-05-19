using DataStructures
using Graphs
using Combinatorics

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


function edgetostring(e)
    return "$(e.src) -> $(e.dst)"
end

function settosepstring(S, sep = " ")
    Sc = copy(S)
    isempty(Sc) && return ""
    out = string(pop!(Sc))
    for s in Sc
        out *= "$sep$s"
    end
    return out
end

function writejtb(G, X, Y, I, R)
    outfile = open("tmpjtb.in", "w")
    println(outfile, "<NODES>")
    println.(outfile, vertices(G))
    println(outfile, "")
    println(outfile, "<EDGES>")
    println.(outfile, edgetostring.(edges(G))) 
    println(outfile, "")
    println(outfile, "<TASK>")
    println(outfile, "treatment: $(settosepstring(X, ","))") 
    println(outfile, "outcome: $(settosepstring(Y, ","))")
    println(outfile, "")
    println(outfile, "<CONSTRAINTS>")
    println(outfile, "I: $(settosepstring(I, ","))")
    println(outfile, "R: $(settosepstring(R, ","))")
    flush(outfile)
    close(outfile)
end

function readjtbpy(output)
    ret = split(output, "\n")
    resultstring = ret[1]
    time = parse(Float64, ret[2]) 
    if resultstring == "No admissible set exists."
        result = false
    else
        resultstring = resultstring[17:end]
	# Admissible set: emptyset 
        	result = Set{Integer}()
		if !startswith(resultstring, "emptyset")
        		elements = filter(x -> !isempty(x), collect(eachsplit(resultstring, ",")))
        		for s in parse.(Int, elements)
            			push!(result, s)  
        		end
		end
    end
    return result, time
end

function readfindjs(output)
    ret = split(output, "\n")
    resultstring = ret[1]
    time = parse(Float64, ret[2]) 
    if resultstring == "no"
        result = false
    else
        resultstring = resultstring[5:end]
        result = Set{Integer}()
        elements = filter(x -> !isempty(x), collect(eachsplit(resultstring, " ")))
        for s in parse.(Int, elements)
            push!(result, s)  
        end
    end
    return result, time
end

function readjl(output)
    ret = split(output, "\n")
    resultstring = ret[1]
    time = parse(Float64, ret[2]) 
    if resultstring == "no" 
        result = false
    else
        result = Set{Integer}()
        elements = filter(x -> !isempty(x), collect(eachsplit(resultstring, " ")))
        for s in parse.(Int, elements)
            push!(result, s)  
        end
    end
    return result, time
end

function writefd(G, X, Y, I, R, file="tmp.in")
    outfile = open(file, "w")  
    n = nv(G)
    m = ne(G)
    println(outfile, "$n $m")
    println(outfile, settosepstring(X, " "))
    println(outfile, settosepstring(Y, " "))
    println(outfile, settosepstring(I, " "))
    println(outfile, settosepstring(R, " "))
    for u = 1:n
	for v in outneighbors(G, u)
		println(outfile, "$u $v")
	end
    end
    flush(outfile)
    close(outfile)
end

function runinstance(algo, input, timeout, name)
    # jl runs the algorithm two times, hence double the timeout
    # note that a run is still only counted if time is below timeout!
    # this is just the timeout for running the terminal command
    jltimeout = 2*timeout+10
    othertimeout = timeout+10
    output = ""
    if algo == "jtbpy"
        writejtb(input...)
    end
    try 
        if algo == "jtbpy"
            output = read(`timeout -k 10 $othertimeout python3 external/FrontdoorAdjustmentSets/main.py find tmpjtb.in`, String) 
        elseif algo == "findpy"
            output = read(`timeout -k 10 $othertimeout python3 frontdoor.py instances/$name.in`, String) 
        elseif algo == "minpy"
            output = read(`timeout -k 10 $othertimeout python3 minimal.py instances/$name.in`, String)
        elseif algo == "findjs"
            output = read(`timeout -k 10 $othertimeout node --expose-gc external/dagitty/jslib/dagitty-node.js instances/$name.in`, String)
        elseif algo == "minjs"
            output = read(`timeout -k 10 $othertimeout node --expose-gc external/dagitty/jslib/dagitty-node-min.js instances/$name.in`, String)
        else
            output = read(`timeout -k 10 $jltimeout julia exec_run.jl frontdoor $algo instances/$name.in`, String)
        end
    catch e
        if e.procs[1].exitcode == 124
            return ("timeout", 10^9)
        else 
            return ("other error", -1)
        end
    end
    try
        if algo == "jtbpy"
            return readjtbpy(output)
        elseif algo == "findjs" || algo == "minjs"
            return readfindjs(output)
        else
            return readjl(output)
        end
    catch
        return ("parseerror", -1)
    end
end

function isminimal(G, X, Y, I, R, result)
    if length(result) > 20
        return true
    end
    for S in powerset(collect(result))
        length(S) == length(result) && continue
        isfrontdoor(G, X, Y, I, R, Set{Integer}(S)) && return false
    end
    return true
end

function parsein(file, problem)
    if problem == "frontdoor"
        return readgraph(file) 
    end
end
