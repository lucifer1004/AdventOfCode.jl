module Day08

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function get_info(input)
    lines = split(input, '\n')
    n = length(lines)
    m = length(lines[1])
    grid = [lines[i][j] for i in 1:n, j in 1:m]
    visible = Dict{Char, Vector{Tuple{Int, Int}}}()
    for i in 1:n
        for j in 1:m
            c = grid[i, j]
            if c != '.'
                push!(get!(visible, c, []), (i, j))
            end
        end
    end
    return n, m, visible
end

function part_one(input)
    n, m, visible = get_info(input)
    st = Set{Tuple{Int, Int}}()
    check!(x, y) =
        if x >= 1 && y >= 1 && x <= n && y <= m
            push!(st, (x, y))
        end
    for v in values(visible)
        k = length(v)
        for i in 1:k
            xi, yi = v[i]
            for j in (i + 1):k
                xj, yj = v[j]
                x1, y1 = 2xj - xi, 2yj - yi
                x2, y2 = 2xi - xj, 2yi - yj
                check!(x1, y1)
                check!(x2, y2)
            end
        end
    end
    return length(st)
end

function part_two(input)
    n, m, visible = get_info(input)
    st = Set{Tuple{Int, Int}}()
    for v in values(visible)
        k = length(v)
        for i in 1:k
            xi, yi = v[i]
            for j in (i + 1):k
                xj, yj = v[j]
                dx, dy = xj - xi, yj - yi
                g = gcd(dx, dy)
                dx, dy = dx // g, dy // g
                for t in (-max(n, m)):max(n, m)
                    x, y = xi + t * dx, yi + t * dy
                    if x >= 1 && y >= 1 && x <= n && y <= m
                        push!(st, (x, y))
                    end
                end
            end
        end
    end
    return length(st)
end

@testitem "Day08" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day08: part_one, part_two, YEAR, DAY

    sample = """............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............"""
    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample) == 14
        @test part_one(input) == 367
    end

    @testset "Part Two" begin
        @test part_two(sample) == 34
        @test part_two(input) == 1285
    end
end

end
