`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:49:33 12/07/2024 
// Design Name: 
// Module Name:    WRITE_MACHINE 
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

module WRITE_MACHINE(
    input clk,
    input reset,
    input step_en,
    input ACK_N,
    output AS_N,
	 output stop_n,
    output WR_N,
    output in_init,
	 output counter_ce,
    output [1:0] current_write_state_out
);

	 reg [1:0] current_write_state;


	 parameter stm_st0 = 2'h0; // Wait
	 parameter stm_st1 = 2'h1; // Store
	 parameter stm_st2 = 2'h2; // Wait4ACK
	 parameter stm_st3 = 2'h3; // Terminate

	always @ (posedge clk)
	begin
			 if (reset)
				  current_write_state = stm_st0;
			 else
				  case (current_write_state)
				  
						stm_st0:
							 if (step_en)
							 begin
								  current_write_state = stm_st1; // if step_en equals 1, move to state "store"
							 end
							 else
							 begin
								 current_write_state = stm_st0; // otherwise, continue to wait
							 end

						stm_st1:
								  current_write_state = stm_st2; // move to Wait4ACK

						stm_st2:
							 if (ACK_N == 0)
							 begin
								current_write_state = stm_st3; // if ACK_N equals 0, move to state "Terminate"
							 end
							 else
							 begin
								  current_write_state = stm_st2; //otherwise, continue wait for ACK
							 end

						stm_st3:
								  current_write_state = stm_st0; 

						default:
							 begin
								   current_write_state = stm_st0;

							 end
				  endcase
		end

		assign in_init = (current_write_state == stm_st0) ? 1 : 0; // in_init is high when we're on state "Wait" 
		assign AS_N = (current_write_state == stm_st0) || (current_write_state == stm_st3)  ? 1 : 0; //AS_N is high if state is "wait" or "terminate"
		assign WR_N = (current_write_state == stm_st0) || (current_write_state == stm_st3)  ? 1 : 0; // same
		assign counter_ce = (current_write_state == stm_st3) ? 1 : 0; // increase counter / address when on state "Terminate"
		assign stop_n =(current_write_state == stm_st2) ? 0 : 1;
		
		assign current_write_state_out = current_write_state;

		endmodule

