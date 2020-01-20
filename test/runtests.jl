using Test, Unitful, RecipesBase, Plots
using Unitful: m, s, cm
using UnitfulRecipes: recipe!

Attributes = Dict{Symbol, Any}
@testset "One Array" begin
    attr = Attributes()
    ys_val = [1, 2.3]
    ys = ys_val * m
    ys_ret = recipe!(attr, ys)
    @test ys_ret ≈ ys_val
    @test attr[:yguide] == string(m)

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
    @test !haskey(attr, :xguide)
    @test haskey(attr, :yguide)

    xs_ret, ys_ret = recipe!(attr, xs, ys)
    @test xs_ret ≈ xs_val
    @test ys_ret ≈ ys_val
    @test haskey(attr, :xguide)
    @test haskey(attr, :yguide)

    zs_val = randn(3)
    xs_ret, ys_ret, zs_ret = recipe!(attr, xs, ys, zs_val)
    @test xs_ret ≈ xs_val
    @test ys_ret ≈ ys_val
    @test zs_ret ≈ zs_val
    @test haskey(attr, :xguide)
    @test haskey(attr, :yguide)
    @test !haskey(attr, :zguide)
end

@testset "Plots (data as $dtype)" for dtype in [:Vectors, :Arrays]
    if dtype == :Vectors 
        x, y, z = randn(10), randn(10), randn(10)
    else
        x, y, z = randn(10,2), randn(10,2), randn(10,2)
    end

    @testset "One array" begin
        @test plot(x*m)                    isa Plots.Plot
        @test plot(x*m, ylabel="x")        isa Plots.Plot
        @test plot(x*m, ylims=(-1,1))      isa Plots.Plot
        @test plot(x*m, ylims=(-1,1) .* m) isa Plots.Plot
        @test plot(x*m, yunit=u"km")       isa Plots.Plot
    end

    @testset "Two arrays" begin
        @test plot(x*m, y*s)                    isa Plots.Plot
        @test plot(x*m, y*s, xlabel="x")        isa Plots.Plot
        @test plot(x*m, y*s, xlims=(-1,1))      isa Plots.Plot
        @test plot(x*m, y*s, xlims=(-1,1) .* m) isa Plots.Plot
        @test plot(x*m, y*s, xunit=u"km")       isa Plots.Plot
        @test plot(x*m, y*s, ylabel="y")        isa Plots.Plot
        @test plot(x*m, y*s, ylims=(-1,1))      isa Plots.Plot
        @test plot(x*m, y*s, ylims=(-1,1) .* s) isa Plots.Plot
        @test plot(x*m, y*s, yunit=u"ks")       isa Plots.Plot
    end

    @testset "Three arrays" begin
        @test plot(x*m, y*s, z*(m/s))                        isa Plots.Plot
        @test plot(x*m, y*s, z*(m/s), xlabel="x")            isa Plots.Plot
        @test plot(x*m, y*s, z*(m/s), xlims=(-1,1))          isa Plots.Plot
        @test plot(x*m, y*s, z*(m/s), xlims=(-1,1) .* m)     isa Plots.Plot
        @test plot(x*m, y*s, z*(m/s), xunit=u"km")           isa Plots.Plot
        @test plot(x*m, y*s, z*(m/s), ylabel="y")            isa Plots.Plot
        @test plot(x*m, y*s, z*(m/s), ylims=(-1,1))          isa Plots.Plot
        @test plot(x*m, y*s, z*(m/s), ylims=(-1,1) .* s)     isa Plots.Plot
        @test plot(x*m, y*s, z*(m/s), yunit=u"ks")           isa Plots.Plot
        @test plot(x*m, y*s, z*(m/s), zlabel="z")            isa Plots.Plot
        @test plot(x*m, y*s, z*(m/s), zlims=(-1,1))          isa Plots.Plot
        @test plot(x*m, y*s, z*(m/s), zlims=(-1,1) .* (m/s)) isa Plots.Plot
        @test plot(x*m, y*s, z*(m/s), zunit=u"km/s")         isa Plots.Plot
    end

    @testset "Unitful/unitless combinations" begin
        mystr(x::Array{<:Quantity}) = "Q"
        mystr(x::Array) = "A"
        @testset "plot($(mystr(xs)), $(mystr(ys)))" for xs in [x, x*m], ys in [y, y*s]
            @test plot(xs, ys) isa Plots.Plot
        end
        @testset "plot($(mystr(xs)), $(mystr(ys)), $(mystr(zs)))" for xs in [x, x*m], ys in [y, y*s], zs in [z, z*(m/s)]
            @test plot(xs, ys, zs) isa Plots.Plot
        end
    end

end


