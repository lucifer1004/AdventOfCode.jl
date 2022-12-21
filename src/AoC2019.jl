module AoC2019

using ..AdventOfCode

export IntCodeMachine, exec!, ishalted

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

mutable struct IntCodeMachine
    mem::Vector{Int}
    inputs::Vector{Int}
    outputs::Vector{Int}
    ptr::Int
    input_ptr::Int
    relative_base::Int
    auto::Bool
    halted::Bool
end

ishalted(machine::IntCodeMachine) = machine.halted

function IntCodeMachine(mem::AbstractVector{Int}; inputs::AbstractVector{Int}=Int[], auto=true, maximum_size=100000)
    n = length(mem)
    append!(mem, zeros(Int, maximum_size - n))
    ptr = 0
    input_ptr = 1
    relative_base = 0
    outputs = Int[]
    return IntCodeMachine(mem, inputs, outputs, ptr, input_ptr, relative_base, auto, false)
end

function exec!(mem::AbstractVector{Int}; inputs::AbstractVector{Int}=Int[], auto=true, maximum_size=100000)
    machine = IntCodeMachine(mem::AbstractVector{Int}; inputs=inputs, auto=auto, maximum_size=maximum_size)
    exec!(machine)
    return machine.outputs
end

function exec!(machine::IntCodeMachine)
    if ishalted(machine)
        return
    end

    n = length(machine.mem)
    mem = OffsetArray(machine.mem, 0:n-1)
    ptr = machine.ptr
    inputs = machine.inputs
    input_ptr = machine.input_ptr
    relative_base = machine.relative_base
    outputs = machine.outputs
    auto = machine.auto

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

            if input_ptr > length(inputs)
                if !auto
                    s = readline(; keep=true)
                    append!(inputs, Int.(collect(s)))
                else
                    # Need more input! Snapshot and break!
                    break
                end
            end

            @assert input_ptr <= length(inputs)
            value = inputs[input_ptr]
            input_ptr += 1

            @assert opcode.modes[1] != 1
            target += (opcode.modes[1] == 2 ? relative_base : 0)
            mem[target] = value
        elseif opcode.op == 4
            src = mem[ptr+1]
            src = parse_arg(mem, src, opcode.modes[1], relative_base)

            push!(outputs, src)
            if !auto
                if 10 <= src <= 127
                    print(Char(src))
                else
                    println("\n", src)
                end
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
            machine.halted = true
            break
        end

        ptr += OP_LEN[opcode.op]
    end

    machine.ptr = ptr
    machine.input_ptr = input_ptr
    machine.relative_base = relative_base

    return nothing
end

end
