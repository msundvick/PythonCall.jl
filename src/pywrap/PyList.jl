"""
    PyList{T=Py}([x])

Wraps the Python list `x` (or anything satisfying the sequence interface) as an `AbstractVector{T}`.

If `x` is not a Python object, it is converted to one using `pylist`.
"""
struct PyList{T} <: AbstractVector{T}
    py :: Py
    PyList{T}(::Val{:new}, py::Py) where {T} = new{T}(py)
end
export PyList

PyList{T}(x=pylist()) where {T} = PyList{T}(Val(:new), ispy(x) ? Py(x) : pylist(x))
PyList(x=pylist()) = PyList{Py}(x)

ispy(::PyList) = true
getpy(x::PyList) = x.py
pydel!(x::PyList) = pydel!(x.py)

pyconvert_rule_sequence(::Type{T}, x::Py, ::Type{PyList{V}}=Utils._type_ub(T)) where {T<:PyList,V} =
    if PyList{Py} <: T
        pyconvert_return(PyList{Py}(x))
    else
        pyconvert_return(PyList{V}(x))
    end

Base.length(x::PyList) = Int(pylen(x))

Base.size(x::PyList) = (length(x),)

Base.@propagate_inbounds function Base.getindex(x::PyList{T}, i::Int) where {T}
    @boundscheck checkbounds(x, i)
    return pyconvert_and_del(T, @py x[@jl(i-1)])
end

Base.@propagate_inbounds function Base.setindex!(x::PyList{T}, v, i::Int) where {T}
    @boundscheck checkbounds(x, i)
    pysetitem(x, i-1, convert(T, v))
    return x
end

Base.@propagate_inbounds function Base.insert!(x::PyList{T}, i::Integer, v) where {T}
    @boundscheck (i==length(x)+1 || checkbounds(x, i))
    pydel!(@py x.insert(@jl(i-1), @jl(convert(T, v))))
    return x
end

function Base.push!(x::PyList{T}, v) where {T}
    pydel!(@py x.append(@jl(convert(T, v))))
    return x
end

function Base.pushfirst!(x::PyList, v)
    return @inbounds Base.insert!(x, 1, v)
end

function Base.append!(x::PyList, vs)
    for v in vs
        push!(x, v)
    end
    return x
end

function Base.push!(x::PyList, v1, v2, vs...)
    push!(x, v1)
    push!(x, v2, vs...)
end

Base.@propagate_inbounds function Base.pop!(x::PyList{T}) where {T}
    @boundscheck (isempty(x) && throw(BoundsError(x)))
    return pyconvert_and_del(T, @py x.pop())
end

Base.@propagate_inbounds function Base.popat!(x::PyList{T}, i::Integer) where {T}
    @boundscheck checkbounds(x, i)
    return pyconvert_and_del(T, @py x.pop(@jl(i-1)))
end

Base.@propagate_inbounds Base.popfirst!(x::PyList) = popat!(x, 1)

function Base.reverse!(x::PyList)
    pydel!(@py x.reverse())
    return x
end

function Base.empty!(x::PyList)
    pydel!(@py x.clear())
    return x
end

function Base.copy(x::PyList{T}) where {T}
    PyList{T}(Val(:new), @py x.copy())
end
