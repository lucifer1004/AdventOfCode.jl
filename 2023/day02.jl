module Day02

using ...AdventOfCode
using ..AoC2023

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function solve(line)
    games = split(line, ": ")[2]
    sets = split(games, "; ")
    hi = Dict("blue" => 0,
        "green" => 0,
        "red" => 0)
    for set in sets
        cards = split(set, ", ")
        for card in cards
            num, color = split(card, " ")
            hi[color] = max(hi[color], parse(Int, num))
        end
    end
    return hi
end

function part_one(input)
    map(enumerate(parse_input(input))) do (i, line)
        hi = solve(line)
        hi["red"] <= 12 && hi["green"] <= 13 && hi["blue"] <= 14 ? i : 0
    end |> sum
end

function part_two(input)
    map(parse_input(input)) do line
        hi = solve(line)
        hi["red"] * hi["green"] * hi["blue"]
    end |> sum
end

@testitem "Day02" begin
    using AdventOfCode.AoC2023.Day02: part_one, part_two

    sample = """Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"""

    @testset "Part One" begin
        @test part_one(sample) == 8
    end

    @testset "Part Two" begin
        @test part_two(sample) == 2286
    end
end

end
