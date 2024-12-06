module AoC2024

for day in 1:6
    include(joinpath(@__DIR__, "..", "2024", "day$(lpad(day, 2, '0')).jl"))
end

end
