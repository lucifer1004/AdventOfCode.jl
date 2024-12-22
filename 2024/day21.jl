module Day21

using ...AdventOfCode
using ..AoC2024

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

const NUMPAD = Dict{String, String}(
    "00" => "A", "01" => "^<A", "02" => "^A", "03" => "^>A",
    "04" => "^^<A", "05" => "^^A", "06" => "^^>A", "07" => "^^^<A",
    "08" => "^^^A", "09" => "^^^>A", "0A" => ">A", "10" => ">vA",
    "11" => "A", "12" => ">A", "13" => ">>A", "14" => "^A",
    "15" => "^>A", "16" => "^>>A", "17" => "^^A", "18" => "^^>A",
    "19" => "^^>>A", "1A" => ">>vA", "20" => "vA", "21" => "<A",
    "22" => "A", "23" => ">A", "24" => "<^A", "25" => "^A",
    "26" => "^>A", "27" => "<^^A", "28" => "^^A", "29" => "^^>A",
    "2A" => "v>A", "30" => "<vA", "31" => "<<A", "32" => "<A",
    "33" => "A", "34" => "<<^A", "35" => "<^A", "36" => "^A",
    "37" => "<<^^A", "38" => "<^^A", "39" => "^^A", "3A" => "vA",
    "40" => ">vvA", "41" => "vA", "42" => "v>A", "43" => "v>>A",
    "44" => "A", "45" => ">A", "46" => ">>A", "47" => "^A",
    "48" => "^>A", "49" => "^>>A", "4A" => ">>vvA", "50" => "vvA",
    "51" => "<vA", "52" => "vA", "53" => "v>A", "54" => "<A",
    "55" => "A", "56" => ">A", "57" => "<^A", "58" => "^A",
    "59" => "^>A", "5A" => "vv>A", "60" => "<vvA", "61" => "<<vA",
    "62" => "<vA", "63" => "vA", "64" => "<<A", "65" => "<A",
    "66" => "A", "67" => "<<^A", "68" => "<^A", "69" => "^A",
    "6A" => "vvA", "70" => ">vvvA", "71" => "vvA", "72" => "vv>A",
    "73" => "vv>>A", "74" => "vA", "75" => "v>A", "76" => "v>>A",
    "77" => "A", "78" => ">A", "79" => ">>A", "7A" => ">>vvvA",
    "80" => "vvvA", "81" => "<vvA", "82" => "vvA", "83" => "vv>A",
    "84" => "<vA", "85" => "vA", "86" => "v>A", "87" => "<A",
    "88" => "A", "89" => ">A", "8A" => "vvv>A", "90" => "<vvvA",
    "91" => "<<vvA", "92" => "<vvA", "93" => "vvA", "94" => "<<vA",
    "95" => "<vA", "96" => "vA", "97" => "<<A", "98" => "<A",
    "99" => "A", "9A" => "vvvA", "A0" => "<A", "A1" => "^<<A",
    "A2" => "<^A", "A3" => "^A", "A4" => "^^<<A", "A5" => "<^^A",
    "A6" => "^^A", "A7" => "^^^<<A", "A8" => "<^^^A", "A9" => "^^^A",
    "AA" => "A"
)

const DIRPAD = Dict{String, String}(
    "<<" => "A", "<>" => ">>A", "<A" => ">>^A", "<^" => ">^A",
    "<v" => ">A", "><" => "<<A", ">>" => "A", ">A" => "^A",
    ">^" => "<^A", ">v" => "<A", "A<" => "v<<A", "A>" => "vA",
    "AA" => "A", "A^" => "<A", "Av" => "<vA", "^<" => "v<A",
    "^>" => "v>A", "^A" => ">A", "^^" => "A", "^v" => "vA",
    "v<" => "<A", "v>" => ">A", "vA" => "^>A", "v^" => "^A",
    "vv" => "A"
)

# To solve for large numbers, one can use `BigInt` for `max_depth`
function solve(input; max_depth::T) where {T}
    lines = split(input, '\n')
    ans = 0
    for line in lines
        @assert line[end] == 'A'  # Valid inputs always end with 'A'
        num = parse(Int, line[1:(lastindex(line) - 1)])
        initial = join(NUMPAD[a * b] for (a, b) in zip("A" * line, line))
        cnt = DefaultDict{String, T}(0)
        for (a, b) in zip("A" * initial, initial)
            cnt[a * b] += 1
        end
        for _ in 1:max_depth
            ncnt = DefaultDict{String, T}(0)
            for k in keys(cnt)
                for (a, b) in zip("A" * DIRPAD[k], DIRPAD[k])
                    ncnt[a * b] += cnt[k]
                end
            end
            cnt = ncnt
        end
        ans += num * sum(values(cnt))
    end
    return ans
end

part_one(input) = solve(input; max_depth = 2)
part_two(input) = solve(input; max_depth = 25)

@testitem "Day21" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2024.Day21: part_one, part_two, YEAR, DAY
    input = get_input(YEAR, DAY)

    sample = """029A
980A
179A
456A
379A"""

    @testset "Part One" begin
        @test part_one(sample) == 126384
        @test part_one(input) == 238078
    end

    @testset "Part Two" begin
        @test part_two(sample) == 154115708116294
        @test part_two(input) == 293919502998014
    end
end

end
