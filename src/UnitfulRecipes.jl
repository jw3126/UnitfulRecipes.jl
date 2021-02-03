module UnitfulRecipes

using RecipesBase
using Unitful: Quantity, unit, ustrip, Unitful, dimension
export @P_str

#==========
Main recipe
==========#

@recipe function f(::Type{T}, x::T) where T <: AbstractArray{<:Quantity}
    axisletter = plotattributes[:letter]   # x, y, or z
    fixaxis!(plotattributes, x, axisletter)
end

function fixaxis!(attr, x, axisletter)
    # Attribute keys
    axislabel = Symbol(axisletter, :guide) # xguide, yguide, zguide
    axislims = Symbol(axisletter, :lims)   # xlims, ylims, zlims
    axisunit = Symbol(axisletter, :unit)   # xunit, yunit, zunit
    axis = Symbol(axisletter, :axis)       # xaxis, yaxis, zaxis
    # Get the unit
    u = pop!(attr, axisunit, unit(eltype(x)))
    # If the subplot already exists, get unit from its axis label
    sp = get(attr, :subplot, 1)
    if sp ≤ length(attr[:plot_object])
        label = attr[:plot_object][sp][axis][:guide]
        if label isa UnitfulString
            u = label.unit
        end
    end
    # Fix the attributes: labels, lims, marker/line stuff, etc.
    append_unit_if_needed!(attr, axislabel, u)
    fixlims!(attr, axislims, u)
    fixmarkercolor!(attr)
    fixmarkersize!(attr)
    fixlinecolor!(attr)
    # Strip the unit
    ustrip.(u, x)
end

# Recipe for (x::AVec, y::AVec, z::Surface) types
const AVec = AbstractVector
const AMat{T} = AbstractArray{T,2} where T
@recipe function f(x::AVec, y::AVec, z::AMat{T}) where T <: Quantity
    u = get(plotattributes, :zunit, unit(eltype(z)))
    z = fixaxis!(plotattributes, z, :z)
    append_unit_if_needed!(plotattributes, :colorbar_title, u)
    x, y, z
end

# Recipe for vectors of vectors
@recipe function f(::Type{T}, x::T) where T <: AbstractVector{<:AbstractVector{<:Quantity}}
    axisletter = plotattributes[:letter]   # x, y, or z
    [fixaxis!(plotattributes, x, axisletter) for x in x]
end

# Recipes for functions
@recipe function f(f::Function, x::T) where T <: AVec{<:Quantity}
    x, f.(x)
end
@recipe function f(x::T, f::Function) where T <: AVec{<:Quantity}
    x, f.(x)
end
@recipe function f(x::T, y::AVec, f::Function) where T <: AVec{<:Quantity}
    x, y, f.(x',y)
end
@recipe function f(x::AVec, y::T, f::Function) where T <: AVec{<:Quantity}
    x, y, f.(x',y)
end
@recipe function f(x::T1, y::T2, f::Function) where {T1<:AVec{<:Quantity}, T2<:AVec{<:Quantity}}
    x, y, f.(x',y)
end


#===============
Attribute fixing
===============#

# Markers / lines
function fixmarkercolor!(attr)
    u = ustripattribute!(attr, :marker_z)
    fixlims!(attr, :clims, u)
    u == Unitful.NoUnits || append_unit_if_needed!(attr, :colorbar_title, u)
end
fixmarkersize!(attr) = ustripattribute!(attr, :markersize)
fixlinecolor!(attr) = ustripattribute!(attr, :line_z)

# Lims
function fixlims!(attr, key, u)
    if haskey(attr, key)
        lims = attr[key]
        if lims isa NTuple{2, Quantity}
            attr[key] = ustrip.(u, lims)
        end
    end
end

# strip unit from attribute[key]
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

function append_unit_if_needed!(attr, key, u::Unitful.Units)
    label = get(attr, key, nothing)
    append_unit_if_needed!(attr, key, label, u)
end
# dispatch on the type of `label`
append_unit_if_needed!(attr, key, label::ProtectedString, u) = nothing
append_unit_if_needed!(attr, key, label::UnitfulString, u) = nothing
function append_unit_if_needed!(attr, key, label::Nothing, u)
    attr[key] = UnitfulString(replace(string(u), r"(\d+)" => s"{\1}"), u)
end
function append_unit_if_needed!(attr, key, label::S, u) where {S <: AbstractString}
    if label ≠ ""
        attr[key] = UnitfulString(S(string(label, " (", replace(string(u), r"(\d+)" => s"{\1}"), ")")), u)
        println("Key is $(key) and the value is $(attr[key]).")
        attr[key]
    end
end

end # module
