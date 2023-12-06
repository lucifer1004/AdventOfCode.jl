module Day04

using ...AdventOfCode

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function solve(input)
    numbers = split(input, ": ")[2]
    left, right = split(numbers, " | ")
    lnum = parse.(Int, split(left))
    rnum = parse.(Int, split(right))
    lst = Set(lnum)
    rst = Set(rnum)
    intersect = lst ∩ rst
    length(intersect)
end

part_one(input) = sum(map(x -> 1 << (x - 1), solve.(parse_input(input))))

function part_two(input)
    input = parse_input(input)
    n = length(input)
    copies = fill(1, n)
    for (i, line) in enumerate(input)
        intersect = solve(line)
        for j in (i + 1):min(n, i + intersect)
            copies[j] += copies[i]
        end
    end
    sum(copies)
end

@testitem "Day04" begin
    using AdventOfCode.AoC2023.Day04: part_one, part_two

    sample = """Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"""

    @testset "Part One" begin
        @test part_one(sample) == 13
    end

    @testset "Part Two" begin
        @test part_two(sample) == 30
    end
end

end
