# UnitfulRecipes.jl

*for plotting data with units seemlessly in Julia*

<p>
  <a href="https://jw3126.github.io/UnitfulRecipes.jl/stable/">
    <img src=https://img.shields.io/badge/docs-stable-important.svg?style=flat-square&label=Documentation&logo=Read%20the%20Docs>
  </a>
</p>

<p>
  <a href="https://travis-ci.com/jw3126/UnitfulRecipes.jl">
    <img alt="Build Status" src="https://img.shields.io/travis/com/jw3126/UnitfulRecipes.jl/master?label=OSX/Linux&logo=travis&logocolor=white&style=flat-square">
  </a>
</p>
<p>
  <a href="https://codecov.io/gh/jw3126/UnitfulRecipes.jl">
    <img src="https://img.shields.io/codecov/c/github/jw3126/UnitfulRecipes.jl/master?label=Codecov&logo=codecov&logoColor=white&style=flat-square">
  </a>
</p>



[UnitfulRecipes.jl](https://github.com/jw3126/UnitfulRecipes.jl) provides recipes for plotting figures ([Plots.jl](https://github.com/JuliaPlots/Plots.jl)) when using data with units ([Unitful.jl](https://github.com/PainterQubits/Unitful.jl)).

Below is a basic example

```julia
using Unitful, UnitfulRecipes, Plots
xs = randn(10)*u"km"
ys = randn(10)*u"kg"
plot(xs, ys)
```

which should give something like

![example1](https://user-images.githubusercontent.com/4486578/72591885-74a20500-3955-11ea-9552-489451bd01fd.png)

Head over to the [documentation](https://jw3126.github.io/UnitfulRecipes.jl/stable/) for more examples!
