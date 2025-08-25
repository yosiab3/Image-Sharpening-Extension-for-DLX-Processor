`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:35:04 12/07/2024 
// Design Name: 
// Module Name:    CNT32 
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
module CNT32(
    input CLK,
    input RST,
    input CE,
    output [31:0] CNT
    );


reg [31:0] CNT_S = 32'b0;

always @(posedge CLK)
     if (RST == 1)
	      CNT_S <= 32'b0;
	  else if (CE == 1) 
	      CNT_S	<= CNT_S + 32'b1;
	  else 
	      CNT_S	<= CNT_S;


assign CNT=CNT_S;			
endmodule

