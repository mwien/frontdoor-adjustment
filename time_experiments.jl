using Random
using Statistics

include("frontdoor.jl")
include("minimal.jl")
include("generate.jl")
include("experiment_utils.jl")

function doubleprintln(file, s)
	println(s)
	println(file, s)
end

function experiments()
    # parameter setup
	Random.seed!(1234)
    numvertices = [2^x for x=4:17]
    expdeg = [3, 5, 10] 
	Rdiv = [2, 4]
    xy = ["rand", "log"]
    repmax = 50
    algorithms = ["findpy", "minpy", "jtbpy", "findjl", "minjl", "findjs", "minjs"] 
    maxtime = 30
    file = "results/timeresults.ans"
    outfile = open(file, "a")
	fullfile = "results/timefullresults.ans"
	fulloutfile = open(fullfile, "a")
    doubleprintln(outfile, "Results are written to '$file'.")
	doubleprintln(outfile, "rdiv,n,xysz,d,alg,avgtime,stdtime")
	println(fulloutfile, "rdiv,n,xysz,d,rep,alg,time")

    # perform experiments
	for xymethod in xy, rdiv in Rdiv, n in numvertices
		xysz = round(Int, log2(n))-3
        for d in expdeg 
		    flush(outfile)
            times = Dict(alg => Vector{Float64}() for alg in algorithms)
            results = Dict{String, Any}(alg => nothing for alg in algorithms)
            numfd = 0
            maxfd = Vector{Int64}()
            minfd = Vector{Int64}()
            for rep = 1:repmax
                # generate graph and sets
                instance = nothing
                if xymethod == "rand"
                    instance = generateinstance("return", n, rand(1:3), rand(1:3), 0, div(n, rdiv), d)
                    xysz = "rand"
                else
                    instance = generateinstance("return", n, xysz, xysz, 0, div(n, rdiv), d)
                end

                name = "$rdiv-$n-$xysz-$d-$rep"
                writefd(instance..., "instances/$name.in")                
                # run the algorithms
                for algo in algorithms
                    result, mtime = runinstance(algo, instance, maxtime, name)
                    if mtime == -1
                        doubleprintln(outfile, "ERROR for algorithm $algo on $rep: $result")
                            result = "error"
                    end
                    if mtime >= maxtime
                        result = "timeout"
                        mtime = 10^9
                    end
                    push!(times[algo], mtime)
                    results[algo] = result
                    println(fulloutfile, "$rdiv,$n,$xysz,$d,$rep,$algo,$mtime")
                    flush(fulloutfile)
                end

                # check results
                numfalse = 0
                numtimeout = 0
                numerror = 0
                for (algo, result) in  results
                    if result == false
                        numfalse += 1
                    elseif result == "timeout"
                        numtimeout += 1
                    elseif result == "error"
                        numerror += 1
                    else 
                        # do sanity checks
                        !isfrontdoor(instance..., result) && doubleprintln(file, "ERROR: $algo gave incorrect FD set on $name")
                        (algo == "minjl" || algo == "minpy" || algo == "minjs") && length(result) < 10 && !isminimal(instance..., result) && doubleprintln(outfile, "ERROR: $algo did not give minimal FD set")
                    end
                end
                if numfalse > 0 && numfalse < length(algorithms) - numtimeout - numerror
                    doubleprintln(outfile, "ERROR: inconsistent results")
                end
            end

            # print results
            for io in [outfile, stdout]
                for alg in algorithms
			        print(io, "$rdiv,$n,$xysz,$d,")
			        print(io, alg)
                    for (metric, fct) in Dict("avg" => mean, "std" => std)
                        print(io, ",$(fct(times[alg]))")
                    end
			        println(io)
                end
                flush(io)
            end
        end
    end
end

experiments()
