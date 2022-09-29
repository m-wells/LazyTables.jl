module LazyTables

export columnnames
export LazyTable
export LazyRow

import Tables
import Tables: columns
import TypedTables: Table

#===========================================================================================
Private
===========================================================================================#
@inline _index(lz) = Core.getfield(lz, :index)
@inline _table(lz) = Core.getfield(lz, :table)

#===========================================================================================
Constructors
===========================================================================================#
struct LazyRow{K} <: Tables.AbstractRow
    columns::K
    index::Int
end

struct LazyTable{K, N, V} <: AbstractArray{LazyRow{V}, N}
    table::Table{K, N, V}
    columns::V

    function LazyTable(table::Table{K, N, V}) where {K, N, V}
        return new{K, N, V}(table, columns(table))
    end
end

@inline LazyTable(args...; kwargs...) = LazyTable(Table(args...; kwargs...))
@inline Table(lz::LazyTable) = _table(lz)

#===========================================================================================
AbstractArray Interface
===========================================================================================#
# @inline Base.eltype(::Type{LazyTable{K}}) where K = LazyRow{K}
# @inline Base.iterate(lz::LazyTable, st=1) = st > length(lz) ? nothing : (lz[st], st+1)
@inline Base.getindex(lz::LazyTable, i::Int) = LazyRow(columns(lz), i)
@inline function Base.getindex(lz::LazyTable, i::AbstractVector{<:Integer})
    LazyTable(_table(lz)[i])
end

# offload to TypedTables
@inline Base.length(lz::LazyTable) = length(_table(lz))
@inline Base.size(lz::LazyTable) = size(_table(lz))
@inline Base.axes(lz::LazyTable) = axes(_table(lz))
@inline Base.IndexStyle(lz::LazyTable) = IndexStyle(_table(lz))

function Base.show(io::IO, ::MIME"text/plain", lz::LazyTable)
    print(io, "Lazy")
    show(io, MIME("text/plain"), _table(lz))
end

#===========================================================================================
Properties
===========================================================================================#
@inline Base.propertynames(::LazyTable{K}) where K = fieldnames(K)
@inline Base.propertynames(::LazyRow{K}) where K = fieldnames(K)
@inline Base.getproperty(table::LazyTable, s::Symbol) = getfield(columns(table), s)
@inline Base.getproperty(row::LazyRow, s::Symbol) = getfield(columns(row), s)[_index(row)]

#===========================================================================================
Tables Interface
===========================================================================================#
@inline Tables.istable(::Type{<:LazyTable}) = true
@inline Tables.rowaccess(::Type{<:LazyTable}) = true
@inline Tables.columnaccess(::Type{<:LazyTable}) = true
@inline Tables.schema(::LazyTable{T}) where {T} = Tables.Schema(T)
@inline Tables.materializer(::LazyTable) = Table
@inline Tables.columns(table::LazyTable) = Core.getfield(table, :columns)
@inline Tables.columnnames(::LazyTable{K}) where K = fieldnames(K)
@inline Tables.getcolumn(table::LazyTable, s::Symbol) = getproperty(table, s)

@inline Tables.columns(row::LazyRow) = Core.getfield(row, :columns)
@inline Tables.getcolumn(row::LazyRow, s::Symbol) = getproperty(row, s)
@inline Tables.columnnames(::LazyRow{K}) where K = fieldnames(K)
@inline Tables.rows(table::LazyTable) = table

end
