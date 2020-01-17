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

# Acknowledgements

Inspired by [UnitfulPlots.jl](https://github.com/PainterQubits/UnitfulPlots.jl).
