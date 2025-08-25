`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:24:00 11/24/2024 
// Design Name: 
// Module Name:    rising_edge_a 
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
module rising_edge_a (
    input 	clk,
    input 	signal_in,
    output 	prev_nand_curr
);

    reg signal_prev;
	 
    always @(posedge clk) begin
			signal_prev <= signal_in;
    end
	 
	 assign prev_nand_curr = ~(signal_prev && signal_in); 

endmodule

