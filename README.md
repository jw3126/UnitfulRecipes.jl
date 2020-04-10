# UnitfulRecipes.jl

*for plotting data with units seemlessly in Julia*

<p>
  <a href="https://jw3126.github.io/UnitfulRecipes.jl/stable/">
    <img src="https://img.shields.io/github/workflow/status/jw3126/UnitfulRecipes.jl/Documentation?style=for-the-badge&label=Documentation&logo=Read%20the%20Docs&logoColor=white">
  </a>
</p>

<p>
  <a href="https://github.com/jw3126/UnitfulRecipes.jl/actions">
    <img src="https://img.shields.io/github/workflow/status/jw3126/UnitfulRecipes.jl/Mac%20OS%20X?label=OSX&logo=Apple&logoColor=white&style=flat-square">
  </a>
  <a href="https://github.com/jw3126/UnitfulRecipes.jl/actions">
    <img src="https://img.shields.io/github/workflow/status/jw3126/UnitfulRecipes.jl/Linux?label=Linux&logo=Linux&logoColor=white&style=flat-square">
  </a>
  <a href="https://github.com/jw3126/UnitfulRecipes.jl/actions">
    <img src="https://img.shields.io/github/workflow/status/jw3126/UnitfulRecipes.jl/Windows?label=Windows&logo=Windows&logoColor=white&style=flat-square">
  </a>
  <a href="https://codecov.io/gh/jw3126/UnitfulRecipes.jl">
    <img src="https://img.shields.io/codecov/c/github/jw3126/UnitfulRecipes.jl/master?label=Codecov&logo=codecov&logoColor=white&style=flat-square">
  </a>
</p>

[UnitfulRecipes.jl](https://github.com/jw3126/UnitfulRecipes.jl) provides recipes for plotting figures ([Plots.jl](https://github.com/JuliaPlots/Plots.jl)) when using data with units ([Unitful.jl](https://github.com/PainterQubits/Unitful.jl)).

```julia
using Unitful, UnitfulRecipes, Plots
xs = randn(10)*u"km"
ys = randn(10)*u"kg"
plot(xs, ys)
```

should give something like

![example1](https://user-images.githubusercontent.com/4486578/72591885-74a20500-3955-11ea-9552-489451bd01fd.png)

Head over to the [documentation](https://jw3126.github.io/UnitfulRecipes.jl/stable/) for more examples!

### Acknowledgements

Inspired by [UnitfulPlots.jl](https://github.com/PainterQubits/UnitfulPlots.jl).
