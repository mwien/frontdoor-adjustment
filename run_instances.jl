include("frontdoor.jl")

function testinstances(type)
  for (root, dirs, files) in walkdir("instances")
    for file in files
      G, X, Y, I, R = readgraph(joinpath(root, file))
      println("Instance: " * file)
      if type == "find"
        Z = findfrontdoor(G, X, Y, I, R)
        if Z == false
          println("No front-door adjustment set")
        else
          println(Z)
        end
      end
      if type == "enumerate"
        res = Vector{Set{Integer}}()
        enumeratefrontdoor(G, X, Y, I, R, "set", res)
        println(res)
      end
    end
  end
end
