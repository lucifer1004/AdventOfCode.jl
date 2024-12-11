module Day11

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function solve(input; rep)
    stones = parse.(Int, split(input))
    cnt = DefaultDict{Int, Int}(0)
    for stone in stones
        cnt[stone] += 1
    end
    
    for _ in 1:rep
        new_stones = DefaultDict{Int, Int}(0)
        for stone in keys(cnt)
            if stone == 0
                new_stones[1] += cnt[stone]
            else
                m = length(string(stone))
                if m % 2 == 0
                    new_stones[stone ÷ 10^(m ÷ 2)] += cnt[stone]
                    new_stones[stone % 10^(m ÷ 2)] += cnt[stone]
                else
                    new_stones[2024stone] += cnt[stone]
                end
            end
        end
        cnt = new_stones
    end
    return sum(values(cnt))
end

part_one(input) = solve(input; rep=25)
part_two(input) = solve(input; rep=75)

@testitem "Day11" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day11: part_one, part_two, YEAR, DAY

    sample = """125 17"""
    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample) == 55312
        @test part_one(input) == 188902
    end

    @testset "Part Two" begin
        @test part_two(sample) == 65601038650482
        @test part_two(input) == 223894720281135
    end
end

end
