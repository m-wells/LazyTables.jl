#=------------------------------------------------------------------------------------------
convert_index, needed for LazyRow
------------------------------------------------------------------------------------------=#
@inline convert_index(::Val{1}, _, i::Int) = (i,)
@inline convert_index(::Val{1}, axes, i::Tuple{Int}) = i
@inline convert_index(::Val{1}, axes, i::CartesianIndex) = (LinearIndices(axes)[i],)
@inline convert_index(::Val{1}, axes, i::Tuple) = (LinearIndices(axes)[i],)

@inline convert_index(::Val{N}, _, i::CartesianIndex{N}) where N = i.I
@inline convert_index(::Val{N}, _, i::NTuple{N, Int}) where N = i
@inline convert_index(::Val{N}, axes, i::Int) where N = (CartesianIndices(axes)[i]).I

#===========================================================================================
LazyRow
===========================================================================================#
"""
    LazyRow(table, index)

Create a `LazyRow` that stores a reference to `table` and the `index`.

This should only be called when indexing a `LazyTable`.
"""
struct LazyRow{T, N} <: Tables.AbstractRow
    table::T
    index::NTuple{N, Int}

    @inline function LazyRow(x, i)
        table = LazyTables.table(x)
        T = typeof(table)
        N = ndims(table)
        index = convert_index(Val(N), axes(table), i)
        return new{T, N}(table, index)
    end
end

#=------------------------------------------------------------------------------------------
getter functions
------------------------------------------------------------------------------------------=#
"""
    table(x::LazyRow)

Return the table that `x` is referencing.
"""
@inline table(x::LazyRow) = getfield(x, :table)

"""
    index(x::LazyRow)

Return the index that `LazyRow` is referencing.
"""
@inline index(x::LazyRow{<:Any, 1}) = only(getfield(x, :index))
@inline index(x::LazyRow) = getfield(x, :index)

#=------------------------------------------------------------------------------------------
LazyRow Base.methods
------------------------------------------------------------------------------------------=#
# indexing (Int)
@inline Base.getindex(x::LazyRow, i::Int) = data(x, i, index(x))
@inline Base.setindex!(x::LazyRow, v, i::Int) = setindex!(data(x, i), v, index(x))

# indexing (Symbol)
@inline Base.getindex(x::LazyRow, s::Symbol) = data(x, s, index(x))
@inline Base.setindex!(x::LazyRow, v, s::Symbol) = setindex!(data(x, s), v, index(x))

# properties
@inline Base.propertynames(x::LazyRow) = propertynames(data(x))
@inline Base.getproperty(x::LazyRow, s::Symbol) = x[s]
@inline Base.setproperty!(x::LazyRow, s::Symbol, v) = setindex!(x, v, s)

# Iteration
@inline Base.keys(x::LazyRow) = (k for k in propertynames(x))
@inline Base.values(x::LazyRow) = (x[k] for k in propertynames(x))
@inline Base.pairs(x::LazyRow) = (k => x[k] for k in propertynames(x))

# Using getindex for iteration (required because LazyRow is not subtyped as AbstractVector)
@inline function Base.iterate(x::LazyRow, i=1)
    props = propertynames(x)
    i > length(props) && return nothing
    return x[i], i+1
end
#=------------------------------------------------------------------------------------------
LazyRow Tables methods
------------------------------------------------------------------------------------------=#
@inline Tables.getcolumn(x::LazyRow, i::Int) = x[i]
@inline Tables.getcolumn(x::LazyRow, s::Symbol) = x[s]
@inline Tables.getcolumn(x::LazyRow, ::Type{T}, ::Int, s::Symbol) where {T} = x[s]
@inline Tables.columnnames(x::LazyRow) = propertynames(x)

#===========================================================================================
Base methods to make LazyRow behave like NamedTuples
===========================================================================================#
Base.merge(x::LazyRow, y::Any) = (; pairs(x)..., pairs(y)...)
Base.merge(x::NamedTuple, y::LazyRow) = Base.merge(x, pairs(y))
