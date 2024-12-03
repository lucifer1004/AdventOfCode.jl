module Day01

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function parse_columns(input)
    numbers = [map(x -> parse(Int, x), split(line, r"\s+")) for line in parse_input(input)]
    left = [x[1] for x in numbers]
    right = [x[2] for x in numbers]
    return left, right
end

function part_one(input)
    left, right = parse_columns(input)
    sort!(left)
    sort!(right)
    return sum(abs.(left .- right))
end

function part_two(input)
    left, right = parse_columns(input)
    left_count = counter(left)
    right_count = counter(right)
    return sum(i * left_count[i] * right_count[i] for i in keys(left_count))
end

@testitem "Day01" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day01: part_one, part_two, YEAR, DAY

    sample = """3   4
4   3
2   5
1   3
3   9
3   3"""
    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample) == 11
        @test part_one(input) == 1189304
    end

    @testset "Part Two" begin
        @test part_two(sample) == 31
        @test part_two(input) == 24349736
    end
end

end
