# LazyTables.jl

*All the good of `TypedTables.jl` but FASTER and without as many allocations!*

A `LazyTable` is basically a [`TypedTables.Table`](https://github.com/JuliaData/TypedTables.jl#typedtablesjl) but better.
At worst, a `LazyTable` will perform just as well as a `Table`.
But at its best it can be hundreds of times faster with no allocations.
Here are some [benchmarks which you can run for yourself](`test/bench.jl`).

## Benchmarks
All benchmarks are performed using the same data for each table.
The tables have 1000 rows and 52 columns (column names are `:A` to `:Z` and `:a` to `:z`) where each column is a `Vector`.
```julia
# LazyTable is 68.64 times FASTER than TypedTables.Table
# LazyTable used 100.00% LESS memory than TypedTables.Table
# LazyTable made 100.00% FEWER allocations than TypedTables.Table

julia> @benchmark values($lazytab[i]) setup=(i=rand(1:1000))
BenchmarkTools.Trial: 10000 samples with 961 evaluations.
 Range (min … max):  86.613 ns … 115.137 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     86.665 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   87.101 ns ±   1.653 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%
 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark values($typetab[i]) setup=(i=rand(1:1000))
BenchmarkTools.Trial: 10000 samples with 6 evaluations.
 Range (min … max):  5.437 μs … 142.746 μs  ┊ GC (min … max): 0.00% … 93.06%
 Time  (median):     5.686 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   5.979 μs ±   3.144 μs  ┊ GC (mean ± σ):  1.24% ±  2.29%
 Memory estimate: 4.78 KiB, allocs estimate: 126.
```
---
```julia
# LazyTable is 47.10 times FASTER than TypedTables.Table
# LazyTable used 100.00% LESS memory than TypedTables.Table
# LazyTable made 100.00% FEWER allocations than TypedTables.Table

julia> @benchmark pairs($lazytab[i]) setup=(i=rand(1:1000))
BenchmarkTools.Trial: 10000 samples with 961 evaluations.
 Range (min … max):  86.620 ns … 113.056 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     86.674 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   87.068 ns ±   1.517 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark pairs($typetab[i]) setup=(i=rand(1:1000))
BenchmarkTools.Trial: 10000 samples with 8 evaluations.
 Range (min … max):  3.729 μs … 129.913 μs  ┊ GC (min … max): 0.00% … 94.93%
 Time  (median):     3.872 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   4.101 μs ±   2.678 μs  ┊ GC (mean ± σ):  1.41% ±  2.12%

 Memory estimate: 3.48 KiB, allocs estimate: 91.
```
---
```julia
# LazyTable is 87.58 times FASTER than TypedTables.Table
# LazyTable used 100.00% LESS memory than TypedTables.Table
# LazyTable made 100.00% FEWER allocations than TypedTables.Table

julia> f(x) = Iterators.map(x -> x.a, x)

julia> @benchmark f($lazytab[i]) setup=(i=rand(1:1000))
BenchmarkTools.Trial: 10000 samples with 988 evaluations.
 Range (min … max):  46.230 ns … 66.602 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     46.272 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   46.568 ns ±  1.127 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark f($typetab[i]) setup=(i=rand(1:1000))
BenchmarkTools.Trial: 10000 samples with 8 evaluations.
 Range (min … max):  3.725 μs … 120.630 μs  ┊ GC (min … max): 0.00% … 95.06%
 Time  (median):     3.847 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   4.078 μs ±   2.568 μs  ┊ GC (mean ± σ):  1.36% ±  2.12%

 Memory estimate: 3.48 KiB, allocs estimate: 91.
```
---
```julia
# LazyTable is 89.21 times FASTER than TypedTables.Table
# LazyTable used 100.00% LESS memory than TypedTables.Table
# LazyTable made 100.00% FEWER allocations than TypedTables.Table

julia> f(x) = x[500]

julia> @benchmark f($lazytab)
BenchmarkTools.Trial: 10000 samples with 988 evaluations.
 Range (min … max):  45.949 ns … 67.608 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     46.002 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   46.240 ns ±  0.993 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark f($typetab)
BenchmarkTools.Trial: 10000 samples with 8 evaluations.
 Range (min … max):  3.746 μs … 124.082 μs  ┊ GC (min … max): 0.00% … 94.28%
 Time  (median):     3.910 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   4.125 μs ±   2.650 μs  ┊ GC (mean ± σ):  1.40% ±  2.13%

 Memory estimate: 3.48 KiB, allocs estimate: 91.
```
---
```julia
# LazyTable is 1.70 times FASTER than TypedTables.Table
# LazyTable used 94.69% LESS memory than TypedTables.Table
# LazyTable made 62.83% FEWER allocations than TypedTables.Table

julia> f(x) = sum(x[500])

julia> @benchmark f($lazytab)
BenchmarkTools.Trial: 10000 samples with 6 evaluations.
 Range (min … max):  5.034 μs … 199.959 μs  ┊ GC (min … max): 0.00% … 95.24%
 Time  (median):     5.466 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   5.402 μs ±   1.964 μs  ┊ GC (mean ± σ):  0.35% ±  0.95%

 Memory estimate: 1.31 KiB, allocs estimate: 84.

julia> @benchmark f($typetab)
BenchmarkTools.Trial: 10000 samples with 3 evaluations.
 Range (min … max):  7.946 μs … 363.028 μs  ┊ GC (min … max): 0.00% … 94.70%
 Time  (median):     8.261 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   9.206 μs ±  12.401 μs  ┊ GC (mean ± σ):  5.08% ±  3.71%

 Memory estimate: 24.72 KiB, allocs estimate: 226.
```
---
```julia
# this is a draw

julia> f(x) = filter(<(0.5), x.z)

julia> @benchmark f($lazytab)
BenchmarkTools.Trial: 10000 samples with 10 evaluations.
 Range (min … max):  1.019 μs … 91.588 μs  ┊ GC (min … max): 0.00% … 97.02%
 Time  (median):     1.056 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.188 μs ±  1.237 μs  ┊ GC (mean ± σ):  1.44% ±  1.38%

 Memory estimate: 1.06 KiB, allocs estimate: 1.

julia> @benchmark f($typetab)
BenchmarkTools.Trial: 10000 samples with 10 evaluations.
 Range (min … max):  1.017 μs … 90.782 μs  ┊ GC (min … max): 0.00% … 96.64%
 Time  (median):     1.055 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.195 μs ±  1.277 μs  ┊ GC (mean ± σ):  1.47% ±  1.37%

 Memory estimate: 1.06 KiB, allocs estimate: 1.
```
---
```julia
# LazyTable is 245.80 times FASTER than TypedTables.Table
# LazyTable used 99.46% LESS memory than TypedTables.Table
# LazyTable made 99.88% FEWER allocations than TypedTables.Table

julia> f(x) = filter(x -> x.z < 0.5, x)

julia> @benchmark f($lazytab)
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  13.791 μs …  1.433 ms  ┊ GC (min … max): 0.00% … 97.16%
 Time  (median):     14.262 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   15.707 μs ± 25.517 μs  ┊ GC (mean ± σ):  3.18% ±  1.95%

 Memory estimate: 19.62 KiB, allocs estimate: 113.

julia> @benchmark f($typetab)
BenchmarkTools.Trial: 1294 samples with 1 evaluation.
 Range (min … max):  3.677 ms …   6.025 ms  ┊ GC (min … max): 0.00% … 23.36%
 Time  (median):     3.743 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):   3.861 ms ± 340.557 μs  ┊ GC (mean ± σ):  2.11% ±  5.71%

 Memory estimate: 3.57 MiB, allocs estimate: 91112.
```
---
```julia
# this is a draw

julia> f(x) = Iterators.filter(x -> x.z < 0.5, x)

julia> @benchmark f($lazytab)
BenchmarkTools.Trial: 10000 samples with 1000 evaluations.
 Range (min … max):  5.858 ns … 22.717 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     5.903 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   6.026 ns ±  0.303 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark f($typetab)
BenchmarkTools.Trial: 10000 samples with 1000 evaluations.
 Range (min … max):  5.863 ns … 21.733 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     5.888 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   6.005 ns ±  0.359 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

 Memory estimate: 0 bytes, allocs estimate: 0.
```
---
```julia
# this is a draw

julia> f(x) = vcat(x, x)

julia> @benchmark f($lazytab)
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  45.199 μs …  1.421 ms  ┊ GC (min … max):  0.00% … 91.16%
 Time  (median):     58.151 μs              ┊ GC (median):     0.00%
 Time  (mean ± σ):   72.780 μs ± 98.033 μs  ┊ GC (mean ± σ):  14.86% ± 10.44%

 Memory estimate: 619.73 KiB, allocs estimate: 61.

julia> @benchmark f($typetab)
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  49.442 μs …  1.421 ms  ┊ GC (min … max):  0.00% … 88.79%
 Time  (median):     58.011 μs              ┊ GC (median):     0.00%
 Time  (mean ± σ):   70.518 μs ± 93.531 μs  ┊ GC (mean ± σ):  14.89% ± 10.42%

 Memory estimate: 619.30 KiB, allocs estimate: 60.
```

## Usage
Full integration with the [`Tables.jl`](https://github.com/JuliaData/Tables.jl#tablesjl) interface.

Should function as a drop in replacement for `TypedTables.Table`.

A `LazyTable` actually uses `Table` as its store and can be constructed the same way.
```julia
julia> using LazyTables

julia> lazytable = LazyTable(x = rand(10), y = rand(10))
LazyTable with 2 columns with 10 rows:
╭─────┬───────────┬───────────╮
│ row │     x     │     y     │
├─────┼───────────┼───────────┤
│   1 │ 0.26997   │ 0.662442  │
│   2 │ 0.315106  │ 0.745717  │
│   3 │ 0.700736  │ 0.499348  │
│   4 │ 0.531262  │ 0.387146  │
│   5 │ 0.961951  │ 0.531365  │
│   6 │ 0.22444   │ 0.498552  │
│   7 │ 0.0450473 │ 0.648617  │
│   8 │ 0.182706  │ 0.0796079 │
│   9 │ 0.216163  │ 0.437709  │
│  10 │ 0.929186  │ 0.899007  │
╰─────┴───────────┴───────────╯

julia> lazytable[1]
(x = 0.26997004281231074, y = 0.6624416805539212)

julia> lazytable[1].x
0.26997004281231074
```

## Differences from `TypedTables.Table`
`LazyTable` does not return a `NamedTuple`.
Instead it returns a `LazyRow` which should act and feel just like a `NamedTuple` (for the most part).

### `LazyRow`
```julia
julia> using TypedTables: Table

julia> typetable = lazytable |> Table;

julia> lt1 = lazytable[1]
(x = 0.26997004281231074, y = 0.6624416805539212)

julia> tt1 = typetable[1]
(x = 0.26997004281231074, y = 0.6624416805539212)

julia> lt1[:x]
0.26997004281231074

julia> tt1[:x]
0.26997004281231074
```

However, you can assign values through a `LazyRow` into the `LazyTable` which isn't possible with `Table`.
```julia
julia> lt1.x = 10
10

julia> tt1.x = 10
ERROR: setfield!: immutable struct of type NamedTuple cannot be changed

julia> lt1
(x = 10.0, y = 0.6624416805539212)

julia> tt1
(x = 0.26997004281231074, y = 0.6624416805539212)
```

### Indexing
To make indexing consistent between rows and tables, columns of the `LazyTable` can be accessed via the property interface or the dictionary like index interface
```julia
julia> lazytable.x === lazytable[:x]
true

julia> typetable[:x]
ERROR: ArgumentError: invalid index: :x of type Symbol
```

Just like `Table`, multidimensional columns are supported

```julia
julia> lazymatrixtable = hcat(lazytable, lazytable)
LazyTable with 2 columns with 20 rows:
╭─────┬───────┬───────────┬───────────╮
│ row │ index │     x     │     y     │
├─────┼───────┼───────────┼───────────┤
│   1 │  1, 1 │ 10.0      │ 0.662442  │
│   2 │  2, 1 │ 0.315106  │ 0.745717  │
│   3 │  3, 1 │ 0.700736  │ 0.499348  │
│   4 │  4, 1 │ 0.531262  │ 0.387146  │
│   5 │  5, 1 │ 0.961951  │ 0.531365  │
│   6 │  6, 1 │ 0.22444   │ 0.498552  │
│   7 │  7, 1 │ 0.0450473 │ 0.648617  │
│   8 │  8, 1 │ 0.182706  │ 0.0796079 │
│   9 │  9, 1 │ 0.216163  │ 0.437709  │
│  10 │ 10, 1 │ 0.929186  │ 0.899007  │
│  11 │  1, 2 │ 10.0      │ 0.662442  │
│  12 │  2, 2 │ 0.315106  │ 0.745717  │
│  13 │  3, 2 │ 0.700736  │ 0.499348  │
│  14 │  4, 2 │ 0.531262  │ 0.387146  │
│  15 │  5, 2 │ 0.961951  │ 0.531365  │
│  16 │  6, 2 │ 0.22444   │ 0.498552  │
│  17 │  7, 2 │ 0.0450473 │ 0.648617  │
│  18 │  8, 2 │ 0.182706  │ 0.0796079 │
│  19 │  9, 2 │ 0.216163  │ 0.437709  │
│  20 │ 10, 2 │ 0.929186  │ 0.899007  │
╰─────┴───────┴───────────┴───────────╯

julia> lazymatrixtable[5,2]
(0.9619514860009788, 0.5313645724703538)
```

Although `Table` errors when showing `Array` columns.
```
julia> typematrixtable = lazymatrixtable |> Table;

julia> lazymatrixtable[5,2]
(0.9619514860009788, 0.5313645724703538)

julia> typematrixtable
Table with 2 columns and 10×2 rowsError showing value of type Table{NamedTuple{(:x, :y), Tuple{Float64, Float64}}, 2, NamedTuple{(:x, :y), Tuple{Matrix{Float64}, Matrix{Float64}}}}:
ERROR: MethodError: no method matching isassigned(::Matrix{Float64}, ::CartesianIndex{2})
```
