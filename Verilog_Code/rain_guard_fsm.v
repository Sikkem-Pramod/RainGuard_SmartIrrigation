// File: rain_guard_fsm.v
// Description: FSM module to decide servo angle based on rain and soil conditions
// Author: Sikkem Pramod
// Date: June 2025
// Project: RainGuard – Smart Irrigation using Verilog and FPGA

module rain_guard_fsm (
    input clk,
    input reset,
    input rain_detected,
    input soil_dry,
    output reg angle_sel     // 0: Open (0°), 1: Close (90°)
);

    // FSM States
    parameter IDLE        = 2'b00,
              CHECK_SOIL  = 2'b01,
              COVER_CROP  = 2'b10,
              LEAVE_OPEN  = 2'b11;

    reg [1:0] current_state, next_state;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (!rain_detected)
                    next_state = CHECK_SOIL;
                else
                    next_state = IDLE;
            end

            CHECK_SOIL: begin
                if (rain_detected)
                    next_state = IDLE;
                else if (soil_dry)
                    next_state = LEAVE_OPEN;
                else
                    next_state = COVER_CROP;
            end

            COVER_CROP: begin
                if (rain_detected)
                    next_state = IDLE;
                else
                    next_state = COVER_CROP;
            end

            LEAVE_OPEN: begin
                if (rain_detected)
                    next_state = IDLE;
                else if (!soil_dry)
                    next_state = COVER_CROP;
                else
                    next_state = LEAVE_OPEN;
            end

            default: next_state = IDLE;
        endcase
    end

    // Output logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            angle_sel <= 1'b0;
        else begin
            case (next_state)
                IDLE:        angle_sel <= 1'b0;
                COVER_CROP:  angle_sel <= 1'b1;
                LEAVE_OPEN:  angle_sel <= 1'b0;
                CHECK_SOIL:  angle_sel <= angle_sel;  // Hold current angle
            endcase
        end
    end

endmodule
