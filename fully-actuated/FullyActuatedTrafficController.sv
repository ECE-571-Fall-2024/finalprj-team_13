// Package to define states and signal colors
package TrafficPackage;
    typedef enum logic [2:0] {
        IDLE,            // Default state
        NS_GREEN,        // North-South green light
        NS_YELLOW,       // North-South yellow light
        EW_GREEN,        // East-West green light
        EW_YELLOW,       // East-West yellow light
        NS_PED_GREEN,    // North-South pedestrian green light
        EW_PED_GREEN     // East-West pedestrian green light
    } state_t;

    typedef enum logic [2:0] {
        RED    = 3'b100,
        YELLOW = 3'b010,
        GREEN  = 3'b001
    } signal_t;
endpackage

// Interface for traffic signals
interface TrafficSignalInterface;
    logic [2:0] light;        // Traffic light {Red, Yellow, Green}
    logic [2:0] ped_light;    // Pedestrian light {Red, Yellow, Green}
endinterface

// Fully Actuated Traffic Controller
module FullyActuatedTrafficController (
    input logic clk,           
    input logic reset,         
    input logic NS_car_detect,  
    input logic EW_car_detect,  
    input logic NS_ped_button, 
    input logic EW_ped_button,  
    TrafficSignalInterface NS_signals,
    TrafficSignalInterface EW_signals  
);

    import TrafficPackage::*; // Import package for states and signal colors

    // FSM state and timer declarations
    state_t current_state, next_state;
    logic [5:0] timer; 

    // State transition logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            timer <= 6'd0;
        end else begin
            timer <= (timer == 6'd30) ? 6'd0 : timer + 1;
            current_state <= next_state;
        end
    end

    // Next state logic
    always_comb begin
        next_state = current_state; // Default to same state
        unique case (current_state)
            IDLE: begin
                if (NS_car_detect || NS_ped_button) next_state = NS_GREEN;
                else if (EW_car_detect || EW_ped_button) next_state = EW_GREEN;
                else if (NS_car_detect == 0 && EW_car_detect == 0) next_state = NS_GREEN; // Default fallback
            end
            NS_GREEN: begin
                if (timer >= 6'd25) next_state = NS_YELLOW;
            end
            NS_YELLOW: begin
                if (timer >= 6'd30) next_state = EW_GREEN;
            end
            EW_GREEN: begin
                if (timer >= 6'd25) next_state = EW_YELLOW;
            end
            EW_YELLOW: begin
                if (timer >= 6'd30) next_state = IDLE;
            end
            NS_PED_GREEN: begin
                if (timer >= 6'd25) next_state = NS_YELLOW;
            end
            EW_PED_GREEN: begin
                if (timer >= 6'd25) next_state = EW_YELLOW;
            end
        endcase
    end

    // Output logic for lights
    always_comb begin
        // Default all lights to RED
        NS_signals.light = RED;
        EW_signals.light = RED;
        NS_signals.ped_light = RED;
        EW_signals.ped_light = RED;

        case (current_state)
            NS_GREEN: begin
                NS_signals.light = GREEN;
                EW_signals.light = RED;
                NS_signals.ped_light = GREEN;
            end
            NS_YELLOW: begin
                NS_signals.light = YELLOW;
                EW_signals.light = RED;
            end
            EW_GREEN: begin
                EW_signals.light = GREEN;
                NS_signals.light = RED;
                EW_signals.ped_light = GREEN;
            end
            EW_YELLOW: begin
                EW_signals.light = YELLOW;
                NS_signals.light = RED;
            end
            NS_PED_GREEN: begin
                NS_signals.light = GREEN;
                NS_signals.ped_light = GREEN;
                EW_signals.light = RED;
            end
            EW_PED_GREEN: begin
                EW_signals.light = GREEN;
                EW_signals.ped_light = GREEN;
                NS_signals.light = RED;
            end
        endcase
    end

endmodule
