add wave -position insertpoint  \
sim:/tb_systolic/M \
sim:/tb_systolic/clk \
sim:/tb_systolic/rst \
sim:/tb_systolic/en \
sim:/tb_systolic/in1 \
sim:/tb_systolic/in2 \
sim:/tb_systolic/out

add wave -position insertpoint  \
sim:/tb_systolic/u_top/BS \
sim:/tb_systolic/u_top/M \
sim:/tb_systolic/u_top/NUMB \
sim:/tb_systolic/u_top/clk \
sim:/tb_systolic/u_top/rst \
sim:/tb_systolic/u_top/en \
sim:/tb_systolic/u_top/in1 \
sim:/tb_systolic/u_top/in2 \
sim:/tb_systolic/u_top/out \
sim:/tb_systolic/u_top/C \
sim:/tb_systolic/u_top/row \
sim:/tb_systolic/u_top/col \
sim:/tb_systolic/u_top/ib \
sim:/tb_systolic/u_top/jb \
sim:/tb_systolic/u_top/kb \
sim:/tb_systolic/u_top/state \
sim:/tb_systolic/u_top/flag \
sim:/tb_systolic/u_top/flush_cnt \
sim:/tb_systolic/u_top/clear \
sim:/tb_systolic/u_top/left \
sim:/tb_systolic/u_top/up \
sim:/tb_systolic/u_top/right \
sim:/tb_systolic/u_top/down \
sim:/tb_systolic/u_top/sum_out


add wave -position insertpoint  \
{sim:/tb_systolic/u_top/row_gen[0]/col_gen[0]/pe/clk} \
{sim:/tb_systolic/u_top/row_gen[0]/col_gen[0]/pe/rst} \
{sim:/tb_systolic/u_top/row_gen[0]/col_gen[0]/pe/clear} \
{sim:/tb_systolic/u_top/row_gen[0]/col_gen[0]/pe/left} \
{sim:/tb_systolic/u_top/row_gen[0]/col_gen[0]/pe/up} \
{sim:/tb_systolic/u_top/row_gen[0]/col_gen[0]/pe/down} \
{sim:/tb_systolic/u_top/row_gen[0]/col_gen[0]/pe/right} \
{sim:/tb_systolic/u_top/row_gen[0]/col_gen[0]/pe/sum_out} \
{sim:/tb_systolic/u_top/row_gen[0]/col_gen[0]/pe/mult_out}
