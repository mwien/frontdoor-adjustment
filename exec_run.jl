include("experiment_utils.jl")
include("frontdoor.jl")
include("minimal.jl")

# Call with julia exec_run.jl problem alg file

algorithmfunction = Dict("findjl" => frontdoor, "minjl" => minimal_frontdoor)

input = parsein(ARGS[3], ARGS[1])

algorithmfunction[ARGS[2]](input...)
GC.gc()
GC.gc()
GC.gc()
GC.gc()
time = @elapsed result = algorithmfunction[ARGS[2]](input...)

if result == false
    println("no")
else
    println(join(collect(result), " "))
end
println(time)
