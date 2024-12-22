module Day22

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function series(secret::Int, n::Int)
    secrets = [secret]
    for _ in 1:n
        secret = ((secret * 64) ⊻ secret) % 16777216
        secret = ((secret ÷ 32) ⊻ secret) % 16777216
        secret = ((secret * 2048) ⊻ secret) % 16777216
        push!(secrets, secret)
    end
    return secrets
end

part_one(input) = sum(series(parse(Int, line), 2000)[end] for line in split(input, '\n'))

function part_two(input)
    nums = parse.(Int, split(input, '\n'))
    all_series::Vector{Vector{Int}} = [series(num, 2000) for num in nums]
    all_prices::Vector{Vector{Int}} = [s .% 10 for s in all_series]
    all_delta::Vector{Vector{Int}} = [[snd - fst + 9 for (fst, snd) in zip(s[2:end], s)]
                                      for s in all_prices]
    counter = zeros(Int, 19^4)
    for (s, delta) in zip(all_prices, all_delta)
        vis = Set{Int}()
        key = delta[1] * 19^3 + delta[2] * 19^2 + delta[3] * 19 + delta[4]
        for i in 1:(length(delta) - 3)
            if key ∉ vis
                counter[key] += s[i + 4]
                push!(vis, key)
            end
            key -= delta[i] * 19^3
            if i < length(delta) - 3
                key = key * 19 + delta[i + 4]
            end
        end
    end
    return maximum(counter)
end

@testitem "Day22" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day22: part_one, part_two, YEAR, DAY
    input = get_input(YEAR, DAY)

    sample = """1
10
100
2024"""

    @testset "Part One" begin
        @test part_one(sample) == 37327623
        @test part_one(input) == 15335183969
    end

    sample2 = """1
2
3
2024"""

    @testset "Part Two" begin
        @test part_two(sample2) == 23
        @test part_two(input) == 1696
    end
end

end
