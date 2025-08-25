`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:17:12 11/16/2024 
// Design Name: 
// Module Name:    slave_mux 
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
module slave_mux(
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,
    input [31:0] d,
    input [1:0] select,
    output [31:0] mux_out
	 );
	 
	 
	 
assign mux_out = (select == 2'b00) ? a :
                     (select == 2'b01) ? b :
                     (select == 2'b10) ? c :
                     d;				
endmodule
