module Day08

using ...AdventOfCode

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

struct Game
    instructions::String
    map::Dict{String, Tuple{String, String}}
end

function Game(input)
    input = parse_input(input)
    instructions = input[1]
    map = Dict{String, Tuple{String, String}}()
    for line in input[3:end]
        from, to = split(line, " = ")
        left, right = split(to[2:(end - 1)], ", ")
        map[from] = (left, right)
    end

    Game(instructions, map)
end

function go(game, from, to)
    n = length(game.instructions)
    step = 0
    now = from
    while !endswith(now, to)
        step += 1
        instruction = game.instructions[mod1(step, n)]
        left, right = game.map[now]
        if instruction == 'L'
            now = left
        else
            now = right
        end
    end

    step
end

part_one(input) = go(Game(input), "AAA", "ZZZ")

function part_two(input)
    game = Game(input)
    starts = filter(x -> endswith(x, "A"), keys(game.map))
    lcm(go.(Ref(game), starts, Ref("Z"))...)
end

@testitem "Day08" begin
    using AdventOfCode.AoC2023.Day08: part_one, part_two

    sample = """RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)"""

    @testset "Part One" begin
        @test part_one(sample) == 2
    end

    sample2 = """LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)"""

    @testset "Part Two" begin
        @test part_two(sample2) == 6
    end
end

end
