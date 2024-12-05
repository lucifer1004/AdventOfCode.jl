module Day05

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function solve(input)
    lines = parse_input(input)
    idx = findfirst(x -> x == "", lines)
    rule_lines = lines[1:(idx - 1)]
    num_lines = lines[(idx + 1):end]
    
    rules = Dict{Int, Set{Int}}()
    for line in rule_lines
        a, b = parse.(Int, split(line, "|"))
        push!(get!(rules, a, Set{Int}()), b)
    end

    nums = Vector{Int}[]
    correct_order = Vector{Int}[]
    for line in num_lines
        unordered_nums = parse.(Int, split(line, ","))
        push!(nums, unordered_nums)
        
        unordered_nums_set = Set(unordered_nums)
        to = Dict{Int, Int}()
        for num in unordered_nums
            for val in get(rules, num, Set{Int}())
                if val in unordered_nums_set
                    to[val] = get(to, val, 0) + 1
                end
            end
        end

        q = Int[]
        order = Int[]
        for num in unordered_nums
            if get(to, num, 0) == 0
                push!(q, num)
            end
        end

        while !isempty(q)
            num = pop!(q)
            push!(order, num)
            for next_num in get(rules, num, Set{Int}())
                if next_num in unordered_nums_set
                    to[next_num] = get(to, next_num, 0) - 1
                    if get(to, next_num, 0) == 0
                        push!(q, next_num)
                    end
                end
            end
        end
        push!(correct_order, order)
    end

    return nums, correct_order
end

get_score(nums) = nums[(firstindex(nums) + lastindex(nums)) ÷ 2]

function part_one(input)
    nums, correct_order = solve(input)
    return sum(get_score(correct_order[i]) for i in eachindex(nums) if all(correct_order[i] .== nums[i]))
end

function part_two(input)
    nums, correct_order = solve(input)
    return sum(get_score(correct_order[i]) for i in eachindex(nums) if any(correct_order[i] .!= nums[i]))
end

@testitem "Day05" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day05: part_one, part_two, YEAR, DAY

    sample = """47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47"""
    input = get_input(YEAR, DAY)

    @testset "Part One" begin
        @test part_one(sample) == 143
        @test part_one(input) == 4790
    end

    @testset "Part Two" begin
        @test part_two(sample) == 123
        @test part_two(input) == 6319
    end
end

end
