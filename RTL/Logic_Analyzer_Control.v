`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:58:25 11/24/2024 
// Design Name: 
// Module Name:    Logic_Analyzer_Control 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Logic_Analyzer_Control(

	 input clk,
	 input reset,
    input step_en,
    input in_init,
	 input stop_n,
	 output la_run,
	 output la_we,
	 output sts_ce
	 // output [4:0] cnt_s
	 // output [7:0] sts
);

	wire rising_1_wire;
	wire falling_1_wire;
 
 
 rising_edge_a rising_1 (.clk(clk),.signal_in(in_init),.prev_nand_curr(rising_1_wire));
 
 assign la_run = (step_en|rising_1_wire);
 assign la_we = (la_run & stop_n);
 
 falling_edge_a falling_1 (.clk(clk),.signal_in(la_run),.falling_edge_detected(falling_1_wire));
 
 assign sts_ce = falling_1_wire;
 
 
endmodule
