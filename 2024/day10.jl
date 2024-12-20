module Day10

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function solve(input)
    lines = split(input, "\n")
    n = length(lines)
    m = length(lines[1])
    grid = [parse(Int, string(c)) for line in lines for c in line]
    grid = reshape(grid, n, m)

    unique_endings = [Set{Tuple{Int, Int}}() for _ in 1:n, _ in 1:m]
    number_routes = zeros(Int, n, m)

    digits = [Tuple{Int, Int}[] for _ in 0:9]
    for i in 1:n
        for j in 1:m
            if grid[i, j] == 9
                push!(unique_endings[i, j], (i, j))
                number_routes[i, j] = 1
            end
            push!(digits[grid[i, j] + 1], (i, j))
        end
    end

    total_ending_points = 0
    total_route_points = 0
    for num in 8:-1:0
        for (i, j) in digits[num + 1]
            for (di, dj) in [(0, 1), (1, 0), (0, -1), (-1, 0)]
                if 1 <= i + di <= n && 1 <= j + dj <= m && grid[i + di, j + dj] == num + 1
                    unique_endings[i, j] = union(
                        unique_endings[i, j], unique_endings[i + di, j + dj])
                    number_routes[i, j] += number_routes[i + di, j + dj]
                end
            end

            if num == 0
                total_ending_points += length(unique_endings[i, j])
                total_route_points += number_routes[i, j]
            end
        end
    end

    return total_ending_points, total_route_points
end

part_one(input) = solve(input)[1]
part_two(input) = solve(input)[2]

@testitem "Day10" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day10: part_one, part_two, YEAR, DAY

    sample = """89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732"""
    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample) == 36
        @test part_one(input) == 617
    end

    @testset "Part Two" begin
        @test part_two(sample) == 81
        @test part_two(input) == 1477
    end
end

end
