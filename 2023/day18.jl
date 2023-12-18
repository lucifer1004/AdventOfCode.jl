module Day18

using ...AdventOfCode

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function polygon_area(x, y)
    area = 0
    j = lastindex(x)
    for i in eachindex(x)
        area += (x[j] + x[i]) * (y[j] - y[i])
        j = i
    end
    abs(area) ÷ 2
end

function polygon_circumference(x, y)
    tot = 0
    j = lastindex(x)
    for i in eachindex(x)
        tot += abs(x[j] - x[i]) + abs(y[j] - y[i])
        j = i
    end
    tot
end

function parse_line(line)
    dir1, dis1, code = split(line)
    dir1 = dir1[1]
    dis1 = parse(Int, dis1)

    dis2 = parse(Int, code[3:(end - 2)], base = 16)
    dir2 = "RDLU"[parse(Int, code[(end - 1):(end - 1)]) + 1]

    return (dir1, dis1), (dir2, dis2)
end

function solve(input, part)
    input = parse_input(input)
    x, y = 0, 0
    xs = [0]
    ys = [0]

    for line in input
        dir, dis = parse_line(line)[part]
        if dir == 'R'
            x += dis
        elseif dir == 'L'
            x -= dis
        elseif dir == 'U'
            y += dis
        elseif dir == 'D'
            y -= dis
        end
        push!(xs, x)
        push!(ys, y)
    end

    polygon_area(xs, ys) + polygon_circumference(xs, ys) ÷ 2 + 1
end

part_one(input) = solve(input, 1)
part_two(input) = solve(input, 2)

@testitem "Day18" begin
    using AdventOfCode.AoC2023.Day18: part_one, part_two

    sample = """R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)"""

    @testset "Part One" begin
        @test part_one(sample) == 62
    end

    @testset "Part Two" begin
        @test part_two(sample) == 952408144115
    end
end

end
