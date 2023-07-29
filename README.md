# DynQuantJuMP.jl

This is an experimental and proof-of-concept package that allows JuMP to be
combined with units using DynamicQuantities.

Currently, the package only supports a limited set of the JuMP functionality.

Note that this version allows different units to be combined in the same expression
by converting all terms to SI base units.

## Variables

Variables are defined with units using the `@variable` macro by adding the unit
as a separate argument:
```julia
@variable(m, speed, us"m/s")
@variable(m, length, us"cm")
```

Note the use of the `us` to avoid eagerly transformation to SI base units.

## Constraints

Constraints are automatically created with units using the  `@constraint` macro
if any of the involved parameters or variables have units. If one of the variables has units, all 
variables must have units. This also includes binary variables that must be declared with an empty dimension.
```julia
period = 1.4u"s"
max_length = 1200u"m"
@constraint(m, period * speed + length  <= max_length)
```
Note that parameters in constraints must be declared with the normal `u` notation.

## Expressions and objective

Both the @expression and @objective macros will handle variables with units

## Usage

```julia
using DynQuantJuMP, HiGHS
m = Model(HiGHS.Optimizer)
@variable(m, x >= 0, us"m/s")
@variable(m, y >= 0, us"km/h")
max_speed = 60u"km/h"
@constraint(m, x + y <= max_speed)
@constraint(m, x <= 0.5y)
obj = @objective(m, Max, x + y)
optimize!(m)
println("x = $(value(x))  y = $(value(y))")
println("objective value = $(value(obj))")

#output x = 5.555555555555556 [m s⁻¹]  y = 40.0 [km h⁻¹]
#      objective value = 16.666666666666668 [m s⁻¹]
```
