using BenchmarkTools
using LazyTables: LazyTable
using TypedTables: Table
using Printf: @printf

#===========================================================================================
setup tables
52 columns by 1000 rows
===========================================================================================#
get_rand(i) = if i == 1
    rand(0:9, 1000)
elseif i == 3
    rand(Bool, 1000)
elseif i == 4
    rand(Float32, 1000)
else
    rand(1000)
end
get_rand(::Symbol) = get_rand(rand(1:5))
K = (
    ntuple(Val(26)) do i
        # 'A' is Char(65), 'Z' is Char(90)
        Symbol(Char(64+i))
    end...,
    ntuple(Val(26)) do i
        # 'a' is Char(97), 'z' is Char(122)
        Symbol(Char(96+i))
    end...,
)
V = map(get_rand, K)
typetab = Table(NamedTuple{K}(V))
lazytab = LazyTable(typetab)

#===========================================================================================

===========================================================================================#
# prepend julia> so it looks like the repr
function julia(io::IO, msg...)
    printstyled(io, "julia> "; bold=true, color=:green)
    println(io, msg...)
end

# limit the output to the number of columns
function limit(io::IO, msg)
    _, ncols::Int = displaysize(io)
    s = sprint(io -> show(io, MIME"text/plain"(), msg))
    for l in eachsplit(s, '\n')
        n = min(length(l), ncols)
        for (i, c) in enumerate(l)
            i ≤ n && print(io, c)
        end
        println(io)
    end
end

function print_and_eval(io::IO, s::String)
    julia(io, s)
    limit(io, eval(Meta.parse(s)))
end

function print_and_eval(io::IO, strs::Vararg{String})
    s1, _strs... = strs
    print_and_eval(io, s1)
    for str in _strs
        println(io)
        print_and_eval(io, str)
    end
end

# benchmarking
function bench(io::IO, lazytable_expr::String, typedtable_expr::String)
    eval(Meta.parse("lazytab_res = "*lazytable_expr))
    eval(Meta.parse("typetab_res = "*typedtable_expr))
    # time ---------------------------------------------------------------------------------
    println(io)
    ltime = mean(lazytab_res.times)
    ttime = mean(typetab_res.times)
    if ttime > ltime
        frac = ttime/ltime
        @printf(io, "LazyTable is %.2f times FASTER than TypedTables.Table", frac)
    #else
    #    frac = ltime/ttime
    #    @printf(io, "This shouldn't be happening but LazyTable is %.2f times SLOWER than \
    #        TypedTables.Table, something must be wrong!", frac)
    end
    println(io)
    # memory -------------------------------------------------------------------------------
    lmem = lazytab_res.memory
    tmem = typetab_res.memory
    if tmem > lmem
        x = 100*(tmem - lmem)/tmem
        @printf(io, "LazyTable used %.2f%% LESS memory than TypedTables.Table", x)
    #else
    #    x = 100*(lmem - tmem)/lmem
    #    @printf(io, "This shouldn't be happening but LazyTable used %.2f%% MORE memory \
    #        than TypedTables.Table, something must be wrong!", x)
    end
    println(io)
    # allocations --------------------------------------------------------------------------
    lallocs = lazytab_res.allocs
    tallocs = typetab_res.allocs
    if tallocs > lallocs
        x = 100*(tallocs - lallocs)/tallocs
        @printf(io, "LazyTable made %.2f%% FEWER allocations than TypedTables.Table", x)
    #else
    #    x = 100*(lallocs - tallocs)/lallocs
    #    @printf(io, "This shouldn't be happening but LazyTable made %.2f%% MORE \
    #        allocations than TypedTables.Table, something must be wrong!", x)
    end
    println(io)
    # display benchmark results ------------------------------------------------------------
    println(io)
    julia(io, lazytable_expr)
    display(lazytab_res)
    julia(io, typedtable_expr)
    display(typetab_res)
end
function bench(io::IO, f::String, lazytable_expr::String, typedtable_expr::String)
    julia(io, f)
    eval(Meta.parse(f))
    bench(io, lazytable_expr, typedtable_expr)
end

# horizontal line
hline(io::IO) = println(repeat('-', displaysize(io)[2]))

# just to show that they contain the same data
print_and_eval(stdout,
    "typetab[2]",
    "lazytab[2]",
    "all(keys(typetab[2]) .== keys(lazytab[2]))",
    "all(values(typetab[2]) .== values(lazytab[2]))",
)
hline(stdout)
bench(stdout,
    raw"@benchmark values($lazytab[i]) setup=(i=rand(1:1000)) ",
    raw"@benchmark values($typetab[i]) setup=(i=rand(1:1000)) ",
)
hline(stdout)
bench(stdout,
    raw"@benchmark pairs($lazytab[i]) setup=(i=rand(1:1000)) ",
    raw"@benchmark pairs($typetab[i]) setup=(i=rand(1:1000)) ",
)
hline(stdout)
bench(stdout,
    "f(x) = Iterators.map(x -> x.a, x)",
    raw"@benchmark f($lazytab[i]) setup=(i=rand(1:1000)) ",
    raw"@benchmark f($typetab[i]) setup=(i=rand(1:1000)) ",
)
hline(stdout)
bench(stdout,
    "f(x) = x[500]",
    raw"@benchmark f($lazytab)",
    raw"@benchmark f($typetab)",
)
hline(stdout)
bench(stdout,
    "f(x) = sum(x[500])",
    raw"@benchmark f($lazytab)",
    raw"@benchmark f($typetab)",
)
hline(stdout)
bench(stdout,
    "f(x) = filter(<(0.5), x.z)",
    raw"@benchmark f($lazytab)",
    raw"@benchmark f($typetab)",
)
hline(stdout)
bench(stdout,
    "f(x) = filter(x -> x.z < 0.5, x)",
    raw"@benchmark f($lazytab)",
    raw"@benchmark f($typetab)",
)
hline(stdout)
bench(stdout,
    "f(x) = Iterators.filter(x -> x.z < 0.5, x)",
    raw"@benchmark f($lazytab)",
    raw"@benchmark f($typetab)",
)
hline(stdout)
bench(stdout,
    "f(x) = vcat(x, x)",
    raw"@benchmark f($lazytab)",
    raw"@benchmark f($typetab)",
)
