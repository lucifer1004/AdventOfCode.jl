module AoC2019

using ..AdventOfCode

export exec!

struct OpCode
    op::Int
    modes::NTuple{3,Int}
end

function OpCode(code::Int)
    op = code % 100
    modes = (code % 1000 ÷ 100, code % 10000 ÷ 1000, code ÷ 10000)
    OpCode(op, modes)
end

const OP_LEN = [4, 4, 2, 2, 3, 3, 4, 4]

function exec!(mem::AbstractVector{Int}; inputs::AbstractVector{Int}=Int[], auto=true)
    n = length(mem)
    mem = OffsetArray(mem, 0:n-1)
    ptr = 0
    input_ptr = 1
    outputs = Int[]
    while true
        opcode = OpCode(mem[ptr])
        if opcode.op == 1
            src1, src2, target = mem[ptr+1:ptr+3]
            if opcode.modes[1] == 0
                src1 = mem[src1]
            end
            if opcode.modes[2] == 0
                src2 = mem[src2]
            end

            @assert opcode.modes[3] == 0
            mem[target] = src1 + src2
        elseif opcode.op == 2
            src1, src2, target = mem[ptr+1:ptr+3]
            if opcode.modes[1] == 0
                src1 = mem[src1]
            end
            if opcode.modes[2] == 0
                src2 = mem[src2]
            end

            @assert opcode.modes[3] == 0
            mem[target] = src1 * src2
        elseif opcode.op == 3
            target = mem[ptr+1]

            if auto
                value = inputs[input_ptr]
                input_ptr += 1
            else
                value = parse(Int, readline())
            end

            @assert opcode.modes[1] == 0
            mem[target] = value
        elseif opcode.op == 4
            src = mem[ptr+1]
            if opcode.modes[1] == 0
                src = mem[src]
            end

            if auto
                push!(outputs, src)
            else
                print(src)
            end
        elseif opcode.op == 5
            src, target = mem[ptr+1:ptr+2]
            if opcode.modes[1] == 0
                src = mem[src]
            end
            if opcode.modes[2] == 0
                target = mem[target]
            end
            if src != 0
                ptr = target
                continue
            end
        elseif opcode.op == 6
            src, target = mem[ptr+1:ptr+2]
            if opcode.modes[1] == 0
                src = mem[src]
            end
            if opcode.modes[2] == 0
                target = mem[target]
            end
            if src == 0
                ptr = target
                continue
            end
        elseif opcode.op == 7
            src1, src2, target = mem[ptr+1:ptr+3]
            if opcode.modes[1] == 0
                src1 = mem[src1]
            end
            if opcode.modes[2] == 0
                src2 = mem[src2]
            end

            @assert opcode.modes[3] == 0
            mem[target] = src1 < src2 ? 1 : 0
        elseif opcode.op == 8
            src1, src2, target = mem[ptr+1:ptr+3]
            if opcode.modes[1] == 0
                src1 = mem[src1]
            end
            if opcode.modes[2] == 0
                src2 = mem[src2]
            end

            @assert opcode.modes[3] == 0
            mem[target] = src1 == src2 ? 1 : 0
        elseif opcode.op == 99
            break
        end

        ptr += OP_LEN[opcode.op]
    end

    return outputs
end

end
