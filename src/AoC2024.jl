module AoC2024

for day in 1:13
    filename = joinpath(@__DIR__, "..", "2024", "day$(lpad(day, 2, '0')).jl")
    include(filename)
end

for day in 16:22
    filename = joinpath(@__DIR__, "..", "2024", "day$(lpad(day, 2, '0')).jl")
    include(filename)
end

end
