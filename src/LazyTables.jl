module LazyTables

export LazyTable
import TypedTables

#===========================================================================================
Private
===========================================================================================#
_data(lz) = getfield(lz, :data)
_index(lz) = getfield(lz, :index)
_table(lz) = getfield(lz, :table)

#===========================================================================================
Constructors
===========================================================================================#
const Table{K, V} = TypedTables.Table{K, 1, V}

struct LazyRow{K, V}
    data::NamedTuple{K, V}
    index::Int
end

struct LazyTable{K, V} <: AbstractVector{LazyRow{K, V}}
    table::Table{K, V}
    data::V
    function LazyTable(table::Table{K, V}) where {K, V}
        return new{K, V}(table, _data(table))
    end
end

LazyTable(args...; kwargs...) = LazyTable(TypedTables.Table(args...; kwargs...))

#===========================================================================================
AbstractArray Interface
===========================================================================================#
Base.size(lz::LazyTable) = size(_table(lz))
Base.getindex(lz::LazyTable, i::Int) = LazyRow(_data(lz), i)
Base.IndexStyle(::Type{<:LazyTable}) = IndexLinear()

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
