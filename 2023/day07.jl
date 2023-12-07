module Day07

using ...AdventOfCode

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

const ORDER = Dict('A' => 14,
    'K' => 13,
    'Q' => 12,
    'J' => 11,
    'T' => 10,
    [string(i)[1] => i for i in 2:9]...)

const ORDER_J = Dict(ORDER..., 'J' => 0)

struct Hand
    type::String
    values::NTuple{5, Int}
    bid::Int
end

function Base.isless(h1::Hand, h2::Hand)
    h1.type < h2.type ||
        h1.type == h2.type && h1.values < h2.values
end

function Hand(line::AbstractString, dict::AbstractDict = ORDER, J_is_special::Bool = false)
    cards, bid = split(line)
    bid = parse(Int, bid)
    nums = Tuple(dict[c] for c in cards)

    cnt = Dict()
    j = 0
    for c in cards
        if c == 'J' && J_is_special
            j += 1
        else
            cnt[c] = get(cnt, c, 0) + 1
        end
    end

    vals = values(cnt) |> collect
    sort!(vals, rev = true)
    if vals == []
        vals = [j]
    elseif J_is_special
        vals[1] += j
    end
    s = join(vals, "")

    Hand(s, nums, bid)
end

function solve(input, J_is_special)
    input = parse_input(input)
    hands = Hand.(input, J_is_special ? (ORDER_J,) : (ORDER,), J_is_special)
    sort!(hands)
    sum(i * h.bid for (i, h) in enumerate(hands))
end

part_one(input) = solve(input, false)
part_two(input) = solve(input, true)

@testitem "Day07" begin
    using AdventOfCode.AoC2023.Day07: part_one, part_two

    sample = """32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483"""

    @testset "Part One" begin
        @test part_one(sample) == 6440
    end

    @testset "Part Two" begin
        @test part_two(sample) == 5905
    end
end

end
