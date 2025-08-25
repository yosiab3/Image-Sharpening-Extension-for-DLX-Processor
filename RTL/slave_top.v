`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:52:20 11/17/2024 
// Design Name: 
// Module Name:    slave_top 
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
module slave_top(
    input [31:0] slave_in_mux_0,
    input [31:0] slave_in_mux_1,
    input [31:0] slave_in_mux_2,
    input [31:0] slave_in_mux_3,
	 
    output [31:0] slave_out_mux_out,
	 
    input clk,
    input CARDSEL,
    input WR_N,
    input [9:0]  AI,
	 input reset,
    output [4:0] reg_address,
	 output SACK_N
	 
    );
	 
	 slave_control control_1(.clk(clk),.CARDSEL(CARDSEL),.WR_N(WR_N),.reset(reset),.AI(AI),
	 .reg_address(reg_address[4:0]),.SACK_N(SACK_N));
	 
	 slave_mux mux_1 (.a(slave_in_mux_0),.b(slave_in_mux_1),.c(slave_in_mux_2),.d(slave_in_mux_3),
	 .select(AI[6:5]),.mux_out(slave_out_mux_out));
	 

endmodule
