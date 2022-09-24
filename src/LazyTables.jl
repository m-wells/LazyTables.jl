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
struct LazyRow{K, V} <: Tables.AbstractRow
    columns::NamedTuple{K, V}
    index::Int
end

struct LazyTable{K, N, V} <: AbstractArray{LazyRow{K, V}, N}
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
@inline Base.getindex(lz::LazyTable, i::Int) = LazyRow(columns(lz), i)

# offload to TypedTables
@inline Base.size(lz::LazyTable) = size(_table(lz))
@inline Base.axes(lz::LazyTable) = axes(_table(lz))
@inline Base.IndexStyle(lz::LazyTable) = IndexStyle(_table(lz))

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

@inline Tables.columns(row::LazyRow) = Core.getfield(row, :columns)
@inline Tables.getcolumn(row::LazyRow, s::Symbol) = getproperty(row, s)
@inline Tables.columnnames(row::LazyRow) = fieldnames(typeof(columns(row)))
@inline Tables.rows(table::LazyTable) = table

end
