`timescale 1s / 1ms

module pretimed_tb;

    logic clk;
    logic reset;
    TrafficSignalInterface NS_signals();
    TrafficSignalInterface EW_signals();

    // Instantiate the DUT
    PretimedTrafficController dut (
        .clk(clk),
        .reset(reset),
        .NS_signals(NS_signals),
        .EW_signals(EW_signals)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task to check expected outputs
    task check_state(
        input logic [2:0] expected_NS_crossing,
        input logic [2:0] expected_NS_road,
        input logic [2:0] expected_EW_crossing,
        input logic [2:0] expected_EW_road,
        input logic [2:0] expected_NS_pedestrian,
        input logic [2:0] expected_EW_pedestrian
    );
        if ({NS_signals.crossing, NS_signals.road, EW_signals.crossing, EW_signals.road, NS_signals.pedestrian, EW_signals.pedestrian} !== 
            {expected_NS_crossing, expected_NS_road, expected_EW_crossing, expected_EW_road, expected_NS_pedestrian, expected_EW_pedestrian}) begin
            $error("At time %t: Expected {%b, %b, %b, %b, %b, %b}, Got {%b, %b, %b, %b, %b, %b}",
                   $time,
                   expected_NS_crossing, expected_NS_road, expected_EW_crossing, expected_EW_road, expected_NS_pedestrian, expected_EW_pedestrian,
                   NS_signals.crossing, NS_signals.road, EW_signals.crossing, EW_signals.road, NS_signals.pedestrian, EW_signals.pedestrian);
        end else begin
            $display("At time %t: Test Passed for state {%b, %b, %b, %b, %b, %b}",
                     $time,
                     NS_signals.crossing, NS_signals.road, EW_signals.crossing, EW_signals.road, NS_signals.pedestrian, EW_signals.pedestrian);
        end
    endtask

    // Test sequence
    initial begin
        clk = 0;
        reset = 1;

        #10 reset = 0;

        #10; // NS_CROSS_GREEN (0-25 sec)
        check_state(3'b001, 3'b100, 3'b100, 3'b100, 3'b100, 3'b100);

        #250; // NS_CROSS_YELLOW (25-30 sec)
        check_state(3'b010, 3'b100, 3'b100, 3'b100, 3'b100, 3'b100);

        #50; // NS_ROAD_GREEN (30-55 sec)
        check_state(3'b100, 3'b001, 3'b100, 3'b100, 3'b001, 3'b100);

        #250; // NS_ROAD_YELLOW (55-60 sec)
        check_state(3'b100, 3'b010, 3'b100, 3'b100, 3'b010, 3'b100);

        #50; // EW_CROSS_GREEN (60-85 sec)
        check_state(3'b100, 3'b100, 3'b001, 3'b100, 3'b100, 3'b100);

        #250; // EW_CROSS_YELLOW (85-90 sec)
        check_state(3'b100, 3'b100, 3'b010, 3'b100, 3'b100, 3'b100);

        #50; // EW_ROAD_GREEN (90-115 sec)
        check_state(3'b100, 3'b100, 3'b100, 3'b001, 3'b100, 3'b001);

        #250; // EW_ROAD_YELLOW (115-120 sec)
        check_state(3'b100, 3'b100, 3'b100, 3'b010, 3'b100, 3'b010);

        #50; // Loop back to NS_CROSS_GREEN (resetting state)
        check_state(3'b001, 3'b100, 3'b100, 3'b100, 3'b100, 3'b100);

        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1);
    end

endmodule
