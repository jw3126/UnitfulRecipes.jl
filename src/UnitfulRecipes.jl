module UnitfulRecipes

using RecipesBase
using Unitful: Quantity, unit, ustrip, Unitful, dimension, Units
using Unitful: LogScaled, logunit, MixedUnits, Level, Gain, uconvert
export @P_str

const clims_types = (:contour, :contourf, :heatmap, :surface)

#==========
Main recipe
==========#

@recipe function f(::Type{T}, x::T) where T <: AbstractArray{<:Union{Missing,<:Quantity, <:LogScaled}}
    axisletter = plotattributes[:letter]   # x, y, or z
    if (axisletter == :z) &&
        get(plotattributes, :seriestype, :nothing) ∈ clims_types
        # u = get(plotattributes, :zunit, unit(eltype(x)))
        u = get(plotattributes, :zunit, eltype(x) <: LogScaled ? logunit(eltype(x)) : unit(eltype(x)))
        ustripattribute!(plotattributes, :clims, u)
        append_unit_if_needed!(plotattributes, :colorbar_title, u)
    end
    fixaxis!(plotattributes, x, axisletter)
end

function fixaxis!(attr, x, axisletter)
    # Attribute keys
    axislabel = Symbol(axisletter, :guide) # xguide, yguide, zguide
    axislims = Symbol(axisletter, :lims)   # xlims, ylims, zlims
    axisticks = Symbol(axisletter, :ticks) # xticks, yticks, zticks
    err = Symbol(axisletter, :error)       # xerror, yerror, zerror
    axisunit = Symbol(axisletter, :unit)   # xunit, yunit, zunit
    axis = Symbol(axisletter, :axis)       # xaxis, yaxis, zaxis
    # Get the unit
    u = pop!(attr, axisunit, _unit(x))
    # If the subplot already exists with data, get its unit
    sp = get(attr, :subplot, 1)
    if sp ≤ length(attr[:plot_object]) && attr[:plot_object].n > 0
        label = attr[:plot_object][sp][axis][:guide]
        if label isa UnitfulString
            u = label.unit
        end
        # If label was not given as an argument, reuse
        get!(attr, axislabel, label)
    end
    # Fix the attributes: labels, lims, ticks, marker/line stuff, etc.
    append_unit_if_needed!(attr, axislabel, u)
    ustripattribute!(attr, axislims, u)
    ustripattribute!(attr, axisticks, u)
    ustripattribute!(attr, err, u)
    if (axisletter == :y)
        ustripattribute!(attr, :ribbon, u)
        ustripattribute!(attr, :fillrange, u)
    end
    fixmarkercolor!(attr)
    fixmarkersize!(attr)
    fixlinecolor!(attr)
    # Strip the unit
    _ustrip.(u, x)
end

# Recipe for (x::AVec, y::AVec, z::Surface) types
const AVec = AbstractVector
const AMat{T} = AbstractArray{T,2} where T
@recipe function f(x::AVec, y::AVec, z::AMat{T}) where T <: Quantity
    u = get(plotattributes, :zunit, _unit(z))
    ustripattribute!(plotattributes, :clims, u)
    z = fixaxis!(plotattributes, z, :z)
    append_unit_if_needed!(plotattributes, :colorbar_title, u)
    x, y, z
end

# Recipe for vectors of vectors
@recipe function f(::Type{T}, x::T) where T <: AbstractVector{<:AbstractVector{<:Union{Missing,<:Quantity, <:LogScaled}}}
    axisletter = plotattributes[:letter]   # x, y, or z
    [fixaxis!(plotattributes, x, axisletter) for x in x]
end

# Recipe for bare units
@recipe function f(::Type{T}, x::T) where T <: Units
    primary := false
    Float64[]*x
end

# Recipes for functions
@recipe function f(f::Function, x::T) where T <: AVec{<:Union{Missing,<:Quantity, <:LogScaled}}
    x, f.(x)
end
@recipe function f(x::T, f::Function) where T <: AVec{<:Union{Missing,<:Quantity, <:LogScaled}}
    x, f.(x)
end
@recipe function f(x::T, y::AVec, f::Function) where T <: AVec{<:Union{Missing,<:Quantity, <:LogScaled}}
    x, y, f.(x',y)
end
@recipe function f(x::AVec, y::T, f::Function) where T <: AVec{<:Union{Missing,<:Quantity, <:LogScaled}}
    x, y, f.(x',y)
end
@recipe function f(x::T1, y::T2, f::Function) where {T1<:AVec{<:Union{Missing,<:Quantity, <:LogScaled}}, T2<:AVec{<:Union{Missing,<:Quantity, <:LogScaled}}}
    x, y, f.(x',y)
end
@recipe function f(f::Function, u::Units)
    uf = UnitFunction(f, [u])
    recipedata = RecipesBase.apply_recipe(plotattributes, uf)
    (_, xmin, xmax) = recipedata[1].args
    return f, xmin*u, xmax*u
end

"""
```julia
UnitFunction
```
A function, bundled with the assumed units of each of its inputs.

```julia
f(x, y) = x^2 + y
uf = UnitFunction(f, u"m", u"m^2")
uf(3, 2) == f(3u"m", 2u"m"^2) == 7u"m^2"
```
"""
struct UnitFunction <: Function
    f::Function
    u::Vector{Units}
end
(f::UnitFunction)(args...) = f.f((args .* f.u)...)

#===============
Attribute fixing
===============#

# Markers / lines
function fixmarkercolor!(attr)
    u = ustripattribute!(attr, :marker_z)
    ustripattribute!(attr, :clims, u)
    u == Unitful.NoUnits || append_unit_if_needed!(attr, :colorbar_title, u)
end
fixmarkersize!(attr) = ustripattribute!(attr, :markersize)
fixlinecolor!(attr) = ustripattribute!(attr, :line_z)

# strip unit from attribute[key]
function ustripattribute!(attr, key)
    if haskey(attr, key)
        v = attr[key]
        u = _unit(eltype(v))
        attr[key] = _ustrip.(u, v)
        return u
    else
        return Unitful.NoUnits
    end
end
# If supplied, use the unit (optional 3rd argument)
function ustripattribute!(attr, key, u)
    if haskey(attr, key)
        v = attr[key]
        if eltype(v) <: Quantity
            attr[key] = _ustrip.(u, v)
        end
    end
    u
end

#=======================================
Label string containing unit information
=======================================#

abstract type AbstractProtectedString <: AbstractString end
struct ProtectedString{S} <: AbstractProtectedString
    content::S
end
struct UnitfulString{S,U} <: AbstractProtectedString
    content::S
    unit::U
end
# Minimum required AbstractString interface to work with Plots
const S = AbstractProtectedString
Base.iterate(n::S) = iterate(n.content)
Base.iterate(n::S, i::Integer) = iterate(n.content, i)
Base.codeunit(n::S) = codeunit(n.content)
Base.ncodeunits(n::S) = ncodeunits(n.content)
Base.isvalid(n::S, i::Integer) = isvalid(n.content, i)
Base.pointer(n::S) = pointer(n.content)
Base.pointer(n::S, i::Integer) = pointer(n.content, i)
"""
    P_str(s)

Creates a string that will be Protected from recipe passes.

Example:
```julia
julia> plot(rand(10)*u"m", xlabel=P"This label is protected")

julia> plot(rand(10)*u"m", xlabel=P"This label is not")
```
"""
macro P_str(s)
    return ProtectedString(s)
end


#=====================================
Append unit to labels when appropriate
=====================================#

function append_unit_if_needed!(attr, key, u::Union{Unitful.Units, Unitful.MixedUnits})
    label = get(attr, key, nothing)
    append_unit_if_needed!(attr, key, label, u)
end
# dispatch on the type of `label`
append_unit_if_needed!(attr, key, label::ProtectedString, u) = nothing
append_unit_if_needed!(attr, key, label::UnitfulString, u) = nothing
function append_unit_if_needed!(attr, key, label::Nothing, u)
    attr[key] = UnitfulString(string(u), u)
end
function append_unit_if_needed!(attr, key, label::S, u) where {S <: AbstractString}
    if !isempty(label)
        attr[key] = UnitfulString(S(format_unit_label(label, u, get(attr, :unitformat, :round))), u)
    end
end

#=============================================
Surround unit string with specified delimiters
=============================================#
format_unit_label(l, u, f::Nothing) = string(l, ' ', u)
format_unit_label(l, u, f::Function) = f(l, u)
format_unit_label(l, u, f::AbstractString) = string(l, f, u)
format_unit_label(l, u, f::NTuple{2, <:AbstractString}) = string(l, f[1], u, f[2])
format_unit_label(l, u, f::NTuple{3, <:AbstractString}) = string(f[1], l, f[2], u, f[3])
format_unit_label(l, u, f::Char) = string(l, ' ', f, ' ', u)
format_unit_label(l, u, f::NTuple{2, Char}) = string(l, ' ', f[1], u, f[2])
format_unit_label(l, u, f::NTuple{3, Char}) = string(f[1], l, ' ', f[2], u, f[3])
format_unit_label(l, u, f::Bool) = f ? format_unit_label(l, u, :round) : format_unit_label(l, u, nothing)

const UNIT_FORMATS = Dict(
                          :round => ('(', ')'),
                          :square => ('[', ']'),
                          :curly => ('{', '}'),
                          :angle => ('<', '>'),
                          :slash => '/',
                          :slashround => (" / (", ")"),
                          :slashsquare => (" / [", "]"),
                          :slashcurly => (" / {", "}"),
                          :slashangle => (" / <", ">"),
                          :verbose => " in units of ",
                         )

format_unit_label(l, u, f::Symbol) = format_unit_label(l,u,UNIT_FORMATS[f])

#=====================================
Placeholder functions for consistent
=====================================#

function _ustrip(u, x)
    if eltype(x) <: Level
        ustrip(uconvert(u, x))
    elseif eltype(x) <: Gain
        getfield(uconvert(u, x), :val)
    elseif u isa MixedUnits
        x = uconvert(u, x) # convert Quantity -> LogScaled
        if eltype(x) <: Level
            ustrip(uconvert(u, x))
        elseif eltype(x) <: Gain
            getfield(uconvert(u, x), :val)
        end
    else
        ustrip(u, x)
    end
end

function _unit(x)
    t = eltype(x)
    u = t <: LogScaled ? logunit(t) : unit(t)
end

end # module
