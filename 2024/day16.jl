module Day16

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])
const DIRS = [(-1, 0), (0, 1), (1, 0), (0, -1)]

function solve(input; move_cost = 1, turn_cost = 1000)
    lines = split(input, '\n')
    n = length(lines)
    m = length(lines[1])
    grid = [lines[i][j] for i in 1:n, j in 1:m]
    sx, sy = n - 1, 2
    ex, ey = 2, m - 1
    @assert grid[sx, sy] == 'S'
    @assert grid[ex, ey] == 'E'

    function next_states(x, y, dir)
        dx, dy = DIRS[dir]
        return [
            (x + dx, y + dy, dir, move_cost),
            (x, y, mod1(dir + 1, 4), turn_cost),
            (x, y, mod1(dir - 1, 4), turn_cost)
        ]
    end

    dist = fill(typemax(Int), n, m, 4)
    prev = [Tuple{Int, Int, Int}[] for _ in 1:n, _ in 1:m, _ in 1:4]
    dist[sx, sy, 2] = 0
    pq = PriorityQueue{Tuple{Int, Int, Int}, Int}()
    pq[(sx, sy, 2)] = 0
    while !isempty(pq)
        x, y, dir = dequeue!(pq)
        if x == ex && y == ey
            break
        else
            for (nx, ny, ndir, cost) in next_states(x, y, dir)
                if 1 <= nx <= n && 1 <= ny <= m && grid[nx, ny] != '#'
                    if dist[nx, ny, ndir] > dist[x, y, dir] + cost
                        dist[nx, ny, ndir] = dist[x, y, dir] + cost
                        pq[(nx, ny, ndir)] = dist[nx, ny, ndir]
                        prev[nx, ny, ndir] = [(x, y, dir)]
                    elseif dist[nx, ny, ndir] == dist[x, y, dir] + cost
                        push!(prev[nx, ny, ndir], (x, y, dir))
                    end
                end
            end
        end
    end

    min_dist = minimum(dist[ex, ey, :])
    queue = Queue{Tuple{Int, Int, Int}}()
    visited = Set{Tuple{Int, Int, Int}}()
    for dir in 1:4
        if dist[ex, ey, dir] == min_dist
            enqueue!(queue, (ex, ey, dir))
            push!(visited, (ex, ey, dir))
        end
    end

    while !isempty(queue)
        x, y, dir = dequeue!(queue)
        for (px, py, pdir) in prev[x, y, dir]
            if (px, py, pdir) ∉ visited
                enqueue!(queue, (px, py, pdir))
                push!(visited, (px, py, pdir))
            end
        end
    end

    visited_cells = Set{Tuple{Int, Int}}([(x, y) for (x, y, dir) in visited])
    return min_dist, length(visited_cells)
end

part_one(input) = solve(input)[1]
part_two(input) = solve(input)[2]

@testitem "Day16" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day16: part_one, part_two, YEAR, DAY

    sample = """###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############"""

    sample2 = """#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################"""

    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample) == 7036
        @test part_one(sample2) == 11048
        @test part_one(input) == 72428
    end

    @testset "Part Two" begin
        @test part_two(sample) == 45
        @test part_two(sample2) == 64
        @test part_two(input) == 456
    end
end

end
