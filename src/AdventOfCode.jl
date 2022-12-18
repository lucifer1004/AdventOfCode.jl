module AdventOfCode

using DotEnv, HTTP, Pipe, Reexport

@reexport using BenchmarkTools, Combinatorics, DataStructures, Graphs, GraphPlot, IterTools, JSON3, LinearAlgebra, MD5, MLStyle, Mods, OffsetArrays

export get_input, parse_input, submit_answer

function get_input(year, day; force=false)
    inputdir = joinpath(@__DIR__, "..", string(year), "inputs")
    if !ispath(inputdir)
        mkpath(inputdir)
    end

    filename = joinpath(inputdir, "$day.txt")
    if !isfile(filename) || force
        cfg = DotEnv.config(joinpath(@__DIR__, "..", ".env"))
        session = cfg["AOC_SESSION"]
        r = HTTP.get("https://adventofcode.com/$year/day/$day/input", cookies=Dict("session" => session))
        write(filename, rstrip(String(r.body)))
    end

    return read(filename, String)
end

function submit_answer(year, day, answer, level=1)
    if day == 0
        return "Set variable \$day to make this work."
    end

    cfg = DotEnv.config(path="../../.env")
    session = cfg["AOC_SESSION"]

    r = HTTP.post("https://adventofcode.com/$year/day/$day/answer",
        [
            "Content-Type" => "application/x-www-form-urlencoded",
        ],
        HTTP.escapeuri(Dict("level" => level, "answer" => answer)),
        cookies=Dict("session" => session))
    return strip(String(r.body))
end

function parse_input(input::AbstractString)
    return @pipe input |> split(_, "\n")
end

include("data_structures.jl")
include("AoC2016.jl")

end
