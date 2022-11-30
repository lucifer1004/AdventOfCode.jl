module AdventOfCode

using HTTP, DotEnv, DataStructures, Pipe

export get_input, parse_input, submit_answer

function get_input(year, day)
    if day == 0
        return "Set variable \$day to make this work."
    end

    cfg = DotEnv.config(path="../../.env")
    session = cfg["AOC_SESSION"]

    r = HTTP.get("https://adventofcode.com/$year/day/$day/input", cookies=Dict("session" => session))
    return strip(String(r.body))
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

end
