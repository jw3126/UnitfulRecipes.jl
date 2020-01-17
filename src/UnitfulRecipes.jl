module UnitfulRecipes

using RecipesBase
using Unitful:Quantity, unit, uconvert, ustrip

key_lims(axis) = Symbol("xyz"[axis], "lims")
key_label(axis) = Symbol("xyz"[axis], "guide")
key_unit(axis) = Symbol("xyz"[axis], "unit")

function recipe!(attr, arr)
    resolve_axis!(attr, arr, 2)
end

function recipe!(attr, arrs...)
    ntuple(length(arrs)) do axis
        arr = arrs[axis]
        resolve_axis!(attr, arr, axis)
    end
end

"""
    resolve_axis!(attr, arr::AbstractArray{T}, axis::Int)) where {T<:Quantity}

Return `arr` data after converting it to axis unit and stripping units.

Mutates `attr` by converting/removing unitful attributes.
"""
function resolve_axis!(attr, arr::AbstractArray{T}, axis::Int) where {T<:Quantity}
    # convert (if user-provided unit) and strip unit from data
    key = key_unit(axis)
    if haskey(attr, key)
        u = attr[key] # 
        delete!(attr, key)
    else
        u = unit(T)
    end
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
    if haskey(attr, key)
        attr[key] = string(attr[key], " ($(string(u)))")
    else
        attr[key] = string(u)
    end
    return arr
end
resolve_axis!(attr, arr::AbstractArray, axis::Int) = arr # fallback

const Q = AbstractArray{<:Quantity}
const A = AbstractArray

@recipe plot(ys::Q) = recipe!(plotattributes, ys)

@recipe plot(xs::A, ys::Q) = recipe!(plotattributes, xs, ys)
@recipe plot(xs::Q, ys::A) = recipe!(plotattributes, xs, ys)
@recipe plot(xs::Q, ys::Q) = recipe!(plotattributes, xs, ys)

@recipe plot(xs::A, ys::A, zs::Q) = recipe!(plotattributes, xs, ys, zs)
@recipe plot(xs::A, ys::Q, zs::A) = recipe!(plotattributes, xs, ys, zs)
@recipe plot(xs::A, ys::Q, zs::Q) = recipe!(plotattributes, xs, ys, zs)
@recipe plot(xs::Q, ys::A, zs::A) = recipe!(plotattributes, xs, ys, zs)
@recipe plot(xs::Q, ys::A, zs::Q) = recipe!(plotattributes, xs, ys, zs)
@recipe plot(xs::Q, ys::Q, zs::A) = recipe!(plotattributes, xs, ys, zs)
@recipe plot(xs::Q, ys::Q, zs::Q) = recipe!(plotattributes, xs, ys, zs)
@recipe plot(f::Function, xs::Q) = recipe!(plotattributes, xs, f.(xs))

end # module
