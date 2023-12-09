module Day09

using ...AdventOfCode

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function solve(input, offset; frombegin = false)
    map(parse_input(input)) do line
        nums = parse.(Float64, split(line))
        n = length(nums)
        itp = LagrangeInterpolation(Float64.(nums), 1.0:1.0:n, n - 1; extrapolate = true)
        round(Int, frombegin ? itp(1 + offset) : itp(n + offset))
    end |> sum
end

part_one(input) = solve(input, 1)
part_two(input) = solve(input, -1; frombegin = true)

@testitem "Day09" begin
    using AdventOfCode.AoC2023.Day09: part_one, part_two

    sample = """0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"""

    @testset "Part One" begin
        @test part_one(sample) == 114
    end

    @testset "Part Two" begin
        @test part_two(sample) == 2
    end
end

end
