module Day23

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function build_graph(input)
    edges = split(input, '\n')
    G = [Int[] for _ in 1:(length(edges) * 2)]
    idx = 1
    mapping = Dict{String, Int}()
    inv_mapping = String[]
    for edge in edges
        a, b = split(edge, "-")
        if a ∉ keys(mapping)
            mapping[a] = idx
            push!(inv_mapping, a)
            idx += 1
        end
        if b ∉ keys(mapping)
            mapping[b] = idx
            push!(inv_mapping, b)
            idx += 1
        end

        a_idx, b_idx = mapping[a], mapping[b]
        if a_idx > b_idx
            a_idx, b_idx = b_idx, a_idx
        end
        push!(G[a_idx], b_idx)
    end

    num_nodes = idx - 1
    return G[1:num_nodes], inv_mapping
end

function part_one(input)
    G, inv_mapping = build_graph(input)
    num_nodes = length(G)
    ans = 0
    for a in 1:num_nodes
        for b in G[a]
            for c in intersect(G[a], G[b])
                if startswith(inv_mapping[a], "t") || startswith(inv_mapping[b], "t") ||
                   startswith(inv_mapping[c], "t")
                    ans += 1
                end
            end
        end
    end
    return ans
end

function part_two(input)
    G, inv_mapping = build_graph(input)
    num_nodes = length(G)
    Gmat = zeros(Bool, num_nodes, num_nodes)
    for i in 1:num_nodes
        sort!(G[i])
        for j in G[i]
            Gmat[i, j] = true
            Gmat[j, i] = true
        end
    end

    best_length = 0
    best_component = nothing
    function dfs(a, st)
        if length(st) > best_length
            best_length = length(st)
            best_component = collect(st)
        end
        start_point = searchsortedfirst(G[a], st[end] + 1)
        for e in G[a][start_point:end]
            if all(Gmat[x, e] for x in st)
                push!(st, e)
                dfs(a, st)
                pop!(st)
            end
        end
    end

    for a in sort(1:num_nodes, by = a -> length(G[a]), rev = true)
        if length(G[a]) + 1 < best_length
            continue
        end
        dfs(a, [a])
    end
    return join(sort(inv_mapping[best_component]), ",")
end

@testitem "Day23" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day23: part_one, part_two, YEAR, DAY
    input = get_input(YEAR, DAY)

    sample = """kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn"""

    @testset "Part One" begin
        @test part_one(sample) == 7
        @test part_one(input) == 1000
    end

    @testset "Part Two" begin
        @test part_two(sample) == "co,de,ka,ta"
        @test part_two(input) == "cf,ct,cv,cz,fi,lq,my,pa,sl,tt,vw,wz,yd"
    end
end

end
