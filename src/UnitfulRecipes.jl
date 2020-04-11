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
    if length(attr[:plot_object].subplots) > 0
        label = attr[:plot_object][end][axis][:guide]
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
#@recipe f(xs::V, ys::UV, fun::Function) = recipe!(plotattributes, xs, ys, fun.(xs',ys))
#@recipe f(xs::UV, ys::V, fun::Function) = recipe!(plotattributes, xs, ys, fun.(xs',ys))
#


#==============
Attibute fixing
==============#

function fixmarkercolor!(attr)
    u = ustripattribute!(attr, :marker_z)
    fixlims!(attr, :clims, u)
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
end
# dispatch on the type of `label`
append_unit_if_needed!(attr, key, label::ProtectedString, u) = nothing
append_unit_if_needed!(attr, key, label::UnitfulString, u) = nothing
function append_unit_if_needed!(attr, key, label::Nothing, u)
    attr[key] = UnitfulString(string(u), u)
end
function append_unit_if_needed!(attr, key, label::String, u)
    if label ≠ ""
        attr[key] = UnitfulString(string(label, " (", u, ")"), u)
    end
end

end # module
