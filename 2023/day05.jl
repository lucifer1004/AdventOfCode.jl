module Day05

using ...AdventOfCode

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function parse_input_(input)
    data = split(input, r"\n.*:.*\n")
    seeds = @pipe match(r"seeds: (.*)\n", data[1]).captures[1] |>
                  parse.(Int, split(_, " "))
    mappings = map(data[2:end]) do mapping
        lines = split(mapping, "\n", keepempty = false)
        rules = map(lines) do line
            dest, start, rg = parse.(Int, split(line))
            start, start + rg - 1, dest
        end
        sort!(rules, by = x -> x[2])

        m = length(rules)
        if rules[1][1] > 1
            push!(rules, (1, rules[1][1] - 1, 1))
        end
        if rules[m][2] < 1_000_000_000_000_000_000
            push!(rules, (rules[m][2] + 1, 1_000_000_000_000_000_000, rules[m][2] + 1))
        end
        for i in 1:(m - 1)
            if rules[i][2] + 1 < rules[i + 1][1]
                push!(rules, (rules[i][2] + 1, rules[i + 1][1] - 1, rules[i][2] + 1))
            end
        end

        sort!(rules, by = x -> x[2])
    end

    seeds, mappings
end

function part_one(input)
    seeds, mappings = parse_input_(input)

    low = typemax(Int64)
    for seed in seeds
        val = seed
        for mapping in mappings
            for (left, right, dest) in mapping
                if left <= val <= right
                    val = dest + (val - left)
                    break
                end
            end
        end
        low = min(low, val)
    end

    low
end

function cleanup(segments)
    sort!(segments)
    n = length(segments)
    segments_nxt = Tuple{Int, Int}[]
    l, r = segments[1]
    for (l′, r′) in segments[2:n]
        if l′ <= r + 1
            r = max(r, r′)
        else
            push!(segments_nxt, (l, r))
            l, r = l′, r′
        end
    end
    push!(segments_nxt, (l, r))
    segments_nxt
end

function part_two(input)
    seeds, mappings = parse_input_(input)
    n = length(seeds)

    low = typemax(Int64)
    segments = [(seeds[i], seeds[i] + seeds[i + 1] - 1) for i in 1:2:n] |> cleanup
    for mapping in mappings
        segments_nxt = Tuple{Int, Int}[]
        for segment in segments
            for (left, right, dest) in mapping
                intersect = max(segment[1], left):min(segment[2], right)
                if !isempty(intersect)
                    push!(segments_nxt,
                        (dest + (intersect[1] - left), dest + (intersect[end] - left)))
                end
            end
        end
        segments = cleanup(segments_nxt)
    end

    if !isempty(segments)
        low = min(low, minimum(s[1] for s in segments))
    end

    low
end

@testitem "Day05" begin
    using AdventOfCode.AoC2023.Day05: part_one, part_two

    sample = """seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"""

    @testset "Part One" begin
        @test part_one(sample) == 35
    end

    @testset "Part Two" begin
        @test part_two(sample) == 46
    end
end

end
