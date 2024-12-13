module Day13

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function parse_button(button)
    rgx = r"Button (\w+): X\+(\d+), Y\+(\d+)"
    m = match(rgx, button)
    return parse(Int, m[2]), parse(Int, m[3])
end

function parse_prize(prize)
    rgx = r"Prize: X\=(\d+), Y\=(\d+)"
    m = match(rgx, prize)
    return parse(Int, m[1]), parse(Int, m[2])
end

struct Problem
    ax::Int
    ay::Int
    bx::Int
    by::Int
    px::Int
    py::Int
end

function get_problems(input; offset=0)
    lines = split(input, "\n")
    n = length(lines)
    problems = Problem[]
    for i in 1:4:n
        ax, ay = parse_button(lines[i])
        bx, by = parse_button(lines[i + 1])
        px, py = parse_prize(lines[i + 2])
        push!(problems, Problem(ax, ay, bx, by, px+offset, py+offset))
    end
    return problems
end

function solve(problem::Problem)
    ax, ay, bx, by, px, py = problem.ax, problem.ay, problem.bx, problem.by, problem.px, problem.py
    cost = typemax(Int)
    if ax * by == ay * bx # collinear
        if ax * py == ay * px && px >= ax
            cost = min(cost, 3 * px ÷ ax)
        end
        if bx * py == by * px && px >= bx
            cost = min(cost, px ÷ bx)
        end
    else
        if (ax * py - ay * px) % (ax * by - ay * bx) == 0 
            b = (ax * py - ay * px) ÷ (ax * by - ay * bx)
            if (ay * px - ay * bx * b) % (ax * ay) == 0
                a = (ay * px - ay * bx * b) ÷ (ax * ay)
                if a >= 0 && b >= 0
                    cost = min(cost, 3a + b)
                end
            end
        end
    end
    return cost == typemax(Int) ? 0 : cost
end

part_one(input) = sum(solve.(get_problems(input)))
part_two(input) = sum(solve.(get_problems(input, offset=10000000000000)))

@testitem "Day13" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day13: part_one, part_two, YEAR, DAY

    sample = """Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279"""
    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample) == 480
        @test part_one(input) == 29201
    end

    @testset "Part Two" begin
        @test part_two(sample) == 875318608908
        @test part_two(input) == 104140871044942
    end
end

end
