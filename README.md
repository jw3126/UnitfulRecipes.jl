# UnitfulRecipes

[![Build Status](https://travis-ci.com/jw3126/UnitfulRecipes.jl.svg?branch=master)](https://travis-ci.com/jw3126/UnitfulRecipes.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/jw3126/UnitfulRecipes.jl?svg=true)](https://ci.appveyor.com/project/jw3126/UnitfulRecipes-jl)
[![Codecov](https://codecov.io/gh/jw3126/UnitfulRecipes.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jw3126/UnitfulRecipes.jl)
[![Coveralls](https://coveralls.io/repos/github/jw3126/UnitfulRecipes.jl/badge.svg?branch=master)](https://coveralls.io/github/jw3126/UnitfulRecipes.jl?branch=master)

# Usage

```julia
using Unitful: cm, kg
using UnitfulRecipes
using Plots

xs = randn(10)*cm
ys = randn(10)*kg
plot(xs, ys)
```

# Acknowledgements

Inspired by [UnitfulPlots.jl](https://github.com/PainterQubits/UnitfulPlots.jl).
