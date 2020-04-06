using Test, Unitful, RecipesBase, Plots
using Unitful: m, s, cm
using UnitfulRecipes

xguide(plt) = plt.subplots[1].attr[:xaxis].plotattributes[:guide]
yguide(plt) = plt.subplots[1].attr[:yaxis].plotattributes[:guide]
zguide(plt) = plt.subplots[1].attr[:zaxis].plotattributes[:guide]
xseries(plt) = plt.series_list[1].plotattributes[:x]
yseries(plt) = plt.series_list[1].plotattributes[:y]
zseries(plt) = plt.series_list[1].plotattributes[:z]

@testset "plot(y)" begin
    y = rand(3)m

    @testset "no keyword argument" begin
        @test yguide(plot(y)) == "m"
        @test yseries(plot(y)) ≈ ustrip.(y)
    end

    @testset "ylabel" begin
        @test yguide(plot(y, ylabel="hello")) == "hello (m)"
        @test yguide(plot(y, ylabel=P"hello")) == "hello"
        @test yguide(plot(y, ylabel="")) == ""
    end

    @testset "yunit" begin
        @test yguide(plot(y, yunit=cm)) == "cm"
        @test yseries(plot(y, yunit=cm)) ≈ ustrip.(cm, y)
    end

    @testset "ylims" begin # Using all(lims .≈ lims) because of uncontrolled type conversions?
        @test all(ylims(plot(y, ylims=(-1,3))) .≈ (-1,3))
        @test all(ylims(plot(y, ylims=(-1m,3m))) .≈ (-1,3))
        @test all(ylims(plot(y, ylims=(-100cm,300cm))) .≈ (-1,3))
        @test all(ylims(plot(y, ylims=(-100cm,3m))) .≈ (-1,3))
    end

    @testset "keyword combinations" begin
        @test yguide(plot(y, yunit=cm, ylabel="hello")) == "hello (cm)"
        @test yseries(plot(y, yunit=cm, ylabel="hello")) ≈ ustrip.(cm, y)
        @test all(ylims(plot(y, yunit=cm, ylims=(-1,3))) .≈ (-1,3))
        @test all(ylims(plot(y, yunit=cm, ylims=(-1,3))) .≈ (-1,3))
        @test all(ylims(plot(y, yunit=cm, ylims=(-100cm,300cm))) .≈ (-100,300))
        @test all(ylims(plot(y, yunit=cm, ylims=(-100cm,3m))) .≈ (-100,300))
    end
end

@testset "plot(x,y)" begin
    x, y = randn(3)m, randn(3)s

    @testset "no keyword argument" begin
        @test xguide(plot(x,y)) == "m"
        @test xseries(plot(x,y)) ≈ ustrip.(x)
        @test yguide(plot(x,y)) == "s"
        @test yseries(plot(x,y)) ≈ ustrip.(y)
    end

    @testset "labels" begin
        @test xguide(plot(x, y, xlabel= "hello")) == "hello (m)"
        @test xguide(plot(x, y, xlabel=P"hello")) == "hello"
        @test yguide(plot(x, y, ylabel= "hello")) == "hello (s)"
        @test yguide(plot(x, y, ylabel=P"hello")) == "hello"
        @test xguide(plot(x, y, xlabel= "hello", ylabel= "hello")) == "hello (m)"
        @test xguide(plot(x, y, xlabel=P"hello", ylabel=P"hello")) == "hello"
        @test yguide(plot(x, y, xlabel= "hello", ylabel= "hello")) == "hello (s)"
        @test yguide(plot(x, y, xlabel=P"hello", ylabel=P"hello")) == "hello"
    end
end

@testset "Moar plots" begin
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
