function Base.searchsortedfirst(predicate::Function, a::AbstractUnitRange)
    lo, hi = first(a), last(a)
    while lo <= hi
        mid = div(lo + hi, 2)
        if predicate(mid)
            hi = mid - 1
        else
            lo = mid + 1
        end
    end
    return lo > last(a) ? nothing : lo
end

function Base.searchsortedlast(predicate::Function, a::AbstractUnitRange)
    lo, hi = first(a), last(a)
    while lo <= hi
        mid = div(lo + hi, 2)
        if predicate(mid)
            lo = mid + 1
        else
            hi = mid - 1
        end
    end
    return hi < first(a) ? nothing : hi
end
