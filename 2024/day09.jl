module Day09

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function get_info(input)
    curr = Int[]
    slots = Tuple{Int, Int}[]
    targets = Tuple{Int, Int, Int}[]
    cd = 0
    for (i, c) in enumerate(input)
        if i % 2 == 1
            d = cd
            cd += 1
        else
            d = -1
        end
        c = parse(Int, c)
        for _ in 1:c
            push!(curr, d)
        end
        if d == -1
            push!(slots, (length(curr) - c + 1, length(curr)))
        else
            push!(targets, (length(curr) - c + 1, length(curr), d))
        end
    end
    return curr, slots, targets
end

checksum(arr) = sum(num * (i - 1) for (i, num) in enumerate(arr) if num != -1)

function part_one(input)
    curr, _, _ = get_info(input)
    left = 1
    for right in lastindex(curr):-1:1
        if left > right
            break
        end
        if curr[right] != -1
            while left < right && curr[left] != -1
                left += 1
            end
            if left < right
                curr[left] = curr[right]
                curr[right] = -1
            end
        end
    end

    checksum(curr)
end

function part_two(input)
    curr, slots, targets = get_info(input)
    for (left, right, d) in targets[end:-1:1]
        for i in eachindex(slots)
            sleft, sright = slots[i]
            if sright < left && sright - sleft + 1 >= right - left + 1
                for j in sleft:(sleft + right - left)
                    curr[j] = d
                end
                for j in left:right
                    curr[j] = -1
                end
                slots[i] = (sleft + right - left + 1, sright)
                if sleft + right - left + 1 > sright
                    popat!(slots, i)
                end
                break
            end
        end
    end

    checksum(curr)
end

@testitem "Day09" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day09: part_one, part_two, YEAR, DAY

    sample = """2333133121414131402"""
    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample) == 1928
        @test part_one(input) == 6398252054886
    end

    @testset "Part Two" begin
        @test part_two(sample) == 2858
        @test part_two(input) == 6415666220005
    end
end

end
