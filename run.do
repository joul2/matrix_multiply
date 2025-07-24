set TOP_NAME "tb_systolic"
set RTL_FILE  "rtl.f"
set TB_FILE  "tb.f"

# 设置工作库路径
vlib work
vmap work work

# 编译RTL文件（Verilog）
vlog -timescale 1ns/10ps -f $RTL_FILE

# 编译测试平台（Testbench）
vlog -timescale 1ns/10ps -f $TB_FILE

# 启动仿真，指定顶层模块为 tb_systolic
vsim -voptargs=+acc work.$TOP_NAME

# 添加波形信号（可选，按需添加）
# add wave -r /*
# set WAVE_TOP "sim:/tb_systolic/*"
# set WAVE_TOP "sim:/tb_systolic/u_top/*"
# add wave $WAVE_TOP
# # add wave -position insertpoint sim:/tb_systolic/u_top/*
# add wave -position insertpoint  \
# sim:/tb_systolic/in1
# add wave -position insertpoint  \
# sim:/tb_systolic/in2
# add wave -position insertpoint  \
# sim:/tb_systolic/out
do wave.do


# 运行仿真（时间单位，例如运行1000ns）
run -all



# 保持波形窗口打开（可选）
# quit 
