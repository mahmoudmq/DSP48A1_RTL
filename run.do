vlib work
vlog dsp.v 
vlog dsp_tb.v
vlog ff_mux.v
vlog mux4_1.v

vsim -voptargs=+acc work.dsp_tb
add wave *
run -all
#quit -sim