module UnitfulRecipes

using RecipesBase
using Unitful: Quantity, unit, ustrip, Unitful

const A = AbstractArray
const V = AbstractVector
const Q = A{<:Quantity}

key_lims(axis) = Symbol("xyz"[axis], "lims")
key_guide(axis) = Symbol("xyz"[axis], "guide")
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
    append_unit_if_needed!(attr, key_guide(axis), u)

    # colorbar_title
    if axis == 3
        append_unit_if_needed!(attr, :colorbar_title, u)
    end

    return arr
end

"""
    ProtectedString

Wrapper around a `String` to "protect" it from `recipe!` passes.

TODO: Decide the name. I suggest `ProtectedString`.
Note that I think the name is not too important at this stage,
because we can use a string macro (see `P_str` below)
"""
struct ProtectedString <: AbstractString
    content::String
end
# Minimum required AbstractString interface to work with Plots?
const S = ProtectedString
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
    ustr = string(u)
    if !(label isa ProtectedString) && (u != Unitful.NoUnits)
        if label isa Nothing # if no label then put just the unit
            attr[key] = ustr
        else # otherwise append it, only if it is not already there
            i = findlast(ustr, label)
            if (i isa Nothing) || ((last(i)≠length(label)-1) && (last(i)≠length(label)))
                attr[key] = string(label, " ($ustr)")
            end
        end
    end
    return attr
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
