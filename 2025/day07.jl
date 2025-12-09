module Day07

using ...AdventOfCode
using ..AoC2025

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function find_start(grid)
    for (r, row) in enumerate(grid)
        c = findfirst(==('S'), row)
        c !== nothing && return (r, c)
    end
    error("Start not found")
end

#=
## Alternative: Generic Abstraction (for reference)

Both parts can be unified with a single `traverse` function:

```julia
function traverse(input, f; T=Int, init=one(T), merge=(+), finalize=sum)
    grid = split(input, '\n')
    H, W = length(grid), length(grid[1])
    sr, sc = find_start(grid)
    curr, next = zeros(T, W), zeros(T, W)
    curr[sc] = init
    acc = zero(T)
    for r in sr:(H - 1)
        fill!(next, zero(T))
        for c in 1:W
            iszero(curr[c]) && continue
            ch = grid[r + 1][c]
            if ch == '.'
                next[c] = merge(next[c], curr[c])
            elseif ch == '^'
                acc = f(acc, r + 1, c, curr[c])
                c > 1 && (next[c - 1] = merge(next[c - 1], curr[c]))
                c < W && (next[c + 1] = merge(next[c + 1], curr[c]))
            end
        end
        curr, next = next, curr
    end
    finalize(acc, curr)
end

# Part One: count unique trees
part_one(input) = let counted = Set{Tuple{Int,Int}}()
    traverse(input, (acc, r, c, _) -> (r,c) ∈ counted ? acc : (push!(counted, (r,c)); acc+1);
             T=Bool, init=true, merge=(|), finalize=(acc, _) -> acc)
end

# Part Two: count paths to bottom  
part_two(input) = traverse(input, (acc, r, c, v) -> acc;
                           T=Int, init=1, merge=(+), finalize=(_, curr) -> sum(curr))
```

Trade-off: Reduces duplication but increases cognitive complexity.
=#

# Part One: Row traversal, count unique trees hit
function part_one(input)
    grid = split(input, '\n')
    H, W = length(grid), length(grid[1])
    sr, sc = find_start(grid)

    reachable = falses(W)
    reachable[sc] = true
    counted = falses(H, W)
    trees = 0

    for r in sr:(H - 1)
        next_reach = falses(W)
        for c in 1:W
            reachable[c] || continue
            ch = grid[r + 1][c]
            if ch == '.'
                next_reach[c] = true
            elseif ch == '^'
                if !counted[r + 1, c]
                    counted[r + 1, c] = true
                    trees += 1
                end
                c > 1 && (next_reach[c - 1] = true)
                c < W && (next_reach[c + 1] = true)
            end
        end
        reachable = next_reach
    end
    trees
end

# Part Two: Row traversal, count total paths to bottom (space-optimized)
function part_two(input)
    grid = split(input, '\n')
    H, W = length(grid), length(grid[1])
    sr, sc = find_start(grid)

    curr, next = zeros(Int, W), zeros(Int, W)
    curr[sc] = 1

    for r in sr:(H - 1)
        fill!(next, 0)
        for c in 1:W
            curr[c] == 0 && continue
            ch = grid[r + 1][c]
            if ch == '.'
                next[c] += curr[c]
            elseif ch == '^'
                c > 1 && (next[c - 1] += curr[c])
                c < W && (next[c + 1] += curr[c])
            end
        end
        curr, next = next, curr
    end
    sum(curr)
end

@testitem "Day07" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2025.Day07: part_one, part_two, YEAR, DAY
    input = get_input(YEAR, DAY)

    sample = """.......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
..............."""

    @testset "Part One" begin
        @test part_one(sample) == 21
        @test part_one(input) == 1703
    end

    @testset "Part Two" begin
        @test part_two(sample) == 40
        @test part_two(input) == 171692855075500
    end
end

end
