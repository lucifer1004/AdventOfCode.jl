module Day03

using ...AdventOfCode
using ..AoC2025

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function solve(line; digits=2)
    hi = fill(-1, digits)
    for ch in line
        now = ch - '0'
        for i in digits:-1:2
            if hi[i-1] >= 0
                hi[i] = max(hi[i], hi[i-1] * 10 + now)
            end
        end
        hi[1] = max(hi[1], now)
    end
    hi[end]
end

function part_one(input)
    lines = split(input, '\n')
    sum(solve.(lines))
end

function part_two(input)
    lines = split(input, '\n')
    sum(solve.(lines; digits=12))
end

@testitem "Day03" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2025.Day03: part_one, part_two, YEAR, DAY
    input = get_input(YEAR, DAY)

    sample = """987654321111111
811111111111119
234234234234278
818181911112111"""

    @testset "Part One" begin
        @test part_one(input) == 16973
    end

    @testset "Part Two" begin
        @test part_two(input) == 168027167146027
    end
end

end

