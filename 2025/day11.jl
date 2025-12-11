module Day11

using AdventOfCode
using DataStructures: Deque

const YEAR = 2025
const DAY = 11

"""
DAG path counting via topological sort.

Part One: Count paths from "you" to "out"
Part Two: Product of three path segments (svr→dac→fft→out or svr→fft→dac→out)
"""

struct Graph
    n::Int
    edges::Vector{Vector{Int}}
    mapping::Dict{String, Int}
    topo::Vector{Int}
end

function build_graph(input)
    connections = [split(line, r": | ") for line in input]
    all_names = collect(Set(Iterators.flatten(connections)))
    mapping = Dict(name => idx for (idx, name) in enumerate(all_names))
    n = length(all_names)

    edges = [Int[] for _ in 1:n]
    in_deg = zeros(Int, n)
    for conn in connections
        from = mapping[conn[1]]
        for to_str in conn[2:end]
            to = mapping[to_str]
            push!(edges[from], to)
            in_deg[to] += 1
        end
    end

    # Topological sort
    q = Deque{Int}()
    foreach(i -> push!(q, i), findall(==(0), in_deg))

    topo = Int[]
    sizehint!(topo, n)
    while !isempty(q)
        u = popfirst!(q)
        push!(topo, u)
        for v in edges[u]
            in_deg[v] -= 1
            in_deg[v] == 0 && push!(q, v)
        end
    end

    length(topo) == n ||
        error("Graph contains a cycle: $(n - length(topo)) nodes unreachable")

    Graph(n, edges, mapping, topo)
end

function count_paths(g::Graph, start::Int, finish::Int)
    ways = zeros(Int, g.n)
    ways[start] = 1
    for u in g.topo
        for v in g.edges[u]
            ways[v] += ways[u]
        end
    end
    ways[finish]
end

function count_paths(g::Graph, start::String, finish::String)
    count_paths(g, g.mapping[start], g.mapping[finish])
end

function part_one(input)
    g = build_graph(input)
    count_paths(g, "you", "out")
end

function part_two(input)
    g = build_graph(input)

    dac_fft = count_paths(g, "dac", "fft")
    if dac_fft == 0
        # Path: svr → fft → dac → out
        count_paths(g, "svr", "fft") * count_paths(g, "fft", "dac") *
        count_paths(g, "dac", "out")
    else
        # Path: svr → dac → fft → out
        count_paths(g, "svr", "dac") * dac_fft * count_paths(g, "fft", "out")
    end
end

@testitem "Day11" begin
    using AdventOfCode: get_input, parse_input
    using AdventOfCode.AoC2025.Day11: part_one, part_two, YEAR, DAY

    input = get_input(YEAR, DAY)
    parsed = parse_input(input)

    sample = """aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out"""
    parsed_sample = parse_input(sample)

    sample2 = """svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out"""
    parsed_sample2 = parse_input(sample2)

    @testset "Part One" begin
        @test part_one(parsed_sample) == 5
        @test part_one(parsed) == 683
    end

    @testset "Part Two" begin
        @test part_two(parsed_sample2) == 2
        @test part_two(parsed) == 533996779677200
    end
end

end
