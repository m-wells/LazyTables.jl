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

include("LazyRow.jl")
include("LazyTable.jl")
include("show.jl")

end
