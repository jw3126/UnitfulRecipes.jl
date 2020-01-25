module UnitfulRecipes

using RecipesBase
using Unitful: Quantity, unit, ustrip, Unitful
export @P_str

const A = AbstractArray
const V = AbstractVector
const Q = Quantity
const UA = AbstractArray{<:Q, N} where N
const UV = AbstractVector{<:Q}

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



# (index, y)
@recipe f(ys::UA) = recipe!(plotattributes, ys)
@recipe f(ys::V{<:UV}) = recipe!(plotattributes, ys)

# (x, y)
@recipe f(xs::A, ys::UA) = recipe!(plotattributes, xs, ys)
@recipe f(xs::UA, ys::A) = recipe!(plotattributes, xs, ys)
@recipe f(xs::UA, ys::UA) = recipe!(plotattributes, xs, ys)

# (x, y) where x or y is a vector of vectors
@recipe f(xs::A, ys::V{<:UV}) = recipe!(plotattributes, xs, ys)
@recipe f(xs::UV, ys::V{<:UV}) = recipe!(plotattributes, xs, ys)
@recipe f(xs::V{<:UV}, ys::A) = recipe!(plotattributes, xs, ys)
@recipe f(xs::V{<:UV}, ys::UV) = recipe!(plotattributes, xs, ys)
@recipe f(xs::V{<:UV}, ys::V{<:UV}) = recipe!(plotattributes, xs, ys)

# (x, f(x))
@recipe f(fun::Function, xs::UA) = recipe!(plotattributes, xs, fun.(xs))
@recipe f(fun::Function, xs::V{<:UV}) = recipe!(plotattributes, xs, [fun.(x) for x in xs])

# (x, y, f(x,y))
@recipe f(xs::UV, ys::UV, fun::Function) = recipe!(plotattributes, xs, ys, fun.(xs',ys))
@recipe f(xs::V, ys::UV, fun::Function) = recipe!(plotattributes, xs, ys, fun.(xs',ys))
@recipe f(xs::UV, ys::V, fun::Function) = recipe!(plotattributes, xs, ys, fun.(xs',ys))

# (x, y, z)
# all matrix/vector combinations where Nx = Ny = Nxy ≤ Nz
# (where Nx is the dimensionality of x, Ny that of y, etc.)
AAQ(N) = :(A{T,$N} where {T<:Quantity})
AA(N) = :(A{T,$N} where {T})
for Nz in 1:2, Nxy in 1:Nz
    for Ts in collect(Iterators.product(fill([AAQ, AA], 3)...))[1:end-1]
        Tx, Ty, Tz = Ts[1](Nxy), Ts[2](Nxy), Ts[3](Nz)
        @eval @recipe f(x::$Tx, y::$Ty, z::$Tz) = recipe!(plotattributes, x, y, z)
    end
end
# all vector of vector combinations
VVQ = :(V{<:V{T}} where {T<:Quantity})
VV = :(V{<:V{T}} where {T})
for Ts in collect(Iterators.product(fill([VVQ, VV], 3)...))[1:end-1]
    Tx, Ty, Tz = Ts[1], Ts[2], Ts[3]
    @eval @recipe f(x::$Tx, y::$Ty, z::$Tz) = recipe!(plotattributes, x, y, z)
end

end # module
