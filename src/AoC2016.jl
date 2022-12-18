module AoC2016

export Instruction, exec

mutable struct Instruction
    typ::Int
    arg1::Union{String,Int}
    arg2::Union{String,Int,Nothing}
end

function Instruction(line)
    if startswith(line, "cpy")
        num, target = string.(match(r"cpy (-?\w+) (\w+)", line).captures)
        if !('a' <= num[1] <= 'z')
            num = parse(Int, num)
        end
        Instruction(1, num, target)
    elseif startswith(line, "inc")
        target = string.(match(r"inc (\w+)", line).captures)[1]
        Instruction(2, target, nothing)
    elseif startswith(line, "dec")
        target = string.(match(r"dec (\w+)", line).captures)[1]
        Instruction(3, target, nothing)
    elseif startswith(line, "jnz")
        target, offset = string.(match(r"jnz (-?\w+) (-?\w+)", line).captures)
        if !('a' <= offset[1] <= 'z')
            offset = parse(Int, offset)
        end
        if !('a' <= target[1] <= 'z')
            target = parse(Int, target)
        end

        Instruction(4, target, offset)
    elseif startswith(line, "tgl")
        target = string.(match(r"tgl (\w+)", line).captures)[1]
        Instruction(5, target, nothing)
    elseif startswith(line, "out")
        target = string.(match(r"out (\w+)", line).captures)[1]
        Instruction(6, target, nothing)
    end
end

function exec(input, registers=Dict("a" => 0, "b" => 0, "c" => 0, "d" => 0); timeout=100000)
    instructions = Instruction.(input)
    i = 1
    t = 0
    output = Int[]
    while i <= length(input)
        t += 1
        if t > timeout
            break
        end
        ins = instructions[i]
        if ins.typ == 1 # "cpy"
            if isa(ins.arg2, String)
                registers[ins.arg2] = isa(ins.arg1, String) ? registers[ins.arg1] : ins.arg1
            end
        elseif ins.typ == 2 # "inc"
            registers[ins.arg1] += 1
        elseif ins.typ == 3 # "dec"
            registers[ins.arg1] -= 1
        elseif ins.typ == 4 # "jnz"
            target = isa(ins.arg1, String) ? registers[ins.arg1] : ins.arg1
            offset = isa(ins.arg2, String) ? registers[ins.arg2] : ins.arg2
            if target != 0
                i += offset
                continue
            end
        elseif ins.typ == 5 # "tgl"
            offset = registers[ins.arg1]
            if i + offset <= length(input)
                j = i + offset
                ins1 = instructions[j]
                if isnothing(ins1.arg2)
                    ins1.typ = ins1.typ == 2 ? 3 : 2
                else
                    ins1.typ = ins1.typ == 4 ? 1 : 4
                end
            end
        elseif ins.typ == 6 # "out"
            target = isa(ins.arg1, String) ? registers[ins.arg1] : ins.arg1
            push!(output, target)
        end
        i += 1
    end

    return registers, output
end

end
