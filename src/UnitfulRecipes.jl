module UnitfulRecipes

using RecipesBase
using Unitful: Quantity, unit, ustrip

key_lims(axis) = Symbol("xyz"[axis], "lims")
key_label(axis) = Symbol("xyz"[axis], "guide")
key_unit(axis) = Symbol("xyz"[axis], "unit")

function recipe!(attr, arr)
    resolve_axis!(attr, arr, 2)
end

function recipe!(attr, arrs...)
    if haskey(attr, :marker_z)
        u = unit(eltype(attr[:marker_z]))
        attr[:marker_z] = ustrip.(u, attr[:marker_z])
        attr[:colorbar_title] = string(u)
    end
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
    ckey = (axis==3) ? :colorbar_title : key
    if haskey(attr, key)
        attr[key] = string(attr[key], " ($(string(u)))")
        attr[ckey] = attr[key]
    else
        attr[key] = string(u)
        attr[ckey] = attr[key]
    end

    return arr
end
resolve_axis!(attr, arr::AbstractArray, axis::Int) = arr # fallback

const Q = AbstractArray{<:Quantity}
const A = AbstractArray

@recipe f(ys::Q) = recipe!(plotattributes, ys)

@recipe f(xs::A, ys::Q) = recipe!(plotattributes, xs, ys)
@recipe f(xs::Q, ys::A) = recipe!(plotattributes, xs, ys)
@recipe f(xs::Q, ys::Q) = recipe!(plotattributes, xs, ys)

@recipe f(fun::Function, xs::Q) = recipe!(plotattributes, xs, fun.(xs))

# UNitful/unitless combinations for 3 arguments
AAQ(N) = :(AbstractArray{T,$N} where {T<:Quantity})
AA(N) = :(AbstractArray{T,$N} where {T})
for Nz in 1:2, Nxy in 1:Nz
    for Ts in collect(Iterators.product(fill([AAQ, AA], 3)...))[1:end-1]
        Tx, Ty, Tz = Ts[1](Nxy), Ts[2](Nxy), Ts[3](Nz)
        @eval @recipe f(x::$Tx, y::$Ty, z::$Tz) = recipe!(plotattributes, x, y, z)
    end
end

end # module
