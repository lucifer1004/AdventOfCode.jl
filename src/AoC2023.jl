module AoC2023

for file in readdir(joinpath(@__DIR__, "..", "2023"))
    if endswith(file, ".jl")
        include(joinpath(@__DIR__, "..", "2023", file))
    end
end

end
