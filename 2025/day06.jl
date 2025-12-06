module Day06

using ...AdventOfCode
using ..AoC2025

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

# Helper: operation and identity
reduce_op(op) = op == "*" ? prod : sum  # for reducing collections
binary_op(op) = op == "*" ? (*) : (+)    # for two values
identity_for(op) = op == "*" ? 1 : 0

# Part One: Numbers are whitespace-separated, apply op per column
function part_one(input)
    lines = split(input, '\n')
    nums = [parse.(Int, split(line)) for line in lines[1:(end - 1)]]
    ops = split(lines[end])

    mapreduce(+, enumerate(ops)) do (i, op)
        reduce_op(op)(row[i] for row in nums)
    end
end

# Part Two: Read digits vertically, columns of spaces are separators
function part_two(input)
    lines = split(input, '\n')
    ops = split(lines[end])
    m = maximum(length, lines)
    grid = [get(line, j, ' ') for line in lines[1:(end - 1)], j in 1:m]

    # Read vertical number from column (skip spaces)
    col_to_num(col) =
        foldl(col; init = 0) do n, c
            c == ' ' ? n : 10n + (c - '0')
        end

    # Fold over columns: state = (total, op_index, accumulator)
    (total,
        idx,
        acc) = foldl(eachcol(grid); init = (
        0, 1, identity_for(ops[1]))) do (total, idx, acc), col
        if all(==(' '), col)  # separator → finalize group, start next
            new_idx = idx + 1
            new_idx > length(ops) ? (total + acc, new_idx, 0) :
            (total + acc, new_idx, identity_for(ops[new_idx]))
        else  # accumulate number into current group
            (total, idx, binary_op(ops[idx])(acc, col_to_num(col)))
        end
    end

    idx <= length(ops) ? total + acc : total
end

@testitem "Day06" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2025.Day06: part_one, part_two, YEAR, DAY
    input = get_input(YEAR, DAY)

    sample = """123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   + """

    @testset "Part One" begin
        @test part_one(sample) == 4277556
        @test part_one(input) == 4076006202939
    end

    @testset "Part Two" begin
        @test part_two(sample) == 3263827
        @test part_two(input) == 7903168391557
    end
end

end
