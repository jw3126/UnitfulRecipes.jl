#---------------------------------------------------------
# # [Simple Examples](@id 1_Examples)
#---------------------------------------------------------

#md # [![](https://mybinder.org/badge_logo.svg)](@__BINDER_ROOT_URL__/notebooks/1_Examples.ipynb)
#md # [![](https://img.shields.io/badge/show-nbviewer-579ACA.svg)](@__NBVIEWER_ROOT_URL__/notebooks/1_Examples.ipynb)

#md # !!! note
#md #     These examples are available as Jupyter notebooks.
#md #     You can execute them online with [binder](https://mybinder.org/) or just view them with [nbviewer](https://nbviewer.jupyter.org/) by clicking on the badges above!

# These examples show what UnitfulRecipes is all about.

# First we need to tell Julia we are using Plots, Unitful, and UnitfulRecipes

using Plots, Unitful, UnitfulRecipes

# ## Simplest plot

# This is the most basic example

y = randn(10)*u"kg"
plot(y)

# Add some more plots, and it will be aware of the units you used previously (note `y2` is about 10 times smaller than `y1`)

y2 = 100randn(10)*u"g"
plot!(y2)


# UnitfulRecipes will not allow you to plot with different unit-dimensions, so
# ```julia
# plot!(rand(10)*u"m")
# ```
# won't work here.
#
# But you can add inset subplots with different axes that have different dimensions

plot!(rand(10)*u"m", inset=bbox(0.5, 0.5, 0.3, 0.3), subplot=2)

# ## Axis label

# If you specify an axis label, the unit will be appended to it.

plot(y, ylabel="mass")

# Unless you want it untouched, in which case you can use a "protected" string using the `@P_str` macro.

plot(y, ylabel=P"mass in kilograms")

# Just like with the `label` keyword for legends, no axis label is added if you specify the axis label to be an empty string.

plot(y, ylabel="")

# ## Axis unit

# You can use the axis-specific keyword arguments to convert units on the fly

plot(y, yunit=u"g")

# ## Axis limits

# Setting the axis limits can be done with units

plot(y, ylims=(-1000u"g",2000u"g"))

# or without

plot(y, ylims=(-1,2))

# ## Multiple series

# You can plot multiple series as 2D arrays

x, y = rand(10,3)*u"m", rand(10,3)*u"g"
plot(x, y)

# Or vectors of vectors (of potnetially different lengths)

x, y = [rand(10), rand(15), rand(20)]*u"m", [rand(10), rand(15), rand(20)]*u"g"
plot(x, y)

# ## 3D

# It works in 3D

x, y = rand(10)*u"km", rand(10)*u"hr"
z = x ./ y
plot(x, y, z)

# ## Scatter plots

# You can do scatter plots

scatter(x, y, zcolor=z, clims=(5,20).*unit(eltype(z)))

# and 3D scatter plots too

scatter(x, y, z, zcolor=z)

# ## Contour plots

# for contours plots

x, y = (1:0.01:2)*u"m", (1:0.02:2)*u"s"
z = x' ./ y
contour(x, y, z)

# and filled contours

contourf(x, y, z)

# ## Error bars

# For example, you can use the `yerror` keyword argument with units,
# which will be converted to the units of `y` and plot your errorbars:

using Unitful: GeV, MeV, c
x = (1.0:0.1:10) * GeV/c
y = @. (2 + sin(x / (GeV/c))) * 0.4GeV/c^2 # a sine to make it pretty
yerror = 10.9MeV/c^2 * exp.(randn(length(x))) # some noise for pretty again
plot(x, y; yerror, title="My unitful data with yerror bars", lab="")

