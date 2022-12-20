import Pkg
Pkg.activate("..")

using AdventOfCode

function preprocess(input)
    map(input) do line
        parts = split(line, "Each ")[2:5]
        map(parts) do part
            items = split(part, " costs ")[2]
            items = rstrip(items)
            @assert items[end] == '.'
            items = items[1:end-1]
            items = split(items, " and ")
            items = map(items) do item
                item = split(item, " ")
                @assert length(item) == 2
                parse(Int, item[1])
            end
            tuple(items...)
        end
    end
end

function solve(bp, T, ORE, CLAY, OBSIDIAN, MAXORE, MAXCLAY, MAXOBSIDIAN)
    # (ra, rb, rc, a, b, c, t)
    dp = OffsetArray(fill(-1, 1:ORE, 0:CLAY, 0:OBSIDIAN, 0:MAXORE, 0:MAXCLAY, 0:MAXOBSIDIAN, 0:T), 1:ORE, 0:CLAY, 0:OBSIDIAN, 0:MAXORE, 0:MAXCLAY, 0:MAXOBSIDIAN, 0:T)
    dp[1, 0, 0, 0, 0, 0, 0] = 0
    for t in 0:T-1
        for ra in 1:ORE, rb in 0:CLAY, rc in 0:OBSIDIAN, a in 0:MAXORE, b in 0:MAXCLAY, c in 0:MAXOBSIDIAN
            now = CartesianIndex(ra, rb, rc, a, b, c, t)
            if dp[now] == -1
                continue
            end

            if a >= bp[1][1] && ra < ORE
                idx = CartesianIndex(ra + 1, rb, rc, min(a - bp[1][1] + ra, MAXORE), min(b + rb, MAXCLAY), min(c + rc, MAXOBSIDIAN), t + 1)
                dp[idx] = max(dp[idx], dp[now])
            end

            if a >= bp[2][1] && rb < CLAY
                idx = CartesianIndex(ra, rb + 1, rc, min(a - bp[2][1] + ra, MAXORE), min(b + rb, MAXCLAY), min(c + rc, MAXOBSIDIAN), t + 1)
                dp[idx] = max(dp[idx], dp[now])
            end

            if a >= bp[3][1] && b >= bp[3][2] && rc < OBSIDIAN
                idx = CartesianIndex(ra, rb, rc + 1, min(a - bp[3][1] + ra, MAXORE), min(b - bp[3][2] + rb, MAXCLAY), min(c + rc, MAXOBSIDIAN), t + 1)
                dp[idx] = max(dp[idx], dp[now])
            end

            if a >= bp[4][1] && c >= bp[4][2]
                idx = CartesianIndex(ra, rb, rc, min(a - bp[4][1] + ra, MAXORE), min(b + rb, MAXCLAY), min(c - bp[4][2] + rc, MAXOBSIDIAN), t + 1)
                dp[idx] = max(dp[idx], dp[now] + T - 1 - t)
            end

            idx = CartesianIndex(ra, rb, rc, min(a + ra, MAXORE), min(b + rb, MAXCLAY), min(c + rc, MAXOBSIDIAN), t + 1)
            dp[idx] = max(dp[idx], dp[now])
        end
    end

    return maximum(dp)
end

function part_one(input)
    bps = preprocess(input)
    ans = zeros(Int, length(bps))
    Threads.@threads for i in eachindex(bps)
        bp = bps[i]

        T = 24
        ORE = max(bp[1][1], bp[2][1], bp[3][1], bp[4][1])
        CLAY = bp[3][2]
        OBSIDIAN = bp[4][2]

        MAXORE = 2 * ORE
        MAXCLAY = 2 * CLAY
        MAXOBSIDIAN = 2 * OBSIDIAN
        ans[i] = solve(bp, T, ORE, CLAY, OBSIDIAN, MAXORE, MAXCLAY, MAXOBSIDIAN)
    end

    return sum(i * x for (i, x) in enumerate(ans))
end

function part_two(input)
    bps = preprocess(input)
    ans = zeros(Int, length(bps))
    Threads.@threads for i in eachindex(bps)
        bp = bps[i]

        T = 32
        ORE = max(bp[1][1], bp[2][1], bp[3][1], bp[4][1])
        CLAY = bp[3][2]
        OBSIDIAN = bp[4][2]

        MAXORE = 2 * ORE
        MAXCLAY = 2 * CLAY
        MAXOBSIDIAN = 2 * OBSIDIAN
        ans[i] = solve(bp, T, ORE, CLAY, OBSIDIAN, MAXORE, MAXCLAY, MAXOBSIDIAN)
    end

    return prod(ans)
end

function main()
    input = get_input(2022, 19)
    parsed_input = parse_input(input)

    @time println("Part 1: ", part_one(parsed_input))
    @time println("Part 2: ", part_two(parsed_input[1:3]))
end

main()
