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

# ## Axis label

# If you specify an axis label, the unit will be appended to it

plot(y, ylabel="mass")

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

# for scatter plots

scatter(x, y, z)

# ## Contour plots

# for contours plots

x, y = (1:0.01:2)*u"m", (1:0.02:2)*u"s"
z = x' ./ y
contour(x, y, z)

# and filled contours

contourf(x, y, z)


