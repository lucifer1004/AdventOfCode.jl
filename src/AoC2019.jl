module AoC2019

using ..AdventOfCode

export exec!

function exec!(mem::AbstractVector{Int})
    n = length(mem)
    mem = OffsetArray(mem, 0:n-1)
    ptr = 0
    while true
        if mem[ptr] == 1
            arg1, arg2, target = mem[ptr+1:ptr+3]
            mem[target] = mem[arg1] + mem[arg2]
            ptr += 4
        elseif mem[ptr] == 2
            arg1, arg2, target = mem[ptr+1:ptr+3]
            mem[target] = mem[arg1] * mem[arg2]
            ptr += 4
        elseif mem[ptr] == 99
            break
        end
    end
end

end
