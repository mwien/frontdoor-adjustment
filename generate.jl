using Graphs
using Random

function writeset(io, S)
  for s in S
    write(io, "$s ")
  end
  write(io, "\n")
end


function generategraph(n, d)
  G = SimpleDiGraph(n)
  
    ecount = 0
#	cnt = 0
    while ecount < d*n/2 && ecount < binomial(n, 2)
        a = rand(1:n)
        b = rand(1:n)

#	cnt += 1

#	if cnt % 10^6 == 0
#		println(a, b)
#	end

        if b < a
            tmp = a
            a = b
            b = tmp
        end

        if a != b && !has_edge(G, a, b)
            add_edge!(G, a, b)
		add_edge!(G, b, a)
            ecount += 1
        end
    end
  ts = randperm(n)
  for a in 1:n, b in inneighbors(G, a)
    ts[b] < ts[a] && rem_edge!(G, a, b)
  end
  return G
end

function generateinstance(id, n, xsize, ysize, isize, rsize, dens)
  X = Set{Integer}(1:xsize)
  Y = Set{Integer}((n-ysize+1):n)
  R = Set{Integer}((xsize+1):(n-ysize))
  while(length(R) > rsize)
    rem = rand(R)
    delete!(R, rem)
  end
  #I = copy(R)
  #while(length(I) > isize)
  #  rem = rand(I)
  #  delete!(I, rem)
  #end
  I = Set{Integer}()
  G = generategraph(n, dens)
  if id != "return"
    writeinstance(G, X, Y, I, R, "instances/$id.in")
    else
    return G, X, Y, I, R
    end
end

function generateinstances()
  for rep in 1:50
    for n in [10, 20, 30, 40, 50, 60]
      for dens in [0.025, 0.05, 0.1, 0.2]
        generateinstance("$n-$dens-$rep", n, div(n, 10), div(n, 10), div(n, 10), div(n, 2), dens) 
      end
    end
  end
end
