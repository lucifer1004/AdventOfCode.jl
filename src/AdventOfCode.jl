module AdventOfCode

using DotEnv, HTTP, Reexport

@reexport using Pipe: @pipe
@reexport using BenchmarkTools, Combinatorics, DataInterpolations, DataStructures, Graphs,
                GraphPlot, IterTools, JSON3, LinearAlgebra, Memoization, MD5, MLStyle,
                Mods, OffsetArrays, StaticArrays, TestItems

export Atomic, get_input, parse_input, submit_answer

mutable struct Atomic{T}
    @atomic x::T
end

function get_input(year, day; force = false)
    inputdir = joinpath(@__DIR__, "..", string(year), "inputs")
    if !ispath(inputdir)
        mkpath(inputdir)
    end

    filename = joinpath(inputdir, "$day.txt")
    if !isfile(filename) || force
        cfg = DotEnv.config(joinpath(@__DIR__, "..", ".env"))
        session = cfg["AOC_SESSION"]
        try
            r = HTTP.get("https://adventofcode.com/$year/day/$day/input",
                cookies = Dict("session" => session))
            write(filename, rstrip(String(r.body)))
        catch e
            @error "Failed to get input for day $day of $year: $e"
            return ""
        end
    end

    return read(filename, String)
end

function submit_answer(year, day, answer, level = 1)
    if day == 0
        return "Set variable \$day to make this work."
    end

    cfg = DotEnv.config(joinpath(@__DIR__, "..", ".env"))
    session = cfg["AOC_SESSION"]
    r = HTTP.post("https://adventofcode.com/$year/day/$day/answer",
        [
            "Content-Type" => "application/x-www-form-urlencoded"
        ],
        HTTP.escapeuri(Dict("level" => level, "answer" => answer)),
        cookies = Dict("session" => session))
    return strip(String(r.body))
end

function parse_input(input::AbstractString)
    return @pipe input |> split(_, "\n") |> map(string, _)
end

include("algorithms.jl")
include("data_structures.jl")
include("AoC2016.jl")
include("AoC2019.jl")
include("AoC2023.jl")
include("AoC2024.jl")

end
