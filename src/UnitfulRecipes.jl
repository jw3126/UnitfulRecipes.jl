module UnitfulRecipes

using RecipesBase
using Unitful: Quantity, unit, ustrip

const A = AbstractArray
const V = AbstractVector
const Q = A{<:Quantity}

key_lims(axis) = Symbol("xyz"[axis], "lims")
key_label(axis) = Symbol("xyz"[axis], "guide")
key_unit(axis) = Symbol("xyz"[axis], "unit")

function recipe!(attr, arr)
    fixscatterattributes!(attr)
    resolve_axis!(attr, arr, 2)
end

function recipe!(attr, arrs...)
    fixscatterattributes!(attr)
    ntuple(length(arrs)) do axis
        arr = arrs[axis]
        resolve_axis!(attr, arr, axis)
    end
end


function fixscatterattributes!(attr)
    if haskey(attr, :marker_z)
        u = unit(eltype(attr[:marker_z]))
        attr[:marker_z] = ustrip.(u, attr[:marker_z])
        attr[:colorbar_title] = string(u)
    end
    for key in [:markersize, :line_z]
        ustripattribute!(attr, key)
    end
end


function ustripattribute!(attr, key)
    if haskey(attr, key)
        v = attr[key]
        u = unit(eltype(v))
        attr[key] = ustrip.(u, v)
    end
end




"""
    resolve_axis!(attr, arr, axis)

Return `arr` data after converting it to axis unit and stripping units.

Mutates `attr` by converting/removing unitful attributes.
"""
function resolve_axis!(attr, arr::A{T}, axis::Int) where {T<:Quantity}
    _resolve_axis!(attr, arr, T, axis)
end
function resolve_axis!(attr, arrs::A{<:A{T}}, axis::Int) where {T<:Quantity}
    [_resolve_axis!(attr, arr, T, axis) for arr in arrs]
end
resolve_axis!(attr, arr::A, axis::Int) = arr # fallback

function _resolve_axis!(attr, arr, T, axis)
    # convert (if user-provided unit) and strip unit from data
    key = key_unit(axis)
    u = pop!(attr, key, unit(T))
    arr = ustrip.(u, arr)

    # convert and strip unit from lims
    key = key_lims(axis)
    if haskey(attr, key)
        lims = attr[key]
        if lims isa NTuple{2, Quantity}
            attr[key] = ustrip.(u, lims)
        end
    end

    # get axis label and append unit
    key = key_label(axis)
    ustr = string(u)
    add_unit_if_missing!(attr, key_label(axis), ustr)

    # colorbar_title
    ckey = (axis==3) ? :colorbar_title : key_label(axis)
    add_unit_if_missing!(attr, ckey, ustr)

    return arr
end

function add_unit_if_missing!(attr, key, ustr::AbstractString)
    value = get!(attr, key, ustr)
    if !occursin(ustr, value)
        attr[key] = "$value $(ustr)"
    end
    attr
end

@recipe f(ys::Q) = recipe!(plotattributes, ys)
@recipe f(ys::V{<:Q}) = recipe!(plotattributes, ys)

@recipe f(xs::A, ys::Q) = recipe!(plotattributes, xs, ys)
@recipe f(xs::Q, ys::A) = recipe!(plotattributes, xs, ys)
@recipe f(xs::Q, ys::Q) = recipe!(plotattributes, xs, ys)

@recipe f(xs::A, ys::V{<:Q}) = recipe!(plotattributes, xs, ys)
@recipe f(xs::Q, ys::V{<:Q}) = recipe!(plotattributes, xs, ys)
@recipe f(xs::V{<:Q}, ys::A) = recipe!(plotattributes, xs, ys)
@recipe f(xs::V{<:Q}, ys::Q) = recipe!(plotattributes, xs, ys)
@recipe f(xs::V{<:Q}, ys::V{<:Q}) = recipe!(plotattributes, xs, ys)

@recipe f(fun::Function, xs::Q) = recipe!(plotattributes, xs, fun.(xs))
@recipe f(xs::A{<:Quantity,1}, ys::A{<:Quantity,1}, fun::Function) = recipe!(plotattributes, xs, ys, fun.(xs',ys))

# UNitful/unitless combinations for 3 arguments
AAQ(N) = :(A{T,$N} where {T<:Quantity})
AA(N) = :(A{T,$N} where {T})
for Nz in 1:2, Nxy in 1:Nz
    for Ts in collect(Iterators.product(fill([AAQ, AA], 3)...))[1:end-1]
        Tx, Ty, Tz = Ts[1](Nxy), Ts[2](Nxy), Ts[3](Nz)
        @eval @recipe f(x::$Tx, y::$Ty, z::$Tz) = recipe!(plotattributes, x, y, z)
    end
end

end # module
