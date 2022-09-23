module LazyTables

export LazyTable
export LazyRow
import Tables
import TypedTables: Table

#===========================================================================================
Private
===========================================================================================#
@inline _data(lz) = Core.getfield(lz, :data)
@inline _index(lz) = Core.getfield(lz, :index)
@inline _table(lz) = Core.getfield(lz, :table)

#===========================================================================================
Constructors
===========================================================================================#
struct LazyRow{K, V}
    data::NamedTuple{K, V}
    index::Int
end

struct LazyTable{K, N, V} <: AbstractArray{LazyRow{K, V}, N}
    table::Table{K, N, V}
    data::V
    function LazyTable(table::Table{K, N, V}) where {K, N, V}
        return new{K, N, V}(table, _data(table))
    end
end

@inline LazyTable(args...; kwargs...) = LazyTable(Table(args...; kwargs...))

Table(lz::LazyTable) = _table(lz)

#===========================================================================================
Tables Interface
===========================================================================================#
Tables.istable(::Type{<:LazyTable}) = true
Tables.rowaccess(::Type{<:LazyTable}) = true
Tables.columnaccess(::Type{<:LazyTable}) = true
Tables.schema(::LazyTable{T}) where {T} = Tables.Schema(T)
Tables.materializer(::LazyTable) = Table

"""
    columns(table::LazyTable)
Convert a `LazyTable` into a `NamedTuple` of its columns.
"""
@inline Tables.columns(t::LazyTable) = _data(t)
@inline Tables.rows(t::LazyTable) = t

#===========================================================================================
AbstractArray Interface
===========================================================================================#
@inline Base.getindex(lz::LazyTable, i::Int) = LazyRow(_data(lz), i)

# offload to TypedTables
@inline Base.size(lz::LazyTable) = size(_table(lz))
@inline Base.axes(lz::LazyTable) = axes(_table(lz))
@inline Base.IndexStyle(lz::LazyTable) = IndexStyle(_table(lz))

#===========================================================================================
Properties
===========================================================================================#
Base.propertynames(::LazyTable{K}) where K = fieldnames(K)
Base.propertynames(::LazyRow{K}) where K = fieldnames(K)
Base.getproperty(lz::LazyTable, s::Symbol) = getfield(_data(lz), s)
Base.getproperty(lz::LazyRow, s::Symbol) = getfield(_data(lz), s)[_index(lz)]

#===========================================================================================
Base.show
===========================================================================================#
function Base.show(io::IO, m::MIME"text/plain", lz::LazyRow)
    show(io::IO, m, _table(lz)[_index(lz)])
end

function Base.show(io::IO, m::MIME"text/plain", lz::LazyTable)
    print(io, "Lazy")
    show(io::IO, m, _table(lz))
end

end
