module Day12

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function solve(input)
    lines = split(input, '\n')
    n = length(lines)
    m = length(lines[1])
    grid = [lines[i][j] for i in 1:n, j in 1:m]
    vis = fill(false, n, m)
    info = Tuple{Int, Int, Int}[]
    for i in 1:n
        for j in 1:m
            if vis[i, j]
                continue
            end
            vis[i, j] = true
            ch = grid[i, j]
            q = [(i, j)]
            area = 0
            bottoms = [Int[] for _ in 1:(n + 1)]
            tops = [Int[] for _ in 1:(n + 1)]
            rights = [Int[] for _ in 1:(m + 1)]
            lefts = [Int[] for _ in 1:(m + 1)]
            while !isempty(q)
                area += 1
                x, y = pop!(q)
                for (dx, dy) in [(0, 1), (0, -1), (1, 0), (-1, 0)]
                    nx, ny = x + dx, y + dy
                    if 1 <= nx <= n && 1 <= ny <= m && !vis[nx, ny] && grid[nx, ny] == ch
                        vis[nx, ny] = true
                        push!(q, (nx, ny))
                    elseif nx < 1 || nx > n || ny < 1 || ny > m || grid[nx, ny] != ch
                        if (dx, dy) == (0, 1)
                            push!(rights[min(y, ny) + 1], x)
                        elseif (dx, dy) == (0, -1)
                            push!(lefts[min(y, ny) + 1], x)
                        elseif (dx, dy) == (1, 0)
                            push!(bottoms[min(x, nx) + 1], y)
                        elseif (dx, dy) == (-1, 0)
                            push!(tops[min(x, nx) + 1], y)
                        end
                    end
                end
            end
            sides = 0
            border_length = 0
            for borders in [bottoms, tops, rights, lefts]
                for border_list in borders
                    sort!(border_list)
                    border_length += length(border_list)
                    lst = -100
                    for b in border_list
                        if b > lst + 1 && lst >= 1
                            sides += 1
                        end
                        lst = b
                    end
                    if lst >= 1
                        sides += 1
                    end
                end
            end
            push!(info, (area, border_length, sides))
        end
    end
    
    return info
end

function part_one(input)
    info = solve(input)
    return sum(area * border_length for (area, border_length, _) in info)
end

function part_two(input)
    info = solve(input)
    return sum(area * sides for (area, _, sides) in info)
end

@testitem "Day12" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day12: part_one, part_two, YEAR, DAY

    sample = """RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE"""
    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample) == 1930
        @test part_one(input) == 1471452
    end

    @testset "Part Two" begin
        @test part_two(sample) == 1206
        @test part_two(input) == 863366
    end
end

end
