module Day20

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function solve(input; max_cheating_time = 2, threshold = 100)
    lines = split(input, "\n")
    n = length(lines)
    m = length(lines[1])
    grid = [lines[i][j] for i in 1:n, j in 1:m]
    start = findfirst(==('S'), grid)
    goal = findfirst(==('E'), grid)
    sx, sy = Tuple(start)
    ex, ey = Tuple(goal)

    function get_dist(x, y)
        dist = fill(typemax(Int), n, m)
        dist[x, y] = 0
        queue = [(x, y, 0)]
        while !isempty(queue)
            x, y, d = popfirst!(queue)
            for (dx, dy) in [(0, 1), (0, -1), (1, 0), (-1, 0)]
                nx, ny = x + dx, y + dy
                if 1 <= nx <= n && 1 <= ny <= m
                    if dist[nx, ny] > d + 1 && grid[nx, ny] != '#'
                        dist[nx, ny] = d + 1
                        push!(queue, (nx, ny, d + 1))
                    end
                end
            end
        end
        return dist
    end

    sdist = get_dist(sx, sy)
    edist = get_dist(ex, ey)
    d = sdist[ex, ey]
    saves = zeros(Int, d)
    mct = max_cheating_time
    for i in 1:n, j in 1:m
        if sdist[i, j] != typemax(Int)
            for dx in (-mct):mct
                for dy in (abs(dx) - mct):(mct - abs(dx))
                    nx, ny = i + dx, j + dy
                    if 1 <= nx <= n && 1 <= ny <= m && edist[nx, ny] != typemax(Int)
                        now = sdist[i, j] + edist[nx, ny] + abs(dx) + abs(dy)
                        if now < d
                            saves[d - now] += 1
                        end
                    end
                end
            end
        end
    end

    return sum(saves[threshold:end])
end

part_one(input) = solve(input)
part_two(input) = solve(input; max_cheating_time = 20)

@testitem "Day20" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day20: part_one, part_two, YEAR, DAY
    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(input) == 1343
    end

    @testset "Part Two" begin
        @test part_two(input) == 982891
    end
end

end
