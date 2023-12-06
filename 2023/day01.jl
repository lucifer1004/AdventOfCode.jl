module Day01

using ...AdventOfCode
using ..AoC2023

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

const DICT_ONE = Dict([string(i) => i for i in 1:9]...)
const DICT_TWO = Dict("one" => 1,
    "two" => 2,
    "three" => 3,
    "four" => 4,
    "five" => 5,
    "six" => 6,
    "seven" => 7,
    "eight" => 8,
    "nine" => 9,
    DICT_ONE...)

function solve(input, dict)
    left = minimum(findfirst(key, input) for key in keys(dict) if occursin(key, input))
    right = maximum(findlast(key, input) for key in keys(dict) if occursin(key, input))
    return dict[input[left]] * 10 + dict[input[right]]
end

part_one(input) = solve.(parse_input(input), (DICT_ONE,)) |> sum
part_two(input) = solve.(parse_input(input), (DICT_TWO,)) |> sum

@testitem "Day01" begin
    using AdventOfCode.AoC2023.Day01: part_one, part_two

    sample = """1abc2
    pqr3stu8vwx
    a1b2c3d4e5f
    treb7uchet"""

    sample2 = """two1nine
    eightwothree
    abcone2threexyz
    xtwone3four
    4nineeightseven2
    zoneight234
    7pqrstsixteen"""

    @testset "Part One" begin
        @test part_one(sample) == 142
    end

    @testset "Part Two" begin
        @test part_two(sample2) == 281
    end
end

end
