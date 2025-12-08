module Day08

using ...AdventOfCode
using ..AoC2025
using DataStructures: DisjointSets, find_root!, union!, counter

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

# Parse into matrix for cache-friendly access
function parse_boxes(input)
    lines = split(input, '\n')
    n = length(lines)
    boxes = Matrix{Int}(undef, n, 3)
    @inbounds for (i, line) in enumerate(lines)
        parts = split(line, ",")
        boxes[i, 1] = parse(Int, parts[1])
        boxes[i, 2] = parse(Int, parts[2])
        boxes[i, 3] = parse(Int, parts[3])
    end
    boxes
end

@inline function dist_sq(boxes, i, j)
    @inbounds (boxes[i, 1] - boxes[j, 1])^2 +
              (boxes[i, 2] - boxes[j, 2])^2 +
              (boxes[i, 3] - boxes[j, 3])^2
end

# Part One: partialsort — O(n²) avg, only sort first `connections` edges
function part_one(input; connections = 1000)
    boxes = parse_boxes(input)
    n = size(boxes, 1)

    edges = [(dist_sq(boxes, i, j), i, j) for i in 1:n for j in i+1:n]
    partialsort!(edges, 1:connections)

    ds = DisjointSets{Int}(1:n)
    for (_, i, j) in @view edges[1:connections]
        union!(ds, i, j)
    end

    grp_sizes = values(counter([find_root!(ds, i) for i in 1:n]))
    prod(partialsort(collect(grp_sizes), 1:3; rev = true))
end

# Part Two: Prim's MST — O(n²), with post-processing for correctness
# When multiple MST edges share max weight, select the one Kruskal would pick last
function part_two(input)
    boxes = parse_boxes(input)
    n = size(boxes, 1)

    dist = fill(typemax(Int), n)
    parent = zeros(Int, n)
    in_mst = falses(n)

    dist[1] = 0

    # Collect all MST edges
    mst_edges = Vector{Tuple{Int,Int,Int}}()
    sizehint!(mst_edges, n - 1)

    @inbounds for _ in 1:n
        # Find closest non-MST node
        u, min_d = 0, typemax(Int)
        for v in 1:n
            if !in_mst[v] && dist[v] < min_d
                min_d = dist[v]
                u = v
            end
        end

        in_mst[u] = true

        # Record MST edge
        if parent[u] != 0
            push!(mst_edges, (dist[u], parent[u], u))
        end

        # Update distances to neighbors
        for v in 1:n
            if !in_mst[v]
                d = dist_sq(boxes, u, v)
                if d < dist[v]
                    dist[v] = d
                    parent[v] = u
                end
            end
        end
    end

    # Sort MST edges by Kruskal's order: (dist, min_idx, max_idx)
    # The last edge in this order = Kruskal's final connecting edge
    sort!(mst_edges, by = e -> (e[1], min(e[2], e[3]), max(e[2], e[3])))
    _, i, j = mst_edges[end]

    boxes[i, 1] * boxes[j, 1]
end

@testitem "Day08" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2025.Day08: part_one, part_two, YEAR, DAY
    input = get_input(YEAR, DAY)

    sample = """162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689"""

    @testset "Part One" begin
        @test part_one(sample; connections = 10) == 40
        @test part_one(input) == 117000
    end

    @testset "Part Two" begin
        @test part_two(sample) == 25272
        @test part_two(input) == 8368033065
    end
end

end
