struct ScaledQuantity{T,D} <: DQ.AbstractQuantity{T,D}
    value::T
    dimensions::D
    scale::Float64
    unit::Union{Nothing, DQ.Quantity}
end

ScaledQuantity(value, dim) = ScaledQuantity(value, dim, 1.0, nothing)


function Base.show(io::IO, q::ScaledQuantity)
    expr = DQ.ustrip(q)
    if isnothing(q.unit)
        print(io, "$(expr / q.scale) [$(DQ.dimension(q))]") 
        return
    end   
    print(io, "$(expr / q.scale) [$(DQ.dimension(q.unit))]")
end


struct _ScaledVariable <: JuMP.AbstractVariable
    variable::JuMP.ScalarVariable
    unit::DQ.Quantity
end

function JuMP.build_variable(
    ::Function,
    info::JuMP.VariableInfo,
    unit::DQ.Quantity,
) 
    return _ScaledVariable(JuMP.ScalarVariable(info), unit)
end

function JuMP.build_variable(
    ::Function,
    info::JuMP.VariableInfo,
    dim::DQ.Dimensions,
) 
    return _ScaledVariable(JuMP.ScalarVariable(info), DQ.Quantity(1.0, dim))
end

function JuMP.add_variable(
    model::JuMP.Model,
    x::_ScaledVariable,
    name::String,
) 
    variable = JuMP.add_variable(model, x.variable, name)
    q = convert(DQ.Quantity{Float64,DQ.Dimensions}, x.unit)
    scale = DQ.ustrip(q)
    return ScaledQuantity(scale * variable, DQ.dimension(q), scale, x.unit) 
end

function JuMP.value(q::ScaledQuantity{JuMP.AffExpr})
    expr = DQ.ustrip(q)
    return ScaledQuantity(JuMP.value(expr), DQ.dimension(q), q.scale, q.unit)
end

struct _DQConstraint <: JuMP.AbstractConstraint
    constraint::JuMP.ScalarConstraint
    dim::DQ.Dimensions
end

function JuMP.build_constraint(
    _error::Function,
    expr::ScaledQuantity{JuMP.AffExpr},
    set::MOI.AbstractScalarSet,
) 
    return _DQConstraint(
        JuMP.build_constraint(_error, DQ.ustrip(expr), set),
        DQ.dimension(expr),
    )
end

function JuMP.add_constraint(
    model::JuMP.Model,
    c::_DQConstraint,
    name::String,
)
    constraint = JuMP.add_constraint(model, c.constraint, name)
    return ScaledQuantity(constraint, c.dim)
end

function JuMP.set_objective(model::JuMP.AbstractModel, sense::MOI.OptimizationSense, func::ScaledQuantity{JuMP.AffExpr})
    JuMP.set_objective(model, sense, DQ.ustrip(func))
end

Base.show(io::IO, con::ScaledQuantity{<:JuMP.ConstraintRef}) = print(io, "$(DQ.ustrip(con)) [$(con.scale) $(DQ.dimension(con))]")
function JuMP.value(con::ScaledQuantity{<:JuMP.ConstraintRef})
    return DQ.Quantity(JuMP.value(DQ.ustrip(con)), DQ.dimension(con))
end