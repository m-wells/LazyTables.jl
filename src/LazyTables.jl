module LazyTables

#===========================================================================================
export ...
===========================================================================================#
export LazyTable

#===========================================================================================
using ...: ...
===========================================================================================#
using PrettyTables: @crayon_str, ft_nonothing, pretty_table, tf_unicode_rounded
using StaticArrays: SVector

#===========================================================================================
import ...
===========================================================================================#
import Tables

#===========================================================================================
import ...: ...
===========================================================================================#
import TypedTables: Table

@inline table(x::Table) = x

"""
    data(x)

Retrieves the `data` field from an object that implements `table(x)`
"""
@inline data(x) = getfield(table(x), :data)
"""
    data(x, i)

Return the property `i` from `data(x)` where `i` can be an `Int` or a `Symbol`.
"""
@inline data(x, i) = getfield(data(x), i)

"""
    data(x, i, j)

Return the value at index `j` from property `i` of `data(x)`.
"""
@inline data(x, i, j) = data(x, i)[j...]

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
LazyTable
===========================================================================================#
struct LazyTable{T, N} <: AbstractArray{LazyRow{T, N}, N}
    table::T
end

"""
    LazyTable(table::TypedTables.Table)

Create a LazyTable from a Table.
"""
@inline LazyTable(table::Table{<:Any, N}) where N = LazyTable{typeof(table), N}(table)

"""
    LazyTable(args...; kwargs...)

Pass construction off to `TypedTables.Table` and then wrap it as a `LazyTable`.
"""
@inline LazyTable(args...; kwargs...) = LazyTable(Table(args...; kwargs...))

"""
    table(x::LazyTable)

Return the table that the `LazyTable` is referencing.
"""
@inline table(x::LazyTable) = getfield(x, :table)

#=------------------------------------------------------------------------------------------
LazyTable Base.methods
------------------------------------------------------------------------------------------=#
# indexing (Int)
@inline Base.getindex(x::LazyTable, i...) = LazyRow(x, i)
Base.setindex!(::LazyTable, _, _...) = error("""
    setindex! is intentionally not implemented for `LazyTable`
    Consider using element-wise broadcasting over properties, i.e., `x.a .= v`
    """
)

# indexing (Symbol)
@inline Base.getindex(x::LazyTable, s::Symbol) = data(x, s)

# properties
@inline Base.propertynames(x::LazyTable) = propertynames(data(x))
@inline Base.getproperty(x::LazyTable, s::Symbol) = x[s]

#===========================================================================================
Tables Interface
===========================================================================================#
@inline Tables.istable(::Type{<:LazyTable}) = true
@inline Tables.schema(x::LazyTable) = Tables.schema(data(x))
@inline Tables.materializer(::Type{<:LazyTable}) = LazyTable

# columns ----------------------------------------------------------------------------------
@inline Tables.columnaccess(::Type{<:LazyTable}) = true
@inline Tables.columnnames(x::LazyTable) = propertynames(x)
@inline Tables.columns(x::LazyTable) = x

@inline Tables.getcolumn(x::LazyTable, i::Int) = data(x, i)
@inline Tables.getcolumn(x::LazyTable, s::Symbol) = data(x, s)
@inline Tables.getcolumn(x::LazyTable, ::Type{T}, ::Int, s::Symbol) where {T} = data(x, s)

# rows -------------------------------------------------------------------------------------
@inline Tables.rowaccess(::Type{<:LazyTable}) = true
@inline Tables.rows(x::LazyTable) = x

#===========================================================================================
methods delegated to table
===========================================================================================#
@inline Base.getindex(x::LazyTable, i::AbstractVector) = LazyTable(view(table(x), i))
@inline Base.size(x::LazyTable) = size(table(x))
@inline Base.IndexStyle(x::LazyTable) = IndexStyle(table(x))

@inline Base.view(x::LazyTable, i) = LazyTable(view(table(x), i))

@inline Base.empty(x::LazyTable) = LazyTable(empty(table(x)))
@inline function Base.similar(x::LazyTable, ::Type{<:LazyRow{T}}, dims::Dims) where T
    LazyTable(similar(table(x), eltype(T), dims))
end
@inline Base.vcat(x::Vararg{LazyTable}) = LazyTable(mapreduce(table, vcat, x))
@inline Base.vcat(x::LazyTable) = x
@inline Base.hcat(x::Vararg{LazyTable}) = LazyTable(mapreduce(table, hcat, x))
@inline Base.hcat(x::LazyTable) = x

#===========================================================================================
additional files to include
===========================================================================================#
include("show.jl")

end
