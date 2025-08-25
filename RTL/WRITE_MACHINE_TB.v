`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:55:23 12/07/2024
// Design Name:   WRITE_MACHINE_TOP_LEVEL
// Module Name:   E:/adlx/A5/JosephOmri/lab5/HOME_VER/WRITE_MACHINE_TB.v
// Project Name:  HOME_VER
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: WRITE_MACHINE_TOP_LEVEL
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module WRITE_MACHINE_TB;

	// Inputs
	reg clk;
	reg reset;
	reg ACK_N;
	reg step_en;

	// Outputs
	wire AS_N;
	wire WR_N;
	wire in_init;
	wire [1:0] current_write_state_out;
	wire stop_n_monitor;
	wire [31:0] WDO;
	wire [31:0] AO;

	// Instantiate the Unit Under Test (UUT)
	WRITE_MACHINE_TOP_LEVEL uut (
		.clk(clk), 
		.reset(reset), 
		.ACK_N(ACK_N), 
		.step_en(step_en), 
		.AS_N(AS_N), 
		.WR_N(WR_N), 
		.in_init(in_init), 
		.current_write_state_out(current_write_state_out), 
		.stop_n_monitor(stop_n_monitor), 
		.WDO(WDO), 
		.AO(AO)
	);
	

	
	always #50 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 1;
		reset = 1;
		ACK_N = 1;
		step_en = 0;

		// Wait 100 ns for global reset to finish
		#108;
      
		reset = 0;
		#200;
		step_en=1;
		#100;
		step_en=0;
		#300;
		ACK_N = 0;
		
		
		
		
		

		// Add stimulus here

	end
      
endmodule

