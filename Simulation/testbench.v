`timescale 1ns / 1ps 

module tb_top_module;

  // Inputs to the top_module
  reg clk;
  reg reset;
  reg rain_in;
  reg soil_sensor_digital;

  // Output from the top_module
  wire servo_pwm_out;

  // Internal wire to monitor FSM output controlling PWM (for debugging)
  wire angle_sel_monitor;

  // Instantiate the Device Under Test (DUT)
  top_module dut (
    .clk(clk),
    .reset(reset),
    .rain_in(rain_in),
    .soil_sensor_digital(soil_sensor_digital),
    .servo_pwm_out(servo_pwm_out)
  );

  // Connect internal wire to monitor the FSM's output (angle_sel)
  assign angle_sel_monitor = dut.angle_sel;

  // Clock generation
  // Directly using the value 20 for 50 MHz (20ns period, 10ns high/low)
  always begin
    clk = 1;
    #10; // Half period for 50 MHz (20ns period / 2 = 10ns)
    clk = 0;
    #10; // Half period for 50 MHz
  end

  // Test Stimulus
  initial begin
    // Initialize inputs
    reset = 1;
    rain_in = 0;
    soil_sensor_digital = 0;

    $display("----------------------------------------------------------------------------------");
    $display("Time | reset | rain_in | soil_dry | FSM_state | angle_sel | PWM_out (sample)");
    $display("----------------------------------------------------------------------------------");

    // Initial Reset Phase
    # (20 * 5); // Hold reset for 5 clock cycles (5 * 20ns = 100ns)
    $display("%0t | %b     | %b       | %b        | N/A       | %b         | %b",
             $time, reset, rain_in, soil_sensor_digital, angle_sel_monitor, servo_pwm_out);

    reset = 0; // Release reset
    $display("%0t | %b     | %b       | %b        | IDLE      | %b         | %b",
             $time, reset, rain_in, soil_sensor_digital, angle_sel_monitor, servo_pwm_out);

    // Give some time for the FSM to settle in IDLE and PWM to start in 0-degree mode
    # (2 * 20_000_000 ); // Wait for 2 full PWM periods (2 * 20ms = 40ms)
    $display("---- After 40ms in IDLE (0 degrees) ----");
    $display("%0t | %b     | %b       | %b        | IDLE      | %b         | %b",
             $time, reset, rain_in, soil_sensor_digital, angle_sel_monitor, servo_pwm_out);


    // Test Case 1: Rain starts, Soil is WET (should go to COVER_CROP)
    $display("\n--- Test Case 1: Rain starts (soil wet) -> COVER_CROP ---");
    rain_in = 1;
    soil_sensor_digital = 0; // Soil is wet
    # (20 * 2); // Wait for FSM to transition to CHECK_SOIL then COVER_CROP (2 clock cycles)
    $display("%0t | %b     | %b       | %b        | CHECK/COVER | %b         | %b",
             $time, reset, rain_in, soil_sensor_digital, angle_sel_monitor, servo_pwm_out);

    # (5 * 20_000_000 ); // Let it stay in COVER_CROP for 5 PWM periods (100ms)
    $display("---- After 100ms in COVER_CROP (90 degrees) ----");
    $display("%0t | %b     | %b       | %b        | COVER_CROP | %b         | %b",
             $time, reset, rain_in, soil_sensor_digital, angle_sel_monitor, servo_pwm_out);


    // Test Case 2: Rain stops -> IDLE
    $display("\n--- Test Case 2: Rain stops -> IDLE ---");
    rain_in = 0;
    # (20 * 2); // Wait for FSM to transition to IDLE (2 clock cycles)
    $display("%0t | %b     | %b       | %b        | IDLE      | %b         | %b",
             $time, reset, rain_in, soil_sensor_digital, angle_sel_monitor, servo_pwm_out);

    # (5 * 20_000_000 ); // Let it stay in IDLE for 5 PWM periods (100ms)
    $display("---- After 100ms in IDLE (0 degrees) ----");
    $display("%0t | %b     | %b       | %b        | IDLE      | %b         | %b",
             $time, reset, rain_in, soil_sensor_digital, angle_sel_monitor, servo_pwm_out);


    // Test Case 3: Rain starts, Soil is DRY (should go to LEAVE_OPEN)
    $display("\n--- Test Case 3: Rain starts (soil dry) -> LEAVE_OPEN ---");
    rain_in = 1;
    soil_sensor_digital = 1; // Soil is dry
    # (20 * 2); // Wait for FSM to transition to CHECK_SOIL then LEAVE_OPEN (2 clock cycles)
    $display("%0t | %b     | %b       | %b        | CHECK/LEAVE | %b         | %b",
             $time, reset, rain_in, soil_sensor_digital, angle_sel_monitor, servo_pwm_out);

    # (5 * 20_000_000 ); // Let it stay in LEAVE_OPEN for 5 PWM periods (100ms)
    $display("---- After 100ms in LEAVE_OPEN (0 degrees) ----");
    $display("%0t | %b     | %b       | %b        | LEAVE_OPEN | %b         | %b",
             $time, reset, rain_in, soil_sensor_digital, angle_sel_monitor, servo_pwm_out);


    // Test Case 4: While LEAVE_OPEN, Soil becomes WET -> COVER_CROP
    $display("\n--- Test Case 4: While LEAVE_OPEN, soil becomes WET -> COVER_CROP ---");
    rain_in = 1; // Still raining
    soil_sensor_digital = 0; // Soil becomes wet
    # (20 * 2); // Wait for FSM to transition to COVER_CROP (2 clock cycles)
    $display("%0t | %b     | %b       | %b        | COVER_CROP | %b         | %b",
             $time, reset, rain_in, soil_sensor_digital, angle_sel_monitor, servo_pwm_out);

    # (5 * 20_000_000 ); // Let it stay in COVER_CROP for 5 PWM periods (100ms)
    $display("---- After 100ms in COVER_CROP (90 degrees) ----");
    $display("%0t | %b     | %b       | %b        | COVER_CROP | %b         | %b",
             $time, reset, rain_in, soil_sensor_digital, angle_sel_monitor, servo_pwm_out);


    // Test Case 5: Quick reset to IDLE
    $display("\n--- Test Case 5: Quick Reset ---");
    reset = 1;
    rain_in = 1; // Arbitrary inputs during reset
    soil_sensor_digital = 1;
    # (20 * 3); // Hold reset for 3 clock cycles
    reset = 0;
    # (20 * 2); // Wait for FSM to settle in IDLE after reset
    $display("%0t | %b     | %b       | %b        | IDLE      | %b         | %b",
             $time, reset, rain_in, soil_sensor_digital, angle_sel_monitor, servo_pwm_out);

    # (2 * 20_000_000 ); // Final IDLE period
    $display("---- Final IDLE (0 degrees) ----");
    $display("%0t | %b     | %b       | %b        | IDLE      | %b         | %b",
             $time, reset, rain_in, soil_sensor_digital, angle_sel_monitor, servo_pwm_out);


    $display("----------------------------------------------------------------------------------");
    $display("Simulation finished.");
    $finish; // End simulation
  end

  // Dump waveforms for visualization
  initial begin
    $dumpfile("top_module_sim.vcd");
    $dumpvars(0, tb_top_module); // Dump all variables in the testbench
  end

endmodule
