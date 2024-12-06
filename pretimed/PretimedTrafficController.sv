// Package to define enums and parameters
package TrafficPackage;
    typedef enum logic [2:0] {
        NS_CROSS_GREEN,  
        NS_CROSS_YELLOW, 
        NS_ROAD_GREEN,   
        NS_ROAD_YELLOW,  
        EW_CROSS_GREEN, 
        EW_CROSS_YELLOW,
        EW_ROAD_GREEN,   
        EW_ROAD_YELLOW 
    } state_t;

    // Signal colors
    typedef enum logic [2:0] {
        RED    = 3'b100,
        YELLOW = 3'b010,
        GREEN  = 3'b001
    } signal_t;

endpackage

// Interface for traffic signal control
interface TrafficSignalInterface;
    logic [2:0] crossing;
    logic [2:0] road;
    logic [2:0] pedestrian;
endinterface

// Pretimed Traffic Controller module
module PretimedTrafficController (
    input logic clk,       
    input logic reset,      
    TrafficSignalInterface NS_signals, // North-South signals
    TrafficSignalInterface EW_signals  // East-West signals
);

    import TrafficPackage::*;

    // State and timer declarations
    state_t current_state, next_state;
    logic [6:0] timer;

    // State transition logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= NS_CROSS_GREEN;
            timer <= 7'd0;
        end else begin
            current_state <= next_state; 
            timer <= (timer == 7'd120) ? 7'd0 : timer + 1;
        end
    end

    // Next state logic
    always_comb begin
        next_state = current_state; 
        unique case (current_state)
            NS_CROSS_GREEN:  if (timer >= 7'd25)  next_state = NS_CROSS_YELLOW;
            NS_CROSS_YELLOW: if (timer >= 7'd30)  next_state = NS_ROAD_GREEN;
            NS_ROAD_GREEN:   if (timer >= 7'd55)  next_state = NS_ROAD_YELLOW;
            NS_ROAD_YELLOW:  if (timer >= 7'd60)  next_state = EW_CROSS_GREEN;
            EW_CROSS_GREEN:  if (timer >= 7'd85)  next_state = EW_CROSS_YELLOW;
            EW_CROSS_YELLOW: if (timer >= 7'd90)  next_state = EW_ROAD_GREEN;
            EW_ROAD_GREEN:   if (timer >= 7'd115) next_state = EW_ROAD_YELLOW;
            EW_ROAD_YELLOW:  if (timer >= 7'd120) next_state = NS_CROSS_GREEN;
        endcase
    end

    // Output logic for lights
    always_comb begin
        // Default all signals to RED
        NS_signals.crossing    = RED;
        NS_signals.road        = RED;
        NS_signals.pedestrian  = RED;
        EW_signals.crossing    = RED;
        EW_signals.road        = RED;
        EW_signals.pedestrian  = RED;

        case (current_state)
            NS_CROSS_GREEN: begin
                NS_signals.crossing = GREEN;
            end
            NS_CROSS_YELLOW: begin
                NS_signals.crossing = YELLOW;
            end
            NS_ROAD_GREEN: begin
                NS_signals.road = GREEN;
                NS_signals.pedestrian = GREEN;
            end
            NS_ROAD_YELLOW: begin
                NS_signals.road = YELLOW;
                NS_signals.pedestrian = YELLOW;
            end
            EW_CROSS_GREEN: begin
                EW_signals.crossing = GREEN;
            end
            EW_CROSS_YELLOW: begin
                EW_signals.crossing = YELLOW;
            end
            EW_ROAD_GREEN: begin
                EW_signals.road = GREEN;
                EW_signals.pedestrian = GREEN;
            end
            EW_ROAD_YELLOW: begin
                EW_signals.road = YELLOW;
                EW_signals.pedestrian = YELLOW;
            end
        endcase
    end

endmodule
