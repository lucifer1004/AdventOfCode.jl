module Day06

using ...AdventOfCode

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function solve(t, d)
    hi = iseven(t) ? t^2 ÷ 4 : (t^2 - 1) ÷ 4
    if hi <= d
        return 0
    end
    left = searchsortedfirst(x -> x * (t - x) > d, 1:(t ÷ 2))
    right = searchsortedlast(x -> x * (t - x) > d, (t ÷ 2 + 1):t)
    @assert !isnothing(left) && !isnothing(right)
    return right - left + 1
end

function part_one(input)
    input = parse_input(input)
    time = parse.(Int, split(split(input[1], ": ")[2]))
    dist = parse.(Int, split(split(input[2], ": ")[2]))
    prod(solve.(time, dist))
end

function part_two(input)
    input = parse_input(input)
    t = parse(Int, join(split(split(input[1], ": ")[2])))
    d = parse(Int, join(split(split(input[2], ": ")[2])))
    solve(t, d)
end

@testitem "Day06" begin
    using AdventOfCode.AoC2023.Day06: part_one, part_two

    sample = """Time:      7  15   30
Distance:  9  40  200"""

    @testset "Part One" begin
        @test part_one(sample) == 288
    end

    @testset "Part Two" begin
        @test part_two(sample) == 71503
    end
end

end
