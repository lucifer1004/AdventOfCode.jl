module Day02

using ...AdventOfCode
using ..AoC2025

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

# i||i = i * (10^d + 1) where d = ndigits(i)
concat_num(i) = i * (10^ndigits(i) + 1)

# Precompute cumulative sums: ACC[i] = sum(concat_num(j) for j in 1:i-1)
const ACC = let
    acc = Int[0]
    for i in 1:100000
        push!(acc, acc[end] + concat_num(i))
    end
    acc
end

# Binary search: find smallest i where concat_num(i) >= target
function bsearch(target)
    lo, hi = 1, 10^9
    while lo <= hi
        mid = (lo + hi) >> 1
        concat_num(mid) >= target ? (hi = mid - 1) : (lo = mid + 1)
    end
    lo
end

function part_one(input)
    ans = 0
    for line in split(input, '\n'), range in split(line, ",")
        isempty(range) && continue
        l, r = parse.(Int, split(range, "-"))
        ans += ACC[bsearch(r + 1)] - ACC[bsearch(l)]
    end
    ans
end

# Precompute all repeating-pattern numbers up to 10^10
# A number is "repeating" if it equals some pattern repeated k times (k >= 2)
# e.g., 1212 = "12" * 2, 111 = "1" * 3
const REPEATING_NUMS, REPEATING_SUM = let
    nums = Int[]
    for t in 2:10  # digit count
        for j in 1:t÷2  # period length
            t % j == 0 || continue
            mult = (10^t - 1) ÷ (10^j - 1)  # 10101... pattern
            lo = j == 1 ? 1 : 10^(j - 1)
            for pattern in lo:(10^j - 1)
                push!(nums, pattern * mult)
            end
        end
    end
    sort!(unique!(nums))
    nums, cumsum(nums)
end

function sum_repeating(l, r)
    lo = searchsortedfirst(REPEATING_NUMS, l)
    hi = searchsortedlast(REPEATING_NUMS, r)
    lo > hi ? 0 : REPEATING_SUM[hi] - get(REPEATING_SUM, lo - 1, 0)
end

function part_two(input)
    ans = 0
    for line in split(input, '\n'), range in split(line, ",")
        isempty(range) && continue
        l, r = parse.(Int, split(range, "-"))
        ans += sum_repeating(l, r)
    end
    ans
end

@testitem "Day02" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2025.Day02: part_one, part_two, YEAR, DAY
    input = get_input(YEAR, DAY)

    sample = """11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
1698522-1698528,446443-446449,38593856-38593862,565653-565659,
824824821-824824827,2121212118-2121212124"""

    @testset "Part One" begin
        @test part_one(input) == 16793817782
    end

    @testset "Part Two" begin
        @test part_two(input) == 27469417404
    end
end

end

