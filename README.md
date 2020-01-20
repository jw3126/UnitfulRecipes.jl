# UnitfulRecipes

[![Build Status](https://travis-ci.com/jw3126/UnitfulRecipes.jl.svg?branch=master)](https://travis-ci.com/jw3126/UnitfulRecipes.jl)
[![Codecov](https://codecov.io/gh/jw3126/UnitfulRecipes.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jw3126/UnitfulRecipes.jl)

# Usage

- without providing axis labels

    ```julia
    using Unitful: m, km, g, kg
    using UnitfulRecipes, Plots
    xs = randn(10)*km
    ys = randn(10)*kg
    plot(xs, ys)
    ```

    gives

    ![example1](https://user-images.githubusercontent.com/4486578/72591885-74a20500-3955-11ea-9552-489451bd01fd.png)

- providing an axis label

    ```julia
    plot(xs, ys, xlabel="length")
    ```

    gives

    ![example2](https://user-images.githubusercontent.com/4486578/72591886-74a20500-3955-11ea-880b-ae34a67fb1ff.png)


- converting units on the fly

    ```julia
    plot(xs, ys, xlabel="length", xunit=m)
    ```

    gives

    ![example3](https://user-images.githubusercontent.com/4486578/72591888-74a20500-3955-11ea-9630-344700694002.png)

- setting axis limits with units

    ```julia
    plot(xs, ys, xlabel="length", xunit=m, ylims=(-1000,2000).*g)
    ```

    gives

    ![example4](https://user-images.githubusercontent.com/4486578/72591890-753a9b80-3955-11ea-8aa3-0b89ea42c6ec.png)

- works for multiple series

    ```julia
    xs, ys = rand(10,3)*m, rand(10,3)*g
    plot(xs, ys)
    ```

    gives

    ![example5](https://user-images.githubusercontent.com/4486578/72728617-e42c2480-3be1-11ea-8050-6b7d4614798a.png)

- in 3D

    ```julia
    xs, ys, zs = rand(10)*m, rand(10)*g, rand(10)*(g/m)
    plot(xs, ys, zs)
    ```

    gives

    ![example6](https://user-images.githubusercontent.com/4486578/72728618-e42c2480-3be1-11ea-8581-499a237aa4d5.png)

- for contours

    ```julia
    xs, ys = (1:0.01:2)*m, (1:0.02:2)*g
    zs = xs' ./ ys
    contour(xs, ys, zs)
    ```

    gives

    ![example7](https://user-images.githubusercontent.com/4486578/72728619-e4c4bb00-3be1-11ea-8801-113469a3a28a.png)

- - for filled contours

    ```julia
    contourf(xs, ys, zs)
    ```

    gives

    ![example8](https://user-images.githubusercontent.com/4486578/72728620-e4c4bb00-3be1-11ea-91c3-1eddc88491bf.png)


# Acknowledgements

Inspired by [UnitfulPlots.jl](https://github.com/PainterQubits/UnitfulPlots.jl).
