```@meta
EditURL = "<unknown>/docs/lit/examples/1_Examples.jl"
```

# [Simple Examples](@id 1_Examples)

[![](https://mybinder.org/badge_logo.svg)](<unknown>/notebooks/1_Examples.ipynb)
[![](https://img.shields.io/badge/show-nbviewer-579ACA.svg)](<unknown>/notebooks/1_Examples.ipynb)

!!! note
    These examples are available as Jupyter notebooks.
    You can execute them online with [binder](https://mybinder.org/) or just view them with [nbviewer](https://nbviewer.jupyter.org/) by clicking on the badges above!

These examples show what UnitfulRecipes is all about.

First we need to tell Julia we are using Plots, Unitful, and UnitfulRecipes

```@example 1_Examples
using Plots, Unitful, UnitfulRecipes
```

## Simplest plot

This is the most basic example

```@example 1_Examples
y = randn(10)*u"kg"
plot(y)
```

## Axis label

If you specify an axis label, the unit will be appended to it

```@example 1_Examples
plot(y, ylabel="mass")
```

## Axis unit

You can use the axis-specific keyword arguments to convert units on the fly

```@example 1_Examples
plot(y, yunit=u"g")
```

## Axis limits

Setting the axis limits can be done with units

```@example 1_Examples
plot(y, ylims=(-1000u"g",2000u"g"))
```

or without

```@example 1_Examples
plot(y, ylims=(-1,2))
```

## Multiple series

You can plot multiple series as 2D arrays

```@example 1_Examples
x, y = rand(10,3)*u"m", rand(10,3)*u"g"
plot(x, y)
```

Or vectors of vectors (of potnetially different lengths)

```@example 1_Examples
x, y = [rand(10), rand(15), rand(20)]*u"m", [rand(10), rand(15), rand(20)]*u"g"
plot(x, y)
```

## 3D

It works in 3D

```@example 1_Examples
x, y = rand(10)*u"km", rand(10)*u"hr"
z = x ./ y
plot(x, y, z)
```

## Scatter plots

for scatter plots

```@example 1_Examples
scatter(x, y, z)
```

## Contour plots

for contours plots

```@example 1_Examples
x, y = (1:0.01:2)*u"m", (1:0.02:2)*u"s"
z = x' ./ y
contour(x, y, z)
```

and filled contours

```@example 1_Examples
contourf(x, y, z)
```

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

