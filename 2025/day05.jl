module Day05

using ...AdventOfCode
using ..AoC2025

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function parse_input(input)
    lines = split(input, '\n')
    sep = findfirst(==(""), lines)
    
    ranges = [Tuple(parse.(Int, split(line, "-"))) for line in lines[1:sep-1]]
    numbers = [parse(Int, line) for line in lines[sep+1:end]]
    
    ranges, numbers
end

# Sort and merge overlapping ranges → O(m log m)
function merge_ranges(ranges)
    isempty(ranges) && return Tuple{Int,Int}[]
    
    sorted = sort(ranges)
    merged = Tuple{Int,Int}[]
    left, right = sorted[1]
    
    for (l, r) in sorted[2:end]
        if l > right + 1
            push!(merged, (left, right))
            left, right = l, r
        else
            right = max(right, r)
        end
    end
    push!(merged, (left, right))
    merged
end

# Two-pointer: count numbers covered by merged ranges → O(n log n + m)
function count_covered(merged, numbers)
    isempty(merged) && return 0
    
    sorted_nums = sort(numbers)
    ans = 0
    j = 1  # pointer into merged ranges
    
    for num in sorted_nums
        # Advance range pointer until we find a range that could contain num
        while j <= length(merged) && merged[j][2] < num
            j += 1
        end
        # Check if current range contains num
        if j <= length(merged) && merged[j][1] <= num <= merged[j][2]
            ans += 1
        end
    end
    ans
end

function part_one(input)
    ranges, numbers = parse_input(input)
    merged = merge_ranges(ranges)
    count_covered(merged, numbers)
end

function part_two(input)
    ranges, _ = parse_input(input)
    merged = merge_ranges(ranges)
    sum(r - l + 1 for (l, r) in merged)
end

@testitem "Day05" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2025.Day05: part_one, part_two, YEAR, DAY
    input = get_input(YEAR, DAY)

    sample = """3-5
10-14
16-20
12-18

1
5
8
11
17
32"""

    @testset "Part One" begin
        @test part_one(sample) == 3
        @test part_one(input) == 888
    end

    @testset "Part Two" begin
        @test part_two(sample) == 14
        @test part_two(input) == 344378119285354
    end
end

end

