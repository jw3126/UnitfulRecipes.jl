using Test, Unitful, RecipesBase, Plots
using Unitful: m, s, cm
using UnitfulRecipes: recipe!, @P_str

Attributes = Dict{Symbol, Any}
@testset "One Array" begin
    attr = Attributes()
    ys_val = [1, 2.3]
    ys = ys_val * m
    ys_ret = recipe!(attr, ys)
    @test ys_ret ≈ ys_val
    @test attr[:yguide] == "m"

    label = P"hello"
    content = label.content
    attr = Attributes(:yguide => label)
    recipe!(attr, ys)


    attr = Attributes(:yguide => "hello")
    recipe!(attr, ys)
    @test attr[:yguide] == "hello (m)"

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

@testset "Plots" begin
    @testset "data as $dtype" for dtype in [:Vectors, :Matrices, Symbol("Vectors of vectors")]
        if dtype == :Vectors
            x, y, z = randn(10), randn(10), randn(10)
        elseif dtype == :Matrices
            x, y, z = randn(10,2), randn(10,2), randn(10,2)
        else
            x, y, z = [rand(10), rand(20)], [rand(10), rand(20)], [rand(10), rand(20)]
        end


        @testset "One array" begin
            @test plot(x*m)                    isa Plots.Plot
            @test plot(x*m, ylabel="x")        isa Plots.Plot
            @test plot(x*m, ylims=(-1,1))      isa Plots.Plot
            @test plot(x*m, ylims=(-1,1) .* m) isa Plots.Plot
            dtype ≠ Symbol("Vectors of vectors") && @test plot(x*m, yunit=u"km") isa Plots.Plot
            @test plot(x -> x^2, x*m)          isa Plots.Plot
        end

        @testset "Two arrays" begin
            @test plot(x*m, y*s)                    isa Plots.Plot
            @test plot(x*m, y*s, xlabel="x")        isa Plots.Plot
            @test plot(x*m, y*s, xlims=(-1,1))      isa Plots.Plot
            @test plot(x*m, y*s, xlims=(-1,1) .* m) isa Plots.Plot
            if dtype == Symbol("Vectors of vectors") 
                @test_broken plot(x*m, y*s, xunit=u"km") isa Plots.Plot
            else
                @test plot(x*m, y*s, xunit=u"km") isa Plots.Plot
            end
            @test plot(x*m, y*s, ylabel="y")        isa Plots.Plot
            @test plot(x*m, y*s, ylims=(-1,1))      isa Plots.Plot
            @test plot(x*m, y*s, ylims=(-1,1) .* s) isa Plots.Plot
            dtype ≠ Symbol("Vectors of vectors") && @test plot(x*m, y*s, yunit=u"ks") isa Plots.Plot
            if dtype ≠ Symbol("Vectors of vectors")
                @test scatter(x*m, y*s)                 isa Plots.Plot
                @test scatter(x*m, y*s, zcolor=z*(m/s)) isa Plots.Plot
            end
            (dtype == :Vectors) && @test plot(x*m, y*s, (x,y) -> x/s) isa Plots.Plot
        end

        @testset "Three arrays" begin
            @test plot(x*m, y*s, z*(m/s))                        isa Plots.Plot
            @test plot(x*m, y*s, z*(m/s), xlabel="x")            isa Plots.Plot
            @test plot(x*m, y*s, z*(m/s), xlims=(-1,1))          isa Plots.Plot
            @test plot(x*m, y*s, z*(m/s), xlims=(-1,1) .* m)     isa Plots.Plot
            dtype ≠ Symbol("Vectors of vectors") && @test plot(x*m, y*s, z*(m/s), xunit=u"km")           isa Plots.Plot
            @test plot(x*m, y*s, z*(m/s), ylabel="y")            isa Plots.Plot
            @test plot(x*m, y*s, z*(m/s), ylims=(-1,1))          isa Plots.Plot
            @test plot(x*m, y*s, z*(m/s), ylims=(-1,1) .* s)     isa Plots.Plot
            dtype ≠ Symbol("Vectors of vectors") && @test plot(x*m, y*s, z*(m/s), yunit=u"ks")           isa Plots.Plot
            @test plot(x*m, y*s, z*(m/s), zlabel="z")            isa Plots.Plot
            @test plot(x*m, y*s, z*(m/s), zlims=(-1,1))          isa Plots.Plot
            @test plot(x*m, y*s, z*(m/s), zlims=(-1,1) .* (m/s)) isa Plots.Plot
            dtype ≠ Symbol("Vectors of vectors") && @test plot(x*m, y*s, z*(m/s), zunit=u"km/s")         isa Plots.Plot
            @test scatter(x*m, y*s, z*(m/s))                     isa Plots.Plot
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

    @testset "scatter(x::$(us[1]), y::$(us[2]))" for us in collect(Iterators.product(fill([1, u"m", u"s"], 2)...))
        x, y = rand(10)*us[1], rand(10)*us[2]
        @test scatter(x,y)  isa Plots.Plot
        @test scatter(x,y, markersize=x)  isa Plots.Plot
        @test scatter(x,y, line_z=x)  isa Plots.Plot
    end

    @testset "contour(x::$(us[1]), y::$(us[2]))" for us in collect(Iterators.product(fill([1, u"m", u"s"], 2)...))
        x, y = (1:0.01:2)*us[1], (1:0.02:2)*us[2]
        z = x' ./ y
        @test contour(x,y,z)  isa Plots.Plot
        @test contourf(x,y,z) isa Plots.Plot
    end

    @testset "ProtectedString" begin
        y = rand(10)*u"m"
        @test plot(y, label=P"meters") isa Plots.Plot
    end


end
