using Unitful: Gain, Level, MixedUnits, LogScaled, NoUnits, uconvert
using Unitful: ustrip
export fullunit, uwstrip

#=====
Extension to Unitful.jl, required to plot LogScaled units and 
Quantities with LogScaled values (dB/Hz).

Intruduces function:
    fullunit

and adds a new method to ustrip for LogScaled units.

=====#

#=====
fullunit(x)
------------
Define new function fullunit which returns correct unit of Quantity and LogScaled.

Unitful.unit(dB/Hz) == Hz⁻¹
Unitful.unit(dB) == NoUnits
Unitful.logunit(dB/Hz) == dB

expected behavior:
fullunit(dB/Hz) == dB Hz⁻¹
fullunit(dB) == dB
fullunit(Hz) == Hz
=====#

# general argument
fullunit(x::T) where T<: Quantity = unit(x)
fullunit(x::Type{T}) where T<:Quantity = unit(x)

# gain
fullunit(x::Gain{L,S}) where {L,S} = fullunit(eltype(x))
fullunit(::Type{T}) where {L,S,T<:Gain{L,S}} = MixedUnits{Gain{L,S}}()

# level
fullunit(x::Level{L,S}) where {L,S} = fullunit(eltype(x))
fullunit(::Type{T}) where {L,S,T<:Level{L,S}} = MixedUnits{Level{L,S}}()

# quantity with mixed unit
fullunit(x::Quantity{T,D,U}) where {T<:LogScaled , D , U} = fullunit(eltype(x))
fullunit(::Type{Quantity{T, D, U}}) where {T<:LogScaled , D , U} = fullunit(T) * U()

# others from Unitful util.jl
fullunit(x::T) where T<: Number = NoUnits
fullunit(::Type{T}) where T<:Number= NoUnits
fullunit(::Type{Union{Missing, T}}) where T = fullunit(T)
fullunit(::Type{Missing}) = missing
fullunit(x::Missing) = missing


#=====
uwstrip(u, x) placeholder for ustrip
=====#
# level
uwstrip(u::T, x::L) where {T<:MixedUnits, L<:Union{Quantity, LogScaled}}  = ustrip(uconvert(u, x))
#all other
uwstrip(u, x) = ustrip(u, x)
