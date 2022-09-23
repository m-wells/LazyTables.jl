# LazyTables

Exports `LazyTable` and `LazyRow`.
A simple wrapper around a `TypedTables.Table` that avoids allocation when iterating over rows.
Can be constructed just like a `TypedTables.Table` (or can be called on a `TypedTables.Table` directly).
A `LazyTable` returns a `LazyRow`.
This should function as a drop in replacement for any `TypedTables.Table`.

## Examples

## Benchmark
Use `KeplerLC`.

```
julia> using Kepler, KEBS

julia> kebc = KEBC(); lc = KeplerLC(kebc[1]);

julia> lz = getfield(lc, :table)
LazyTable with 41 columns and 69302 rows:
	...

julia> tt = getfield(lz, :table);
Table with 41 columns and 69302 rows:
	...

julia> f(x) = x.bkg[10]
f (generic function with 1 method)

julia> g(x) = x[10].bkg
g (generic function with 1 method)

julia> f(tt); @time f(tt)
  0.000004 seconds (1 allocation: 16 bytes)
0.06335759f0

julia> g(tt); @time g(tt)
  0.000042 seconds (244 allocations: 86.625 KiB)
0.06335759f0

julia> f(lz); @time f(lz)
  0.000005 seconds (1 allocation: 16 bytes)
0.06335759f0

julia> g(lz); @time g(lz)
  0.000004 seconds (1 allocation: 16 bytes)
0.06335759f0
```
