module UnitfulRecipes

using RecipesBase
using Unitful:Quantity, unit, uconvert, ustrip

struct UnitFormatter{U}
    unit::U
end

(fmt::UnitFormatter)(value) = string(value, fmt.unit)

key_lims(axis) = Symbol("xyz"[axis], "lims")
key_formatter(axis) = Symbol("xyz"[axis], "formatter")
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

function resolve_axis!(attr, arr::AbstractArray{<: Quantity}, axis::Int)
    key = key_unit(axis)
    if haskey(attr, key)
        u = attr[key] 
        delete!(attr, key)
    else
        u = unit(first(arr))
    end
    arr = ustrip.(u, arr)
    
    key = key_lims(axis)
    if haskey(attr, key)
        lims = attr[key]
        if lims isa NTuple{2, Quantity}
            attr[key] = ustrip.(u, lims)
        end
    end
    
    key = key_formatter(axis)
    attr[key] = UnitFormatter(u)
    return arr
end

function resolve_axis!(attr, arr::AbstractArray, axis::Int)
    arr
end

const Q = AbstractArray{<: Quantity}
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

end # module
