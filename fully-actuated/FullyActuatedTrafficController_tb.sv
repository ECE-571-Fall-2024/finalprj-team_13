`timescale 1s / 1ms

module FullyActuatedTrafficController_tb;

    logic clk;
    logic reset;
    logic NS_car_detect;
    logic EW_car_detect;
    logic NS_ped_button;
    logic EW_ped_button;

    // Interfaces for the traffic signals
    TrafficSignalInterface NS_signals();
    TrafficSignalInterface EW_signals();

    // Instantiate the DUT
    FullyActuatedTrafficController dut (
        .clk(clk),
        .reset(reset),
        .NS_car_detect(NS_car_detect),
        .EW_car_detect(EW_car_detect),
        .NS_ped_button(NS_ped_button),
        .EW_ped_button(EW_ped_button),
        .NS_signals(NS_signals),
        .EW_signals(EW_signals)
    );

    always #5 clk = ~clk;

    task check_state(
        input [2:0] expected_NS_light,
        input [2:0] expected_EW_light,
        input [2:0] expected_NS_ped_light,
        input [2:0] expected_EW_ped_light
    );
        if ({NS_signals.light, EW_signals.light, NS_signals.ped_light, EW_signals.ped_light} !== 
            {expected_NS_light, expected_EW_light, expected_NS_ped_light, expected_EW_ped_light}) begin
            $error("At time %t: Expected {%b, %b, %b, %b}, Got {%b, %b, %b, %b}",
                   $time,
                   expected_NS_light, expected_EW_light, expected_NS_ped_light, expected_EW_ped_light,
                   NS_signals.light, EW_signals.light, NS_signals.ped_light, EW_signals.ped_light);
        end else begin
            $display("At time %t: Test Passed for state {%b, %b, %b, %b}",
                     $time,
                     NS_signals.light, EW_signals.light, NS_signals.ped_light, EW_signals.ped_light);
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        NS_car_detect = 0;
        EW_car_detect = 0;
        NS_ped_button = 0;
        EW_ped_button = 0;

        #10 reset = 0;

        // Test car detection in NS direction
        NS_car_detect = 1;
        #10;
        check_state(3'b001, 3'b100, 3'b001, 3'b100); // NS green, NS pedestrian green
        #250;
        check_state(3'b010, 3'b100, 3'b100, 3'b100); // NS yellow
        NS_car_detect = 0;

        // Test car detection in EW direction
        EW_car_detect = 1;
        #50;
        check_state(3'b100, 3'b001, 3'b100, 3'b001); // EW green, EW pedestrian green
        #280;
        check_state(3'b100, 3'b010, 3'b100, 3'b100); // EW yellow
        EW_car_detect = 0;

        // Test pedestrian button for NS
        NS_ped_button = 1;
        #50;
        check_state(3'b001, 3'b100, 3'b001, 3'b100); // NS green, NS pedestrian green
        #250;
        check_state(3'b010, 3'b100, 3'b100, 3'b100); // NS yellow
        NS_ped_button = 0;

        // Test pedestrian button for EW
        EW_ped_button = 1;
        #50;
        check_state(3'b100, 3'b001, 3'b100, 3'b001); // EW green, EW pedestrian green
        #250;
        check_state(3'b100, 3'b010, 3'b100, 3'b100); // EW yellow
        EW_ped_button = 0;

        // Default fallback behavior
        #50;
        check_state(3'b100, 3'b100, 3'b100, 3'b100); // Default Idle

        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1);
    end

endmodule
