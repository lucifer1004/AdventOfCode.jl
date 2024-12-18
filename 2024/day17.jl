module Day17

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function rewrite_program(program)
    @assert program[(end - 1):end]==[3, 0] "Invalid program"
    idx = 1
    forward_lines = String[]
    backward_lines = String[]

    combo(i) =
        if i <= 3
            string(i)
        elseif 4 <= i <= 6
            ["a", "b", "c"][i - 3]
        else
            ""
        end

    a_factor = -1
    for idx in 1:2:length(program)
        op = program[idx]
        operand = program[idx + 1]
        if op == 0 && operand <= 3
            @assert a_factor==-1 "Multiple a factors found"
            a_factor = 2^operand
        end
    end
    @assert a_factor!=-1 "No a factor found"

    while idx <= length(program)
        op = program[idx]
        if op == 0
            push!(forward_lines, "a ÷= 2^$(combo(program[idx + 1]))")
            if program[idx + 1] > 3
                push!(backward_lines, "a ÷= 2^$(combo(program[idx + 1]))")
            end
        elseif op == 1
            push!(forward_lines, "b ⊻= $(program[idx + 1])")
            push!(backward_lines, "b ⊻= $(program[idx + 1])")
        elseif op == 2
            push!(forward_lines, "b = $(combo(program[idx + 1])) % 8")
            push!(backward_lines, "b = $(combo(program[idx + 1])) % 8")
        elseif op == 3
            # Skip jnz since it's used for main loop only
        elseif op == 4
            push!(forward_lines, "b ⊻= c")
            push!(backward_lines, "b ⊻= c")
        elseif op == 5
            push!(forward_lines, "push!(outputs, $(combo(program[idx + 1])) % 8)")
            push!(backward_lines, "if $(combo(program[idx + 1])) % 8 == program[idx]")
            push!(backward_lines, "    for i in 0:$(a_factor - 1)")
            push!(backward_lines,
                "        dfs_$(hash(program))(a * $(a_factor) + i, b_orig, c_orig, program, idx - 1, output)")
            push!(backward_lines, "    end")
            push!(backward_lines, "end")
        elseif op == 6
            push!(forward_lines, "b = a ÷ 2^$(combo(program[idx + 1]))")
            push!(backward_lines, "b = a ÷ 2^$(combo(program[idx + 1]))")
        elseif op == 7
            push!(forward_lines, "c = a ÷ 2^$(combo(program[idx + 1]))")
            push!(backward_lines, "c = a ÷ 2^$(combo(program[idx + 1]))")
        end
        idx += 2
    end

    forward_func = """
    function run_program_$(hash(program))(a, b, c, program)
        outputs = Int[]
        while a != 0
            $(join(forward_lines, "\n        "))
        end
        return outputs
    end"""

    dfs_func = """
    function dfs_$(hash(program))(a::Int, b_orig::Int, c_orig::Int, program::AbstractVector{Int}, idx::Int, output::AbstractVector{Int})
        results = run_program_$(hash(program))(a, b_orig, c_orig, program)
        if length(results) == length(program)
            if all(results .== program)
                push!(output, a)
            else
                return
            end
        end
        if idx <= 0
            return
        end
        $(join(backward_lines, "\n    "))
        return
    end"""

    return forward_func, dfs_func
end

function get_info(input)
    lines = split(input, '\n')
    a = parse(Int, match(r"Register A: (\d+)", lines[1]).captures[1])
    b = parse(Int, match(r"Register B: (\d+)", lines[2]).captures[1])
    c = parse(Int, match(r"Register C: (\d+)", lines[3]).captures[1])
    program = parse.(Int, split(match(r"Program: (.+)", lines[5]).captures[1], ','))
    forward_func_str, dfs_func_str = rewrite_program(program)
    if !isdefined(@__MODULE__, Symbol("run_program_$(hash(program))"))
        eval(Meta.parse(forward_func_str))
    end
    if !isdefined(@__MODULE__, Symbol("dfs_$(hash(program))"))
        eval(Meta.parse(dfs_func_str))
    end
    return a, b, c, program
end

function part_one(input)
    a, b, c, program = get_info(input)
    forward_func = getfield(@__MODULE__, Symbol("run_program_$(hash(program))"))
    outputs = Base.invokelatest(forward_func, a, b, c, program)
    return join(outputs, ",")
end

function part_two(input)
    _, b, c, program = get_info(input)
    dfs_func = getfield(@__MODULE__, Symbol("dfs_$(hash(program))"))
    output = Int[]
    for i in 0:7
        Base.invokelatest(dfs_func, i, b, c, program, length(program), output)
    end
    @debug "All possible values: $output"
    return output[1]
end

@testitem "Day17" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day17: part_one, part_two, YEAR, DAY

    sample = """Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0"""

    sample2 = """Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0"""

    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample) == "4,6,3,5,6,3,5,2,1,0"
        @test part_one(input) == "7,4,2,5,1,4,6,0,4"
    end

    @testset "Part Two" begin
        @test part_two(sample2) == 117440
        @test part_two(input) == 164278764924605
    end
end

end
