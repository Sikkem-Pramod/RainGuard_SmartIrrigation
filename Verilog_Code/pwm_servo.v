// File: pwm_servo.v
// Description: PWM generation module to control servo motor for smart irrigation system
// Author: Sikkem Pramod
// Date: June 2025
// Project: RainGuard – Smart Irrigation using Verilog and FPGA

module pwm_servo (
    input clk,
    input reset,
    input angle_sel,        // 0: Open (0°), 1: Close (90°)
    output reg pwm_out
);

    // Constants for 50 MHz clock
    parameter PWM_PERIOD = 1_000_000;  // 20ms period (50Hz)
    parameter PULSE_0    = 50_000;     // 1ms pulse = 0°
    parameter PULSE_90   = 100_000;    // 1.5ms pulse = 90°

    reg [19:0] counter = 0;
    reg [19:0] pulse_width;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter  <= 0;
            pwm_out  <= 0;
        end else begin
            // Select pulse width based on angle selection
            case (angle_sel)
                1'b0: pulse_width <= PULSE_0;
                1'b1: pulse_width <= PULSE_90;
                default: pulse_width <= PULSE_0;
            endcase

            // Generate PWM signal
            if (counter < pulse_width)
                pwm_out <= 1;
            else
                pwm_out <= 0;

            counter <= counter + 1;
            if (counter == PWM_PERIOD - 1)
                counter <= 0;
        end
    end

endmodule

