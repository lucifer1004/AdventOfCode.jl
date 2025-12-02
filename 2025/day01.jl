module Day01

using ...AdventOfCode
using ..AoC2025

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])
const START_POS = 50
const CYCLE_LEN = 100

function parse_commands(input)
    lines = split(input, '\n')
    directions = map(x -> x[1], lines)
    numbers = map(x -> parse(Int, x[2:end]), lines)
    return directions, numbers
end

function part_one(input; start = START_POS, cycle = CYCLE_LEN)
    directions, numbers = parse_commands(input)
    cnt = 0
    now = start
    for (dir, number) in zip(directions, numbers)
        if dir == 'L'
            now = mod(now - number, cycle)
        else
            now = mod(now + number, cycle)
        end
        if now == 0
            cnt += 1
        end
    end

    cnt
end

function part_two(input; start = START_POS, cycle = CYCLE_LEN)
    directions, numbers = parse_commands(input)
    cnt = 0
    now = start
    for (dir, number) in zip(directions, numbers)
        if dir == 'L'
            if number >= now
                cnt += (now != 0) + (number - now) ÷ cycle
            end
            now = mod(now - number, cycle)
        else
            if number >= cycle - now
                cnt += 1 + (number - cycle + now) ÷ cycle
            end
            now = mod(now + number, cycle)
        end
    end

    cnt
end

@testitem "Day01" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2025.Day01: part_one, part_two, YEAR, DAY
    input = get_input(YEAR, DAY)

    sample = """L68
L30
R48
L5
R60
L55
L1
L99
R14
L82"""

    @testset "Part One" begin
        @test part_one(sample) == 3
        @test part_one(input) == 989
    end

    @testset "Part Two" begin
        @test part_two(sample) == 6
        @test part_two(input) == 5941
    end
end

end
