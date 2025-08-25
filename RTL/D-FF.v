`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:29:37 11/16/2024 
// Design Name: 
// Module Name:    MY_DFF 
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
module MY_DFF(
    input D,
    input clk,
    input reset,
    output reg Q
);

    always @(posedge clk) begin
        if (reset)
				Q <= 1'b0;
		  else
				Q <= D;
			end
endmodule


