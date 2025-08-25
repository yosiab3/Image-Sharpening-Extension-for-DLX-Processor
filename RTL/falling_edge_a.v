`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:48:24 11/24/2024 
// Design Name: 
// Module Name:    falling_edge_a 
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
module falling_edge_a(
    input 	clk,
    input 	signal_in,
    output	falling_edge_detected
);

    reg signal_prev;
	 
    always @(posedge clk) begin
        signal_prev <= signal_in;
    end
	 
	 assign falling_edge_detected = ~signal_in & signal_prev;


endmodule

