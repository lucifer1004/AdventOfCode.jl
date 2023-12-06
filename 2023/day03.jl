module Day03

using ...AdventOfCode
using ..AoC2023

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function solve(input)
    n = length(input)
    m = length(input[1])
    nums = []
    adj = []
    for i in 1:n
        l = 1
        while l <= m
            if !isnumeric(input[i][l])
                l += 1
            else
                r = l
                while r + 1 <= m && isnumeric(input[i][r + 1])
                    r += 1
                end
                num = parse(Int, input[i][l:r])
                adjrow = max(1, i - 1):min(n, i + 1)
                adjcol = max(1, l - 1):min(m, r + 1)
                found = false
                for j in adjrow
                    for k in adjcol
                        if input[j][k] != '.' && !isnumeric(input[j][k])
                            push!(nums, num)
                            push!(adj, (j, k, input[j][k]))
                            found = true
                            break
                        end
                    end
                    if found
                        break
                    end
                end
                l = r + 1
            end
        end
    end

    nums, adj
end

part_one(input) = sum(solve(parse_input(input))[1])

function part_two(input)
    nums, adj = solve(parse_input(input))
    cnt = Dict()
    for (i, j, c) in adj
        if c == '*'
            cnt[(i, j)] = get(cnt, (i, j), 0) + 1
        end
    end

    d = Dict()
    for (idx, (i, j, c)) in enumerate(adj)
        if c == '*' && get(cnt, (i, j), 0) == 2
            d[(i, j)] = get(d, (i, j), 1) * nums[idx]
        end
    end

    sum(values(d))
end

@testitem "Day03" begin
    using AdventOfCode.AoC2023.Day03: part_one, part_two

    sample = raw"""467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."""

    @testset "Part One" begin
        @test part_one(sample) == 4361
    end

    @testset "Part Two" begin
        @test part_two(sample) == 467835
    end
end

end
