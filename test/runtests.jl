using Test
using Unitful: m, s, cm
using UnitfulRecipes: recipe!, UnitFormatter
import RecipesBase

Attributes = Dict{Symbol, Any}
@testset "One Array" begin
    attr = Attributes()
    ys_val = [1, 2.3]
    ys = ys_val * m
    ys_ret = recipe!(attr, ys)
    @test ys_ret ≈ ys_val
    @test attr[:yformatter] == UnitFormatter(m)
    
    attr = Attributes(:yunit => cm)
    ys_ret = recipe!(attr, ys)
    @test ys_ret ≈ ys_val * 100
    @test !haskey(attr, :yunit)
    
    attr = Attributes(:ylims => (100cm, 2m))
    ys_ret = recipe!(attr, ys)
    @test ys_ret ≈ ys_val
    @test attr[:ylims] == (1, 2)
end

@testset "Multi Array" begin
    attr = Attributes()
    xs_val = randn(3)
    ys_val = randn(3)
    xu = s
    yu = m/s
    xs = xs_val * xu
    ys = ys_val * yu
    xs_ret, ys_ret = recipe!(attr, xs_val, ys)
    @test xs_ret ≈ xs_val
    @test ys_ret ≈ ys_val
    @test !haskey(attr, :xformatter)
    @test haskey(attr, :yformatter)
    
    xs_ret, ys_ret = recipe!(attr, xs, ys)
    @test xs_ret ≈ xs_val
    @test ys_ret ≈ ys_val
    @test haskey(attr, :xformatter)
    @test haskey(attr, :yformatter)
    
    zs_val = randn(3)
    xs_ret, ys_ret, zs_ret = recipe!(attr, xs, ys, zs_val)
    @test xs_ret ≈ xs_val
    @test ys_ret ≈ ys_val
    @test zs_ret ≈ zs_val
    @test haskey(attr, :xformatter)
    @test haskey(attr, :yformatter)
    @test !haskey(attr, :zformatter)
end

@testset "format" begin
    @test UnitFormatter(cm)(170.0) == "170.0cm"
    @test_broken UnitFormatter(cm)(170.000000000001) == "170.0cm"
end
