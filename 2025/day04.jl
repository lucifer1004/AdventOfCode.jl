module Day04

using ...AdventOfCode
using ..AoC2025

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

parse_grid(input) = permutedims(stack(split(input, '\n'))) .== '@'

# Iterate over 8-neighbors (macro: zero runtime overhead)
macro for_neighbors(i, j, nrow, ncol, body)
    quote
        for $(esc(:ni)) in max(1, $(esc(i)) - 1):min($(esc(i)) + 1, $(esc(nrow)))
            for $(esc(:nj)) in max(1, $(esc(j)) - 1):min($(esc(j)) + 1, $(esc(ncol)))
                ($(esc(:ni)) == $(esc(i)) && $(esc(:nj)) == $(esc(j))) && continue
                $(esc(body))
            end
        end
    end
end

# Compute neighbor counts via convolution (in-place)
function neighbor_counts!(nei, arr)
    fill!(nei, 0)
    nrow, ncol = size(arr)
    for di in -1:1, dj in -1:1
        (di, dj) == (0, 0) && continue
        ri = max(1, 1 + di):min(nrow, nrow + di)
        rj = max(1, 1 + dj):min(ncol, ncol + dj)
        si = max(1, 1 - di):min(nrow, nrow - di)
        sj = max(1, 1 - dj):min(ncol, ncol - dj)
        @views nei[ri, rj] .+= arr[si, sj]
    end
    nei .*= arr
end

function part_one(input; threshold = 4)
    arr = parse_grid(input)
    nei = similar(arr, Int)
    neighbor_counts!(nei, arr)
    count(arr .& (nei .< threshold))
end

function part_two(input; threshold = 4)
    arr = parse_grid(input)
    nrow, ncol = size(arr)
    nei = similar(arr, Int)
    neighbor_counts!(nei, arr)

    # Initialize with unstable cells
    vis = arr .& (nei .< threshold)
    stk = [(I[1], I[2]) for I in findall(vis)]

    # Cascade removal
    ans = 0
    while !isempty(stk)
        ans += 1
        i, j = pop!(stk)
        @for_neighbors i j nrow ncol begin
            if arr[ni, nj]
                nei[ni, nj] -= 1
                if nei[ni, nj] < threshold && !vis[ni, nj]
                    push!(stk, (ni, nj))
                    vis[ni, nj] = true
                end
            end
        end
    end
    ans
end

@testitem "Day04" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2025.Day04: part_one, part_two, YEAR, DAY
    input = get_input(YEAR, DAY)

    sample = """..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."""

    @testset "Part One" begin
        @test part_one(sample) == 13
        @test part_one(input) == 1351
    end

    @testset "Part Two" begin
        @test part_two(sample) == 43
        @test part_two(input) == 8345
    end
end

end

