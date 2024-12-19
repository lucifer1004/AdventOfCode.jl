module Day19

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function solve(input)
    lines = split(input, "\n")
    patterns = Set{String}(split(lines[1], ", "))
    solvable = 0
    ways = 0
    for line in lines[3:end]
        m = length(line)
        dp = fill(0, m + 1)
        can = fill(false, m + 1)
        dp[1] = 1
        can[1] = true
        for i in 1:m
            if can[i]
                for pattern in patterns
                    if i + length(pattern) <= m + 1 && line[i:i + length(pattern) - 1] == pattern
                        can[i + length(pattern)] = true
                        dp[i + length(pattern)] += dp[i]
                    end
                end
            end
        end
        solvable += can[end]
        ways += dp[end]
    end
    return solvable, ways
end

part_one(input) = solve(input)[1]
part_two(input) = solve(input)[2]

@testitem "Day19" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day19: part_one, part_two, YEAR, DAY

    sample = """r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb"""

    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample) == 6
        @test part_one(input) == 233
    end

    @testset "Part Two" begin
        @test part_two(sample) == 16
        @test part_two(input) == 691316989225259
    end
end

end
