module Day02

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function check(nums; tolerance = 0, lower_bound = 1, upper_bound = 3)
    inc = [Set() for _ in 0:tolerance]
    dec = [Set() for _ in 0:tolerance]
    push!(inc[1], nums[1])
    push!(dec[1], nums[1])
    for i in 2:lastindex(nums)
        for j in tolerance:-1:0
            ninc = Set()
            if any(lower_bound <= nums[i] - x <= upper_bound for x in inc[j + 1])
                push!(ninc, nums[i])
            end
            ndec = Set()
            if any(lower_bound <= x - nums[i] <= upper_bound for x in dec[j + 1])
                push!(ndec, nums[i])
            end
            if j + 1 <= tolerance
                inc[j + 2] = union(inc[j + 2], inc[j + 1])
                dec[j + 2] = union(dec[j + 2], dec[j + 1])
            end
            inc[j + 1] = ninc
            dec[j + 1] = ndec
        end

        if i - 1 <= tolerance
            push!(inc[i], nums[i])
            push!(dec[i], nums[i])
        end
    end

    return any(length(inc[i]) > 0 || length(dec[i]) > 0 for i in 1:(tolerance + 1))
end

function part_one(input)
    return sum(check(map(x -> parse(Int, x), split(line))) for line in parse_input(input))
end

function part_two(input)
    return sum(check(map(x -> parse(Int, x), split(line)), tolerance = 1)
    for line in parse_input(input))
end

@testitem "Day02" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day02: part_one, part_two, YEAR, DAY

    sample = """7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"""
    input = get_input(YEAR, DAY)
    @testset "Part One" begin
        @test part_one(sample) == 2
        @test part_one(input) == 432
    end

    @testset "Part Two" begin
        @test part_two(sample) == 4
        @test part_two(input) == 488
    end
end

end
