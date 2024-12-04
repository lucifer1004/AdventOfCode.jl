module Day04

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])
const DIRS = [(0, 1), (1, 0), (0, -1), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1)]

function get_board(input)
    board = parse_input(input)
    n = length(board)
    m = length(board[1])
    return n, m, board
end

function part_one(input)
    n, m, board = get_board(input)
    ans = 0
    for i in 1:n, j in 1:m
        if board[i][j] == 'X'
            for d in DIRS
                if i + 3d[1] in 1:n && j + 3d[2] in 1:m
                    chars = [
                        board[i + d[1]][j + d[2]],
                        board[i + 2d[1]][j + 2d[2]],
                        board[i + 3d[1]][j + 3d[2]]
                    ]
                    if join(chars) == "MAS"
                        ans += 1
                    end
                end
            end
        end
    end
    return ans
end

function part_two(input)
    n, m, board = get_board(input)
    ans = 0
    for i in 2:(n - 1), j in 2:(m - 1)
        if board[i][j] == 'A'
            a = board[i - 1][j - 1]
            b = board[i - 1][j + 1]
            c = board[i + 1][j - 1]
            d = board[i + 1][j + 1]
            mc = count(x -> x == 'M', [a, b, c, d])
            sc = count(x -> x == 'S', [a, b, c, d])
            if mc == 2 && sc == 2 && a != d && b != c
                ans += 1
            end
        end
    end
    return ans
end

@testitem "Day04" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day04: part_one, part_two, YEAR, DAY

    sample = """MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"""
    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample) == 18
        @test part_one(input) == 2507
    end

    @testset "Part Two" begin
        @test part_two(sample) == 9
        @test part_two(input) == 1969
    end
end

end
