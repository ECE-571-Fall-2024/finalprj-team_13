vlog +define+DEBUG FullyActuatedTrafficController.sv FullyActuatedTrafficController_tb.sv 
vsim work.FullyActuatedTrafficController_tb
vsim -voptargs=+acc work.FullyActuatedTrafficController_tb
add wave -r /*
run -all
