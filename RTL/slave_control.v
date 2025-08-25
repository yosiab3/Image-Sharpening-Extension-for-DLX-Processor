`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:21:54 11/16/2024 
// Design Name: 
// Module Name:    slave_control 
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
module slave_control(
    input clk,
    input CARDSEL,
    input WR_N,
    input [9:0] AI,
	 input reset,
    output [4:0] reg_address,
    output SACK_N
);

    wire first;
    wire D;
    wire Q1, Q2;         

    assign first = ~AI[9] & AI[8] & AI[7];
    assign D = first & CARDSEL & WR_N; 

    MY_DFF DFF_1 (.clk(clk), .D(D), .reset(reset), .Q(Q1));
    MY_DFF DFF_2 (.clk(clk), .D(Q1), .reset(reset), .Q(Q2));

    assign SACK_N = ~(Q1 & (~Q2));
    assign reg_address = AI[4:0];  

endmodule


