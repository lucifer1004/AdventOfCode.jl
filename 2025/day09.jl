module Day09

using ...AdventOfCode
using ..AoC2025
import GeometryOps as GO
import GeoInterface as GI

const YEAR = parse(Int, splitdir(@__DIR__)[end])
const DAY = parse(Int, match(r"day(\d+).jl", basename(@__FILE__))[1])

function parse_points(input)
    lines = isa(input, AbstractString) ? split(input, '\n') : input
    [Tuple(parse.(Int, split(line, ","))) for line in lines]
end

# Part One: Maximum rectangle area (cell count) between any two points
function part_one(input)
    points = parse_points(input)
    maximum((abs(p[1] - q[1]) + 1) * (abs(p[2] - q[2]) + 1) for p in points, q in points)
end

#=
## Part Two: GeometryOps version

Uses GeometryOps.within with epsilon-inset rectangle for strict interior check.
=#
function part_two(input)
    points = parse_points(input)
    n = length(points)

    # Build polygon from points
    poly_coords = [(Float64(p[1]), Float64(p[2])) for p in points]
    push!(poly_coords, poly_coords[1])  # Close polygon
    poly = GI.Polygon([poly_coords])

    max_area = 0
    eps = 1e-9  # Epsilon inset for strict interior check

    for i in 1:n, j in i+1:n
        p, q = points[i], points[j]
        xlo, xhi = minmax(p[1], q[1])
        ylo, yhi = minmax(p[2], q[2])

        # Skip degenerate rectangles
        (xlo == xhi || ylo == yhi) && continue

        # Build rectangle with epsilon inset (strict interior)
        rect_coords = [
            (Float64(xlo) + eps, Float64(ylo) + eps),
            (Float64(xhi) - eps, Float64(ylo) + eps),
            (Float64(xhi) - eps, Float64(yhi) - eps),
            (Float64(xlo) + eps, Float64(yhi) - eps),
            (Float64(xlo) + eps, Float64(ylo) + eps),
        ]
        rect = GI.Polygon([rect_coords])

        # Check if rectangle is strictly inside polygon
        if GO.within(rect, poly)
            area = (xhi - xlo + 1) * (yhi - ylo + 1)  # Cell count
            max_area = max(max_area, area)
        end
    end

    max_area
end

#=
## Part Two: No geometry library version

Algorithm correctness (R ⊆ P ⟺ conditions):
1. All 4 corners of R are inside P (including boundary)
2. No edge of R properly intersects any edge of P

Proof sketch:
- Necessity: obvious
- Sufficiency: R is convex (rectangle), so any point x ∈ R can be connected
  to a corner c ∈ P by a line segment entirely within R. Since this segment
  doesn't cross ∂P (by condition 2), x and c are on the same side of ∂P
  (Jordan curve theorem), hence x ∈ P.
=#

# Ray casting: point inside polygon (including boundary)
function point_in_polygon(px, py, poly)
    n = length(poly)
    inside = false
    j = n
    @inbounds for i in 1:n
        xi, yi = Float64(poly[i][1]), Float64(poly[i][2])
        xj, yj = Float64(poly[j][1]), Float64(poly[j][2])

        # Point on edge?
        cross = (px - xi) * (yj - yi) - (py - yi) * (xj - xi)
        if abs(cross) < 1e-9 && min(xi, xj) <= px <= max(xi, xj) &&
           min(yi, yj) <= py <= max(yi, yj)
            return true
        end

        # Ray crossing
        if ((yi > py) != (yj > py)) && (px < (xj - xi) * (py - yi) / (yj - yi) + xi)
            inside = !inside
        end
        j = i
    end
    inside
end

# Cross product sign for orientation
@inline ccw(px, py, qx, qy, rx, ry) = (qx - px) * (ry - py) - (qy - py) * (rx - px)

# Two segments properly intersect (endpoints don't count)
function segments_cross(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2)
    d1 = ccw(ax1, ay1, ax2, ay2, bx1, by1)
    d2 = ccw(ax1, ay1, ax2, ay2, bx2, by2)
    d3 = ccw(bx1, by1, bx2, by2, ax1, ay1)
    d4 = ccw(bx1, by1, bx2, by2, ax2, ay2)
    sign(d1) * sign(d2) < 0 && sign(d3) * sign(d4) < 0
end

# Rectangle completely inside polygon
function rect_inside_polygon(xlo, ylo, xhi, yhi, poly)
    # Condition 1: all 4 corners inside polygon
    for (x, y) in ((xlo, ylo), (xhi, ylo), (xhi, yhi), (xlo, yhi))
        point_in_polygon(Float64(x), Float64(y), poly) || return false
    end

    # Condition 2: no edge of rectangle properly intersects polygon edges
    rect_edges = (
        (xlo, ylo, xhi, ylo),
        (xhi, ylo, xhi, yhi),
        (xhi, yhi, xlo, yhi),
        (xlo, yhi, xlo, ylo),
    )
    n = length(poly)
    @inbounds for (x1, y1, x2, y2) in rect_edges
        for i in 1:n
            j = mod1(i + 1, n)
            px1, py1 = Float64(poly[i][1]), Float64(poly[i][2])
            px2, py2 = Float64(poly[j][1]), Float64(poly[j][2])
            if segments_cross(Float64(x1), Float64(y1), Float64(x2), Float64(y2),
                px1, py1, px2, py2)
                return false
            end
        end
    end
    true
end

function part_two_no_geo(input)
    points = parse_points(input)
    n = length(points)

    max_area = 0
    for i in 1:n, j in i+1:n
        p, q = points[i], points[j]
        xlo, xhi = minmax(p[1], q[1])
        ylo, yhi = minmax(p[2], q[2])

        (xlo == xhi || ylo == yhi) && continue

        if rect_inside_polygon(xlo, ylo, xhi, yhi, points)
            area = (xhi - xlo + 1) * (yhi - ylo + 1)
            max_area = max(max_area, area)
        end
    end
    max_area
end

@testitem "Day09" begin
    using AdventOfCode: get_input
    using AdventOfCode.AoC2025.Day09: part_one, part_two, part_two_no_geo, YEAR, DAY
    input = get_input(YEAR, DAY)

    sample = """7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"""

    @testset "Part One" begin
        @test part_one(sample) == 50
        @test part_one(input) == 4758121828
    end

    @testset "Part Two (GeometryOps)" begin
        @test part_two(sample) == 24
        @test part_two(input) == 1577956170
    end

    @testset "Part Two (No Geo)" begin
        @test part_two_no_geo(sample) == 24
        @test part_two_no_geo(input) == 1577956170
    end
end

end
