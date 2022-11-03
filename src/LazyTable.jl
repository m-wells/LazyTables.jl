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
@inline function Tables.subset(x::LazyTable, inds::AbstractVector; viewhint = nothing)
    if isnothing(viewhint) || viewhint
        return view(x, inds)
    else
        return LazyTable(table(x)[inds])
    end
end
@inline function Tables.subset(x::LazyTable, i; viewhint = nothing)
    if isnothing(viewhint) || viewhint
        return x[i]
    else
        return table(x)[inds]
    end
end

#===========================================================================================
other Base methods
===========================================================================================#
@inline function Base.merge(x::LazyTable, y::LazyTable)
    size(x) === size(y) || throw(DimensionMismatch(string(
        "LazyTable of size ",
        size(x),
        " is incompatible with a LazyTable of size ",
        size(y),
    )))
    return LazyTable(merge(data(x), data(y)))
end

#===========================================================================================
methods delegated to table
===========================================================================================#
@inline Base.getindex(x::LazyTable, i::AbstractVector) = LazyTable(view(table(x), i))
@inline Base.size(x::LazyTable) = size(table(x))
@inline Base.IndexStyle(x::LazyTable) = IndexStyle(table(x))

@inline Base.deleteat!(x::LazyTable, i) = deleteat!(table(x), i)

@inline Base.view(x::LazyTable, i) = LazyTable(view(table(x), i))

@inline Base.empty(x::LazyTable) = LazyTable(empty(table(x)))
@inline function Base.similar(x::LazyTable, ::Type{<:LazyRow{T}}, dims::Dims) where T
    LazyTable(similar(table(x), eltype(T), dims))
end
@inline Base.vcat(x::Vararg{LazyTable}) = LazyTable(mapreduce(table, vcat, x))
@inline Base.vcat(x::LazyTable) = x
@inline Base.hcat(x::Vararg{LazyTable}) = LazyTable(mapreduce(table, hcat, x))
@inline Base.hcat(x::LazyTable) = x


