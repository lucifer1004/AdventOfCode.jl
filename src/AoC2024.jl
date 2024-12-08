module AoC2024

for day in 1:8
    include(joinpath(@__DIR__, "..", "2024", "day$(lpad(day, 2, '0')).jl"))
end

end
