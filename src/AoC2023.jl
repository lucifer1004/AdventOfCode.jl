module AoC2023

for day in 1:9
    include(joinpath(@__DIR__, "..", "2023", "day$(lpad(day, 2, '0')).jl"))
end

end
