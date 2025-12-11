module AoC2025

for day in 1:11
    filename = joinpath(@__DIR__, "..", "2025", "day$(lpad(day, 2, '0')).jl")
    include(filename)
end

end
