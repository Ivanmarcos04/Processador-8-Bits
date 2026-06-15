transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/mlsl/Documents/Processador_8bits {C:/Users/mlsl/Documents/Processador_8bits/controller_fsm.v}
vlog -vlog01compat -work work +incdir+C:/Users/mlsl/Documents/Processador_8bits {C:/Users/mlsl/Documents/Processador_8bits/pc.v}
vlog -vlog01compat -work work +incdir+C:/Users/mlsl/Documents/Processador_8bits {C:/Users/mlsl/Documents/Processador_8bits/mar.v}
vlog -vlog01compat -work work +incdir+C:/Users/mlsl/Documents/Processador_8bits {C:/Users/mlsl/Documents/Processador_8bits/ram16x8.v}
vlog -vlog01compat -work work +incdir+C:/Users/mlsl/Documents/Processador_8bits {C:/Users/mlsl/Documents/Processador_8bits/ir.v}
vlog -vlog01compat -work work +incdir+C:/Users/mlsl/Documents/Processador_8bits {C:/Users/mlsl/Documents/Processador_8bits/accumulator_a.v}
vlog -vlog01compat -work work +incdir+C:/Users/mlsl/Documents/Processador_8bits {C:/Users/mlsl/Documents/Processador_8bits/register_b.v}
vlog -vlog01compat -work work +incdir+C:/Users/mlsl/Documents/Processador_8bits {C:/Users/mlsl/Documents/Processador_8bits/alu.v}
vlog -vlog01compat -work work +incdir+C:/Users/mlsl/Documents/Processador_8bits {C:/Users/mlsl/Documents/Processador_8bits/output_register.v}
vlog -vlog01compat -work work +incdir+C:/Users/mlsl/Documents/Processador_8bits {C:/Users/mlsl/Documents/Processador_8bits/processador_8bits.v}

