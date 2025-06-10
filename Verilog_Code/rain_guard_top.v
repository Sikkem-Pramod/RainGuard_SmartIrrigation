// File: rain_guard_top.v
// Description: Top module integrating FSM and PWM for RainGuard system
// Author: Sikkem Pramod
// Date: June 2025
// Project: RainGuard – Smart Irrigation using Verilog and FPGA

module rain_guard_top (
    input clk,
    input reset,
    input rain_in,
    input soil_sensor_digital,
    output servo_pwm_out
);

    wire angle_sel;

    // Instantiate FSM Controller
    rain_guard_fsm fsm (
        .clk(clk),
        .reset(reset),
        .rain_detected(rain_in),
        .soil_dry(soil_sensor_digital),
        .angle_sel(angle_sel)
    );

    // Instantiate PWM Generator
    pwm_servo pwm (
        .clk(clk),
        .reset(reset),
        .angle_sel(angle_sel),
        .pwm_out(servo_pwm_out)
    );

endmodule
