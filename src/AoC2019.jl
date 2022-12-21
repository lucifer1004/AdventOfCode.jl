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

const OP_LEN = [4, 4, 2, 2, 3, 3, 4, 4, 2]

function parse_arg(mem, raw, mode, relative_base)
    if mode == 0
        return mem[raw]
    elseif mode == 1
        return raw
    elseif mode == 2
        return mem[raw+relative_base]
    end
end

function exec!(mem::AbstractVector{Int}; inputs::AbstractVector{Int}=Int[], auto=true, maximum_size=100000)
    n = length(mem)
    append!(mem, zeros(Int, maximum_size - n))
    mem = OffsetArray(mem, 0:maximum_size-1)
    ptr = 0
    input_ptr = 1
    relative_base = 0
    outputs = Int[]
    while true
        opcode = OpCode(mem[ptr])
        if opcode.op == 1
            src1, src2, target = mem[ptr+1:ptr+3]
            src1 = parse_arg(mem, src1, opcode.modes[1], relative_base)
            src2 = parse_arg(mem, src2, opcode.modes[2], relative_base)

            @assert opcode.modes[3] != 1
            target += (opcode.modes[3] == 2 ? relative_base : 0)
            mem[target] = src1 + src2
        elseif opcode.op == 2
            src1, src2, target = mem[ptr+1:ptr+3]
            src1 = parse_arg(mem, src1, opcode.modes[1], relative_base)
            src2 = parse_arg(mem, src2, opcode.modes[2], relative_base)

            @assert opcode.modes[3] != 1
            target += (opcode.modes[3] == 2 ? relative_base : 0)
            mem[target] = src1 * src2
        elseif opcode.op == 3
            target = mem[ptr+1]

            if auto
                value = inputs[input_ptr]
                input_ptr += 1
            else
                value = parse(Int, readline())
            end

            @assert opcode.modes[1] != 1
            target += (opcode.modes[1] == 2 ? relative_base : 0)
            mem[target] = value
        elseif opcode.op == 4
            src = mem[ptr+1]
            src = parse_arg(mem, src, opcode.modes[1], relative_base)

            if auto
                push!(outputs, src)
            else
                print(src)
            end
        elseif opcode.op == 5
            src, target = mem[ptr+1:ptr+2]
            src = parse_arg(mem, src, opcode.modes[1], relative_base)
            target = parse_arg(mem, target, opcode.modes[2], relative_base)

            if src != 0
                ptr = target
                continue
            end
        elseif opcode.op == 6
            src, target = mem[ptr+1:ptr+2]
            src = parse_arg(mem, src, opcode.modes[1], relative_base)
            target = parse_arg(mem, target, opcode.modes[2], relative_base)

            if src == 0
                ptr = target
                continue
            end
        elseif opcode.op == 7
            src1, src2, target = mem[ptr+1:ptr+3]
            src1 = parse_arg(mem, src1, opcode.modes[1], relative_base)
            src2 = parse_arg(mem, src2, opcode.modes[2], relative_base)

            @assert opcode.modes[3] != 1
            target += (opcode.modes[3] == 2 ? relative_base : 0)
            mem[target] = src1 < src2 ? 1 : 0
        elseif opcode.op == 8
            src1, src2, target = mem[ptr+1:ptr+3]
            src1 = parse_arg(mem, src1, opcode.modes[1], relative_base)
            src2 = parse_arg(mem, src2, opcode.modes[2], relative_base)

            @assert opcode.modes[3] != 1
            target += (opcode.modes[3] == 2 ? relative_base : 0)
            mem[target] = src1 == src2 ? 1 : 0
        elseif opcode.op == 9
            src = mem[ptr+1]
            src = parse_arg(mem, src, opcode.modes[1], relative_base)
            relative_base += src
        elseif opcode.op == 99
            break
        end

        ptr += OP_LEN[opcode.op]
    end

    return outputs
end

end
