export SparseTable, SparseTable2D, query

struct SparseTable{T, F}
    a::Matrix{T}
    op::F
end

function SparseTable(arr, op)
    n = length(arr)
    T = eltype(arr)
    m = ceil(Int, log2(n + 1))
    a = zeros(T, n, m)
    for i in 1:n
        a[i, 1] = arr[i]
    end
    for j in 2:m
        for i in 1:n
            a[i, j] = op(a[i, j - 1], a[min(i + 2^(j - 2), n), j - 1])
        end
    end
    return SparseTable(a, op)
end

function query(st::SparseTable, l::Int, r::Int)
    j = max(1, ceil(Int, log2(r - l + 1)))
    return st.op(st.a[l, j], st.a[r - 2 ^ (j - 1) + 1, j])
end

struct SparseTable2D{T, F}
    a::Array{T, 4}
    op::F
end

function SparseTable2D(mat, op)
    n, m = size(mat)
    T = eltype(mat)
    k = ceil(Int, log2(n + 1))
    l = ceil(Int, log2(m + 1))
    a = zeros(T, n, m, k, l)

    for i in 1:n, j in 1:m

        a[i, j, 1, 1] = mat[i, j]
    end

    for p in 2:k
        for i in 1:n, j in 1:m

            a[i, j, p, 1] = op(a[i, j, p - 1, 1], a[min(i + 2^(p - 2), n), j, p - 1, 1])
        end
    end

    for q in 2:l
        for i in 1:n, j in 1:m

            a[i, j, 1, q] = op(a[i, j, 1, q - 1], a[i, min(j + 2^(q - 2), m), 1, q - 1])
        end
    end

    for q in 2:l
        for p in 2:k
            for i in 1:n, j in 1:m

                a[i, j, p, q] = op(a[i, j, p, q - 1], a[i, min(j + 2^(q - 2), m), p, q - 1])
            end
        end
    end

    return SparseTable2D(a, op)
end

function query(st::SparseTable2D, l1::Int, r1::Int, l2::Int, r2::Int)
    p = max(1, ceil(Int, log2(r1 - l1 + 1)))
    q = max(1, ceil(Int, log2(r2 - l2 + 1)))
    return st.op(st.op(st.a[l1, l2, p, q], st.a[r1 - 2 ^ (p - 1) + 1, l2, p, q]),
        st.op(st.a[l1, r2 - 2 ^ (q - 1) + 1, p, q],
            st.a[r1 - 2 ^ (p - 1) + 1, r2 - 2 ^ (q - 1) + 1, p, q]))
end
