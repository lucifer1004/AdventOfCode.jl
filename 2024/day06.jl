module Day06

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])
const DIRS = Tuple{Int, Int}[
    (-1, 0),
    (0, 1),
    (1, 0),
    (0, -1)
]

function get_info(input)
    lines = parse_input(input)
    n = length(lines)
    m = length(lines[1])
    grid = [lines[i][j] for i in 1:n, j in 1:m]
    st = findfirst(==('^'), grid)
    sx = st[1]
    sy = st[2]
    grid[sx, sy] = '.'
    return n, m, grid, sx, sy
end

function get_vis(n, m, grid, sx, sy)
    dir = 1
    x, y = sx, sy
    vis = Set{Tuple{Int, Int}}()
    while true
        dx, dy = DIRS[dir]
        push!(vis, (x, y))
        if x + dx < 1 || x + dx > n || y + dy < 1 || y + dy > m
            break
        end
        if grid[x + dx, y + dy] == '.'
            x += dx
            y += dy
        else
            dir = mod1(dir + 1, 4)
        end
    end
    return vis
end

function get_shortcuts(n, m, grid)
    shortcuts = zeros(Int, n, m, 4)
    for i in 0:(n + 1), j in 0:(m + 1)
        if i == 0 || i == n + 1 || j == 0 || j == m + 1 || grid[i, j] == '#'
            for dir in eachindex(DIRS)
                dx, dy = DIRS[dir]
                x, y = i, j
                while true
                    x += dx
                    y += dy
                    if x < 1 || x > n || y < 1 || y > m || grid[x, y] == '#'
                        break
                    end
                    shortcuts[x, y, mod1(dir + 2, 4)] = abs(x - i) + abs(y - j) - 1
                end
            end
        end
    end
    return shortcuts
end

function part_one(input)
    n, m, grid, sx, sy = get_info(input)
    vis = get_vis(n, m, grid, sx, sy)
    return length(vis)
end

function part_two(input)
    n, m, grid, sx, sy = get_info(input)
    original_vis = collect(get_vis(n, m, grid, sx, sy))
    shortcuts = get_shortcuts(n, m, grid)

    vis = [fill(false, n, m, 4) for _ in 1:Threads.nthreads()]
    ans = Atomic{Int}(0)
    Threads.@threads for (i, j) in original_vis
        if grid[i, j] != '.'
            continue
        end
        dir = 1
        x, y = sx, sy
        blocked = false
        visi = vis[Threads.threadid()]
        fill!(visi, false)
        while true
            dx, dy = DIRS[dir]
            if visi[x, y, dir]
                blocked = true
                break
            end
            visi[x, y, dir] = true
            if x + dx < 1 || x + dx > n || y + dy < 1 || y + dy > m
                break
            end
            if shortcuts[x, y, dir] > 0
                dist = shortcuts[x, y, dir]
                nx, ny = x + dx * dist, y + dy * dist
                if !(min(nx, x) <= i <= max(nx, x) && min(ny, y) <= j <= max(ny, y))
                    x, y = nx, ny
                    if x == 1 || x == n || y == 1 || y == m
                        continue
                    end
                    dir = mod1(dir + 1, 4)
                    continue
                end
            end

            if grid[x + dx, y + dy] == '.' && (x + dx, y + dy) != (i, j)
                x += dx
                y += dy
            else
                dir = mod1(dir + 1, 4)
            end
        end
        if blocked
            @atomic ans.x += 1
        end
    end

    return ans.x
end

@testitem "Day06" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day06: part_one, part_two, YEAR, DAY

    sample = """....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."""
    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample) == 41
        @test part_one(input) == 5305
    end

    @testset "Part Two" begin
        @test part_two(sample) == 6
        @test part_two(input) == 2143
    end
end

end
