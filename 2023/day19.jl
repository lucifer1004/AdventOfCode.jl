module Day19

using ...AdventOfCode

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

struct Rule
    index::Int
    islt::Bool
    threshold::Int
    destination::String
end

const MAPPING = Dict('x' => 1,
    'm' => 2,
    'a' => 3,
    's' => 4)

function preprocessing(input)
    input = parse_input(input)

    i = 1
    while input[i] != ""
        i += 1
    end

    rules = input[1:(i - 1)]
    messages = input[(i + 1):end]
    rules_dict = Dict{String, Vector{Rule}}()

    for rule in rules
        key, value = split(rule, "{")
        parts = split(value[1:(end - 1)], ",")
        rules_dict[key] = map(parts) do part
            if occursin(":", part)
                expr, value = split(part, ":")
                value = string(value)
                if occursin("<", expr)
                    Rule(MAPPING[expr[1]], 1, parse(Int, expr[3:end]), value)
                else
                    Rule(MAPPING[expr[1]], 0, parse(Int, expr[3:end]), value)
                end
            else
                Rule(1, 0, 0, part)
            end
        end
    end

    parsed_messages = map(messages) do message
        parse.(Int, match(r"{x=(\d+),m=(\d+),a=(\d+),s=(\d+)}", message).captures)
    end

    rules_dict, parsed_messages
end

function part_one(input)
    rules_dict, messages = preprocessing(input)

    ans = 0
    for msg in messages
        curr = "in"
        while curr != "A" && curr != "R"
            rules = rules_dict[curr]
            for rule in rules
                if (rule.islt && msg[rule.index] < rule.threshold) ||
                   (!rule.islt && msg[rule.index] > rule.threshold)
                    curr = rule.destination
                    break
                end
            end
        end

        if curr == "A"
            ans += sum(msg)
        end
    end

    ans
end

function part_two(input; lowerbound = 1, upperbound = 4001)
    rules_dict, _ = preprocessing(input)
    ans = 0

    function dfs(ranges, curr)
        if prod([length(r) - 1 for r in ranges]) == 0
            return
        end

        if curr == "A"
            ans += prod([length(r) - 1 for r in ranges])
            return
        end

        if curr == "R"
            return
        end

        rules = rules_dict[curr]
        for rule in rules
            nxt = deepcopy(ranges)
            if rule.islt
                nxt[rule.index] = intersect(ranges[rule.index], lowerbound:(rule.threshold))
                dfs(nxt, rule.destination)
                ranges[rule.index] = intersect(ranges[rule.index],
                    (rule.threshold):upperbound)
            else
                nxt[rule.index] = intersect(ranges[rule.index],
                    (rule.threshold + 1):upperbound)
                dfs(nxt, rule.destination)
                ranges[rule.index] = intersect(ranges[rule.index],
                    lowerbound:(rule.threshold + 1))
            end
        end
    end

    dfs(fill(lowerbound:upperbound, 4), "in")

    ans
end

@testitem "Day19" begin
    using AdventOfCode.AoC2023.Day19: part_one, part_two

    sample = """px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}"""

    @testset "Part One" begin
        @test part_one(sample) == 19114
    end

    @testset "Part Two" begin
        @test part_two(sample) == 167409079868000
    end
end

end
