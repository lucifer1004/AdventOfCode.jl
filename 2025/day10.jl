module Day10

using AdventOfCode
using DataStructures: Deque
using JuMP
using HiGHS

const YEAR = 2025
const DAY = 10

"""
Part One: BFS on bit states (toggle XOR)
Part Two: Integer Linear Programming (minimize button presses)

For Part Two, the problem is:
- Variables: x_i = number of times button i is pressed
- Constraints: A × x = target (A is 0-1 button-counter matrix)
- Objective: minimize sum(x)

BFS would explore O(∏(target[i]+1)) states, which can be billions.
ILP solves this optimally in milliseconds.
"""

# Parse button indices from "(0,2,3)" format
parse_buttons(parts) = [parse.(Int, split(x[2:(end - 1)], ",")) for x in parts[2:(end - 1)]]

# Part One: BFS on bit states
function part_one(input)
    ans = 0
    for line in input
        parts = split(line)
        target_pattern = parts[1][2:(end - 1)]
        button_indices = parse_buttons(parts)

        m = length(target_pattern)
        target_bits = sum((target_pattern[i] == '#') << (i - 1) for i in 1:m)
        buttons = [sum(1 << bit for bit in btn) for btn in button_indices]

        nstates = 1 << m
        dp = fill(typemax(Int), nstates)
        dp[1] = 0
        q = Deque{Int}()
        push!(q, 0)
        while !isempty(q)
            u = popfirst!(q)
            for button in buttons
                nxt = u ⊻ button
                if dp[nxt + 1] == typemax(Int)
                    push!(q, nxt)
                    dp[nxt + 1] = dp[u + 1] + 1
                end
            end
        end
        ans += dp[target_bits + 1]
    end
    ans
end

# Part Two: ILP solver
function solve_ilp(line)
    parts = split(line)
    target = parse.(Int, split(parts[end][2:(end - 1)], ","))
    button_indices = parse_buttons(parts)

    m = length(target)
    n = length(button_indices)

    # Build button matrix A (m×n): A[i,j] = 1 if button j affects counter i
    A = zeros(Int, m, n)
    for (j, btn) in enumerate(button_indices)
        for i in btn
            A[i + 1, j] = 1
        end
    end

    # ILP model: minimize sum(x) s.t. A*x = target, x >= 0, x ∈ Z
    model = Model(HiGHS.Optimizer)
    set_silent(model)

    @variable(model, x[1:n] >= 0, Int)
    @constraint(model, A * x .== target)
    @objective(model, Min, sum(x))

    optimize!(model)
    round(Int, objective_value(model))
end

function part_two(input)
    sum(solve_ilp(line) for line in input)
end

@testitem "Day10" begin
    using AdventOfCode: get_input, parse_input
    using AdventOfCode.AoC2025.Day10: part_one, part_two, YEAR, DAY

    input = get_input(YEAR, DAY)
    parsed = parse_input(input)

    sample = """[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"""
    parsed_sample = parse_input(sample)

    @testset "Part One" begin
        @test part_one(parsed_sample) == 7
        @test part_one(parsed) == 396
    end

    @testset "Part Two" begin
        @test part_two(parsed_sample) == 33
        @test part_two(parsed) == 15688
    end
end

end
