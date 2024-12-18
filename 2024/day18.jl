module Day18

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function get_info(input)
    lines = split(input, '\n')
    positions = Tuple{Int, Int}[]
    for line in lines
        push!(positions, Tuple(parse(Int, x) + 1 for x in split(line, ",")))
    end
    return positions
end

function shortest_path(h::Int, w::Int, positions::AbstractVector{Tuple{Int, Int}}, t::Int, start::Tuple{Int, Int}, target::Tuple{Int, Int})
    grid = fill(true, h, w)
    for i in 1:t
        grid[positions[i][1], positions[i][2]] = false
    end
    q = Queue{Tuple{Int, Int}}()
    dist = fill(typemax(Int), h, w)
    enqueue!(q, start)
    dist[start[1], start[2]] = 0

    while !isempty(q)
        x, y = dequeue!(q)
        for (dx, dy) in [(0, 1), (1, 0), (0, -1), (-1, 0)]
            nx, ny = x + dx, y + dy
            if 1 <= nx <= h && 1 <= ny <= w && grid[nx, ny] && dist[nx, ny] > dist[x, y] + 1
                dist[nx, ny] = dist[x, y] + 1
                enqueue!(q, (nx, ny))
            end
        end
    end
    return dist[target[1], target[2]]
end

function part_one(input; H = 71, W = 71, N = 1024)
    positions = get_info(input)
    return shortest_path(H, W, positions, N, (1, 1), (H, W))
end

function part_two(input; H = 71, W = 71)
    positions = get_info(input)
    n = length(positions)
    l = 1
    r = n
    while l <= r
        mid = (l + r) ÷ 2
        dist = shortest_path(H, W, positions, mid, (1, 1), (H, W))
        if dist == typemax(Int)
            r = mid - 1
        else
            l = mid + 1
        end
    end
    return join(positions[l] .- 1, ",")
end

@testitem "Day18" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day18: part_one, part_two, YEAR, DAY

    sample = """5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0"""

    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample; H = 7, W = 7, N = 12) == 22
        @test part_one(input) == 370
    end

    @testset "Part Two" begin
        @test part_two(sample; H = 7, W = 7) == "6,1"
        @test part_two(input) == "65,6"
    end
end

end
