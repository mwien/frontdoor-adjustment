using Random
using Statistics

include("frontdoor.jl")
include("minimal.jl")
include("backdoor.jl")
include("generate.jl")
include("experiment_utils.jl")

function doubleprintln(outfile, s)
    println(outfile, s)
    println(s)
    flush(stdout)
    flush(outfile)
end

function experiments()
    # parameter setup
    Random.seed!(1235)
    numvertices = [2^x for x = 4:17]
    expdeg = [3, 5, 10]
    repmax = 10000
    Rdiv = [2, 4]
    xy = ["rand", "log"]
    file = "results/ratioresults.ans"
    outfile = open(file, "a")
    println("Results are written to '$file'.")
    doubleprintln(outfile, "rdiv,n,xysz,d,alg,avg,[std]")

    for xymethod in xy, rdiv in Rdiv, n in numvertices      
		xysz = round(Int, log2(n))-3
        for d in expdeg
            #doubleprintln(outfile, "Computing for n=" * string(n) * " and d=" * string(d))
            hasfd = Set{Int64}()
            hasbd = Set{Int64}()
            hasnaive = Set{Int64}()
            hasbdp = Set{Int64}()
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
                
                Z = frontdoor(instance...)
                if Z != false
                    push!(hasfd, rep)
                    push!(maxfd, length(Z))
                end

                Z = minimal_frontdoor(instance...)
                if Z != false
                    push!(minfd, length(Z))
                end

                Z = backdoor(instance...)
                if Z != false
                    push!(hasbd, rep)
                end

                Z = backdoorplus(instance...)
                if Z != false
                    push!(hasbdp, rep)
                end

                # naive checks directly for fdzero
                Z = naive(instance...)
                if Z != false
                    push!(hasnaive, rep)
                end
            end

            doubleprintln(outfile, "$rdiv,$n,$xysz,$d,fdratio," * string(length(hasfd)/repmax))
            doubleprintln(outfile, "$rdiv,$n,$xysz,$d,bdratio," * string(length(hasbd)/repmax))
            doubleprintln(outfile, "$rdiv,$n,$xysz,$d,naiveratio," * string(length(hasnaive)/repmax))
            doubleprintln(outfile, "$rdiv,$n,$xysz,$d,bdplusratio," * string(length(hasbdp)/repmax))

            doubleprintln(outfile, "$rdiv,$n,$xysz,$d,max," * string(mean(maxfd)) * "," * string(std(maxfd)))
            doubleprintln(outfile, "$rdiv,$n,$xysz,$d,min," * string(mean(minfd)) * "," * string(std(minfd)))
        end
    end
end

experiments()
