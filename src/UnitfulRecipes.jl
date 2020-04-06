module UnitfulRecipes

using RecipesBase
using Unitful: Quantity, unit, ustrip, Unitful
export @P_str

#==========
Main recipe
==========#

@recipe function f(::Type{T}, x::T) where T <: AbstractArray{<:Quantity}
    # Attribute keys
    axisletter = plotattributes[:letter]   # x, y, or z
    axislabel = Symbol(axisletter, :guide) # xguide, yguide, zguide
    axislims = Symbol(axisletter, :lims)   # xlims, ylims, zlims
    axisunit = Symbol(axisletter, :unit)   # xunit, yunit, zunit
    # Get the unit
    u = pop!(plotattributes, axisunit, unit(eltype(x)))
    # Fix the attributes: labels, lims, marker/line stuff, etc.
    append_unit_if_needed!(plotattributes, axislabel, u)
    fixlims!(plotattributes, axislims, u)
    fixmarkercolor!(plotattributes)
    fixmarkersize!(plotattributes)
    fixlinecolor!(plotattributes)
    # Strip the unit
    ustrip.(u, x)
end


#==============
Attibute fixing
==============#

function fixmarkercolor!(attr)
    u = ustripattribute!(attr, :marker_z)
    u == Unitful.NoUnits || append_unit_if_needed!(attr, :colorbar_title, u)
end
fixmarkersize!(attr) = ustripattribute!(attr, :markersize)
fixlinecolor!(attr) = ustripattribute!(attr, :line_z)
function fixlims!(attr, key, u)
    if haskey(attr, key)
        lims = attr[key]
        if lims isa NTuple{2, Quantity}
            attr[key] = ustrip.(u, lims)
        end
    end
end

# strip unit from attribute
function ustripattribute!(attr, key)
    if haskey(attr, key)
        v = attr[key]
        u = unit(eltype(v))
        attr[key] = ustrip.(u, v)
        return u
    else
        return Unitful.NoUnits
    end
end


#===========
String stuff
===========#

abstract type AbstractProtectedString <: AbstractString end
struct ProtectedString <: AbstractProtectedString
    content::String
end
struct UnitfulString{U} <: AbstractProtectedString
    content::String
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


#=============
label modifier
=============#

function append_unit_if_needed!(attr, key, u::Unitful.Units)
    label = get(attr, key, nothing)
    append_unit_if_needed!(attr, key, label, u)
    return attr
end
# dispatch on the type of `label`
append_unit_if_needed!(attr, key, label::ProtectedString, u) = attr
function append_unit_if_needed!(attr, key, label::Nothing, u)
    attr[key] = UnitfulString(string(u), u)
    return attr
end
function append_unit_if_needed!(attr, key, label::UnitfulString, u)
    (label.unit ≠ u) && error("The unit of $key has changed!")
    return attr
end
function append_unit_if_needed!(attr, key, label::String, u)
    if label ≠ ""
        attr[key] = UnitfulString(string(label, " (", u, ")"), u)
    end
    return attr
end

end # module
