module Day03

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

mul_pattern = r"mul\(([0-9]{1,3}),([0-9]{1,3})\)"

function part_one(input)
    return sum(sum(parse(Int, m[1]) * parse(Int, m[2])
               for m in eachmatch(mul_pattern, line))
               for line in parse_input(input))
end

function part_two(input)
    ans = 0
    for part in split(input, "do()")
        for m in eachmatch(mul_pattern, split(part, "don't()")[1])
            ans += parse(Int, m[1]) * parse(Int, m[2])
        end
    end
    return ans
end

@testitem "Day03" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day03: part_one, part_two, YEAR, DAY

    sample = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample) == 161
        @test part_one(input) == 174960292
    end

    sample2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

    @testset "Part Two" begin
        @test part_two(sample2) == 48
        @test part_two(input) == 56275602
    end
end

end
