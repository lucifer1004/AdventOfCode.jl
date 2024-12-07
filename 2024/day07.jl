module Day07

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

struct Problem
    target::Int
    components::Vector{Int}
end

function Problem(line)
    target, components = split(line, ": ")
    target = parse(Int, target)
    components = parse.(Int, split(components, " "))
    return Problem(target, components)
end

function solve(input; ops)
    problems = Problem.(split(input, '\n'))
    ans = Atomic{Int}(0)
    Threads.@threads for problem in problems
        n = length(problem.components)
        for i in 0:(ops^(n - 1) - 1)
            now = problem.components[1]
            temp = i
            for j in 1:(n - 1)
                op = temp % ops
                temp ÷= ops
                if op == 0
                    now += problem.components[j + 1]
                elseif op == 1
                    now *= problem.components[j + 1]
                else  # op == 2
                    now = now * 10^(floor(Int, log10(problem.components[j + 1])) + 1) +
                          problem.components[j + 1]
                end

                if now > problem.target
                    break
                end
            end
            if now == problem.target
                @atomic ans.x += problem.target
                break
            end
        end
    end
    return ans.x
end

part_one(input) = solve(input; ops=2)
part_two(input) = solve(input; ops=3)

@testitem "Day07" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day07: part_one, part_two, YEAR, DAY

    sample = """190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20"""
    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample) == 3749
        @test part_one(input) == 12553187650171
    end

    @testset "Part Two" begin
        @test part_two(sample) == 11387
        @test part_two(input) == 96779702119491
    end
end

end
