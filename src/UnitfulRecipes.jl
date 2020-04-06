module UnitfulRecipes

using RecipesBase
using Unitful: Quantity, unit, ustrip, Unitful
export @P_str

#const A = AbstractArray
#const V = AbstractVector
#const Q = Quantity
#const UA = AbstractArray{<:Q, N} where N
#const UV = AbstractVector{<:Q}


@recipe function f(::Type{T}, x::T) where T <: AbstractArray{<:Quantity}
    axisletter = plotattributes[:letter]
    axislabel = Symbol(axisletter, :guide)
    axislims = Symbol(axisletter, :lims)
    axisunit = Symbol(axisletter, :unit)
    u = pop!(plotattributes, axisunit, unit(eltype(x)))
    @show u
    append_unit_if_needed!(plotattributes, axislabel, u)
    fixlims!(plotattributes, axislims, u)
    fixmarkercolor!(plotattributes)
    fixmarkersize!(plotattributes)
    fixlinecolor!(plotattributes)
    ustrip.(u, x)
end





#key_lims(axis) = Symbol("xyz"[axis], "lims")
#key_guide(axis) = Symbol("xyz"[axis], "guide")
#key_unit(axis) = Symbol("xyz"[axis], "unit")
#
#function recipe!(attr, arr)
#    fixscatterattributes!(attr)
#    fixclims!(attr)
#    if get(attr, :seriestype, nothing) == :histogram
#        resolve_axis!(attr, arr, 1)
#    else
#        resolve_axis!(attr, arr, 2)
#    end
#end
#
#function recipe!(attr, arrs...)
#    fixscatterattributes!(attr)
#    fixclims!(attr)
#    ntuple(length(arrs)) do axis
#        arr = arrs[axis]
#        resolve_axis!(attr, arr, axis)
#    end
#end
#
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


#
#function fixclims!(attr)
#    if haskey(attr, :clims)
#        min, max = attr[:clims]
#        umin, umax = unit(min), unit(max)
#        attr[:clims] = (ustrip(umin, min), ustrip(umax, max))
#    end
#end
#
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
#
#
#"""
#    resolve_axis!(attr, arr, axis)
#
#Return `arr` data after converting it to axis unit and stripping units.
#
#Mutates `attr` by converting/removing unitful attributes.
#"""
#function resolve_axis!(attr, arr::A{T}, axis::Int) where {T<:Quantity}
#    _resolve_axis!(attr, arr, T, axis)
#end
#function resolve_axis!(attr, arrs::A{<:A{T}}, axis::Int) where {T<:Quantity}
#    [_resolve_axis!(attr, arr, T, axis) for arr in arrs]
#end
#resolve_axis!(attr, arr::A, axis::Int) = arr # fallback
#
#function _resolve_axis!(attr, arr, T, axis)
#    # convert (if user-provided unit) and strip unit from data
#    key = key_unit(axis)
#    u = pop!(attr, key, unit(T))
#    arr = ustrip.(u, arr)
#
#    # convert and strip unit from lims
#    key = key_lims(axis)
#    if haskey(attr, key)
#        lims = attr[key]
#        if lims isa NTuple{2, Quantity}
#            attr[key] = ustrip.(u, lims)
#        end
#    end
#
#    # get axis label and append unit
#    append_unit_if_needed!(attr, key_guide(axis), u)
#
#    # colorbar_title
#    if axis == 3
#        append_unit_if_needed!(attr, :colorbar_title, u)
#    end
#
#    return arr
#end


#======
Strings
======#

abstract type AbstractProtectedString <: AbstractString end
"""
    ProtectedString

Wrapper around a `String` to "protect" it from `recipe!` passes.
"""
struct ProtectedString <: AbstractProtectedString
    content::String
end
struct UnitfulString{U} <: AbstractProtectedString
    content::String
    unit::U
end
# Minimum required AbstractString interface to work with Plots?
const S = AbstractProtectedString
Base.iterate(n::S) = iterate(n.content)
Base.iterate(n::S, i::Integer) = iterate(n.content, i)
Base.codeunit(n::S) = codeunit(n.content)
Base.ncodeunits(n::S) = ncodeunits(n.content)
Base.isvalid(n::S, i::Integer) = isvalid(n.content, i)
Base.pointer(n::S) = pointer(n.content)
Base.pointer(n::S, i::Integer) = pointer(n.content, i)
# macro for easy-to-use interface?
# i.e., so that `P"foo"` creates `ProtectedString("foo")`
macro P_str(s)
    return ProtectedString(s)
end


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
