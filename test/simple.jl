using DynQuantJuMP, HiGHS

m = Model(HiGHS.Optimizer);
set_silent(m)

@variable(m, x >= 0, us"m/s")
@variable(m, y >= 0, us"km/h")
@variable(m, z, Bin, Dimensions())

max_speed = 4u"km/s"
@constraint(m, x + y  <= max_speed * z)

obj = @objective(m, Max, x + 3y)

optimize!(m)

println("obj = $(value(obj))")
println("x = $(value(x))")
println("y = $(value(y))")
println("z = $(value(z))")