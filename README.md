# UnitfulRecipes.jl

*for plotting data with units seamlessly in Julia*

## Deprecation

As of Plots.jl `v1.34.2`, UnitfulRecipes is included in Plots, and is no longer
necessary. Instead, loading both Unitful.jl and Plots.jl suffices to plot
unitful data.

## Archive

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

[UnitfulRecipes.jl](https://github.com/jw3126/UnitfulRecipes.jl) makes it easy to plot data with units.

It works by providing [recipes](http://docs.juliaplots.org/latest/recipes/#recipes) for the [Plots.jl](https://github.com/JuliaPlots/Plots.jl) package that can deal with units from [Unitful.jl](https://github.com/PainterQubits/Unitful.jl).
For a quick example,

```julia
using Unitful, UnitfulRecipes, Plots
const a = 1u"m/s^2"
v(t) = a * t
x(t) = a/2 * t^2
t = (0:0.01:100)*u"s"
plot(x.(t), v.(t), xlabel="position", ylabel="speed")
```

should give something like

![UnitfulRecipeExample](https://user-images.githubusercontent.com/4486578/78975352-451b2700-7b57-11ea-8e7d-42c2860da51f.png)

Head over to the [documentation](https://jw3126.github.io/UnitfulRecipes.jl/stable/) for more examples!

### Acknowledgements

Inspired by [UnitfulPlots.jl](https://github.com/PainterQubits/UnitfulPlots.jl).
