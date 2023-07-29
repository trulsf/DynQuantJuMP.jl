module DynQuantJuMP

using Reexport
@reexport using JuMP
@reexport using DynamicQuantities

const DQ = DynamicQuantities

include("dynamic_quant.jl")


end # module DynQuantJuMP
