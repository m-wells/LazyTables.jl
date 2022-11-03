using LazyTables
using TypedTables: Table
import Tables
using Test

@testset "LazyTable" begin
    lt1 = LazyTable(; x = rand(10), y = rand(10))
    @test isa(lt1, LazyTable)
    @test isa(lt1, AbstractVector)
    @inferred lt1.x[2]
    @inferred lt1.y[2]

    @test isa(lt1 |> Table, Table)
end
@testset "LazyTable 2d" begin
    lt_mat = LazyTable(; x = rand(10,2), y = rand(10,2))
    @test isa(lt_mat, AbstractMatrix)
    @test isa(lt_mat, LazyTable)
    @inferred lt_mat.x[2]
    @inferred lt_mat.y[2]
end

@testset "Tables.jl" begin
    x = rand(10)
    y = rand(Float32, 10)
    lzytbl = LazyTable(; x, y, evens = string.(2:2:20))
    # test that the LazyTable `istable`
    @test Tables.istable(typeof(lzytbl))
    # test that it defines row access
    @test Tables.rowaccess(typeof(lzytbl))
    @test Tables.rows(lzytbl) === lzytbl
    # test that it defines column access
    @test Tables.columnaccess(typeof(lzytbl))
    @test Tables.columns(lzytbl) === lzytbl
    # test that we can access the first "column" of our lazy table by column name
    @test lzytbl.x == x
    # test our `Tables.AbstractColumns` interface methods
    @test Tables.getcolumn(lzytbl, :x) == x
    @test Tables.getcolumn(lzytbl, 1) == x
    @test Tables.columnnames(lzytbl) == (:x, :y, :evens)
    ## now let's iterate our LazyTable to get our first LazyRow
    lzyrow = first(lzytbl)
    @test eltype(lzytbl) == typeof(lzyrow)
    # now we can test our `Tables.AbstractRow` interface methods on our LazyRow
    @test lzyrow.evens == "2"
    @test Tables.getcolumn(lzyrow, :evens) == "2"
    @test Tables.getcolumn(lzyrow, 3) == "2"
    @test propertynames(lzytbl) == propertynames(lzyrow) == (:x, :y, :evens)
end

@testset "AbstractArray" begin
    x = rand(10)
    y = rand(Float32, 10)
    lzytbl = LazyTable(; x, y)
    @test first(lzytbl) === lzytbl[1]
    @test last(lzytbl) === lzytbl[end]
end

@testset "Base methods" begin
    x = collect(2:2:20)
    y = [true, true, false, false, true, true, false, true, false, false]
    lzytbl = LazyTable(; x, y)
    @test map(sin, x) == sin.(x)
    @test map(sin, x) !== sin.(x) # it is lazy
    for (_filter, _view) in zip(filter(row -> row.y, lzytbl), view(lzytbl, y))
        @test all(_filter .== _view)
    end
    lzyvcat = vcat(lzytbl, lzytbl)
    for (_vcat, _lzyt) in zip(view(lzyvcat, 1:10), lzytbl)
        @test all(_vcat .== _lzyt)
    end
    a = rand(10)
    b = rand(Float32, 10)
    lzyhcat = hcat(LazyTable(; x = a, y = b), lzytbl)
    @test size(lzyhcat)[1] == length(lzytbl)
    @test size(lzyhcat)[2] == 2
    lzytbl2 = LazyTable(; a, b)
    lzymerge = merge(lzytbl, lzytbl2)
    @test length(lzymerge) === length(lzytbl) === length(lzytbl2)
    @test Tables.columnnames(lzymerge) === (:x, :y, :a, :b)
end

@testset "TypedTable validate" begin
    a = rand(100)
    b = rand(100)
    typetab = Table(; a, b)
    lazytab = LazyTable(typetab)
    trow4 = typetab[4]
    lrow4 = lazytab[4]
    @test sum(trow4) === sum(lrow4)
    @test all(values(trow4) .== values(lrow4))
    @test all(zip(pairs(trow4), pairs(lrow4))) do (tkv, lkv)
        tk, tv = tkv
        lk, lv = lkv
        (tk === lk) && (tv === lv)
    end
end
