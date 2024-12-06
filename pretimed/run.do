vlog +define+DEBUG PretimedTrafficController.sv  PretimedTrafficController_tb.sv
vsim work.pretimed_tb
vsim -voptargs=+acc work.pretimed_tb
add wave -r /*
run -all
