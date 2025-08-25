`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:48:27 01/04/2025 
// Design Name: 
// Module Name:    DLX_CONTROL_STATE_MACHINE 
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
module DLX_CONTROL_STATE_MACHINE(
    input clk,
    input reset,
    input AEQZ,
    input step_en,
    input busy,
    input [31:0] IR,
    output in_init,
    output mr,
    output mw,
    output add,
    output A_en,
    output B_en,
    output C_en,
    output IR_en,
    output PC_en,
    output MDR_en,
    output MAR_en,
    output MDR_sel,
	 output A_sel,
    output DINT_sel,
    output test,
    output Itype,
    output shift,
    output right,
    output jlink,
    output GPR_WE,
    output [1:0] S1_sel,
    output [1:0] S2_sel,
    output [4:0] DLX_STATE_OUT,
	 
	 output E_en,
	 output SHARPEN_sel
	 
    );
	
	wire BRANCH_TAKEN  ;
	
		
	parameter INIT = 5'b00000 ;
	parameter FETCH = 5'b00001 ;
	parameter DECODE = 5'b00010 ;
	parameter HALT = 5'b00011 ;
	parameter ALU = 5'b00100 ;
	parameter SHIFT = 5'b00101 ;
	parameter WBR = 5'b00110 ;
	parameter ALUI = 5'b00111 ;
	parameter WBI = 5'b01000 ;
	parameter TESTI = 5'b01001 ;
	parameter ADDRESSCMP = 5'b01010 ;
	parameter LOAD = 5'b01011 ;
	parameter COPYMDR2C = 5'b01100 ;
	parameter COPYGPR2MDR = 5'b01101 ;
	parameter STORE = 5'b01110 ;
	parameter JR = 5'b01111 ;
	parameter SAVEPC = 5'b10000 ;
	parameter JALR = 5'b10001 ;
	parameter BRANCH = 5'b10010 ;
	parameter BTAKEN = 5'b10011 ;
	parameter SHARPEN = 5'b10100;
	
	reg [4:0] DLX_STATE ;
	
	always @(posedge clk)
	begin 
	if(reset)
		DLX_STATE = INIT ;
	else
	begin
	case(DLX_STATE)
		INIT : 
				if(step_en)
				begin
				DLX_STATE = FETCH ;
				end
				else 
				begin 
				DLX_STATE = INIT;
				end
	
	
		FETCH : 
					if(~busy)
					begin
					DLX_STATE = DECODE ;
					end
					else 
					begin 
					DLX_STATE = FETCH;
					end
	
		DECODE :
					if(IR[31:29] == 3'b110) // special nop operation  
					begin
						if(step_en) 
							begin
							DLX_STATE = FETCH ;
							end
							else 
							begin 
							DLX_STATE = INIT;
							end
					end
					else if (IR[31:26]==6'b000000 && IR[5:0]==6'b100000) // DNF - D0, Target - SHARPEN, R-TYPE OPERATION
								begin
								DLX_STATE = SHARPEN;
								end
	
					else if (IR[31:28]==4'b0000 && IR[5]==1'b1) // DNF - D2, Target - ALU, R-TYPE OPERATION
								begin
								DLX_STATE = ALU;
								end
	
					else if (IR[31:28]==4'b0000 && IR[5]==1'b0) // DNF - D4, Target - SHIFT, R-TYPE OPERATION
								begin
								DLX_STATE = SHIFT;
								end
					
					else if (IR[31:29]==3'b001) // DNF - D5, Target - ALUI (ADDI)
								begin
								DLX_STATE = ALUI;
								end
										
					else if (IR[31:29]==3'b011) // DNF - D6, Target - TESTI
						begin
						DLX_STATE = TESTI;
						end
					
					else if (IR[31:30]==2'b10) // DNF - D7, Target - ADR.COMP (LOAD OR STORE OPERATION)
						begin
						DLX_STATE = ADDRESSCMP;
						end

					else if (IR[31:29]==3'b010 && IR[26]==1'b0) // DNF - D8, Target - JR
						begin
						DLX_STATE = JR;
						end
						
					else if (IR[31:29]==3'b010 && IR[26]==1'b1) // DNF - D9, Target - SAVEPC
						begin
						DLX_STATE = SAVEPC;
						end
					
					
					else if (IR[31:28]==4'b0001) // DNF - D12, Target - BRANCH
						begin
						DLX_STATE = BRANCH;
						end
					
					else
						begin
						DLX_STATE = HALT;
						end
			
			SHARPEN:
					DLX_STATE = WBR;			
			ALU: 	
					DLX_STATE = WBR;
			SHIFT: 	
					DLX_STATE = WBR;
			ALUI: 	
					DLX_STATE = WBI;
			TESTI: 	
					DLX_STATE = WBI;
			
			ADDRESSCMP:
					if(IR[29]==1'b1) // DNF - D13, Target - COPYGPR2MDR, STORE COMMAND
					begin
					DLX_STATE = COPYGPR2MDR  ;
					end
					else if(IR[29]==1'b0) // DNF - /D13, Target - LOAD, LOAD COMMAND
					begin
					DLX_STATE = LOAD  ;
					end
					

		 COPYGPR2MDR:
						DLX_STATE = STORE  ;
			
		 LOAD: 
					if(~busy) 
					begin
					DLX_STATE = COPYMDR2C;
					end
					else 
					begin
					DLX_STATE = LOAD;
					end
		
		  COPYMDR2C:
					DLX_STATE = WBI;
		
		SAVEPC: 
					DLX_STATE = JALR;
				

		BRANCH: 
				if(BRANCH_TAKEN)
				begin
				DLX_STATE = BTAKEN;
				end
				else 
				begin
				if(step_en)
				begin
				DLX_STATE = FETCH ;
				end
				else 
				begin 
				DLX_STATE = INIT;
				end
				end
				
				
		WBR:
				if(step_en)
				begin
				DLX_STATE = FETCH ;
				end
				else 
				begin 
				DLX_STATE = INIT;
				end
		
		WBI:
				if(step_en)
				begin
				DLX_STATE = FETCH ;
				end
				else 
				begin 
				DLX_STATE = INIT;
				end
				
		BTAKEN:
				if(step_en)
				begin
				DLX_STATE = FETCH ;
				end
				else 
				begin 
				DLX_STATE = INIT;
				end
		
		
		JALR:
				if(step_en)
				begin
				DLX_STATE = FETCH ;
				end
				else 
				begin 
				DLX_STATE = INIT;
				end
		
		
		JR:
				if(step_en)
				begin
				DLX_STATE = FETCH ;
				end
				else 
				begin 
				DLX_STATE = INIT;
				end

	STORE:
			if(~busy)
			begin
				if(step_en)
				begin
				DLX_STATE = FETCH ;
				end
				else 
				begin 
				DLX_STATE = INIT;
				end
			end
			else
				DLX_STATE = STORE;
	
	HALT: 
			
				if(reset)
				begin
				DLX_STATE = INIT ;
				end
				else 
				begin 
				DLX_STATE = HALT;
				end
				
				
	default : 
			begin 
			DLX_STATE = INIT ;
			end
	endcase
		end
		end
		
		
		assign S1_sel[0] = DLX_STATE==ALU || DLX_STATE==TESTI || DLX_STATE==ALUI || 
			DLX_STATE==SHIFT || DLX_STATE==ADDRESSCMP || DLX_STATE==COPYMDR2C ||
			 DLX_STATE== JR ||  DLX_STATE==JALR ;
			 
		assign S1_sel[1] = DLX_STATE==COPYMDR2C || DLX_STATE==COPYGPR2MDR ; 
		
		assign S2_sel[0] = DLX_STATE== DECODE || DLX_STATE== TESTI ||
			DLX_STATE== ALUI || DLX_STATE==ADDRESSCMP|| DLX_STATE==BTAKEN ; 
			
		assign S2_sel[1] = DLX_STATE== DECODE || DLX_STATE== COPYMDR2C ||
			DLX_STATE== COPYGPR2MDR || 	DLX_STATE==JR || 
			DLX_STATE==JALR || DLX_STATE==SAVEPC ; 
			
		assign in_init  = DLX_STATE== INIT || DLX_STATE==HALT  ; 
		
		assign IR_en = DLX_STATE== FETCH ;
		
		assign PC_en = DLX_STATE== DECODE ||  DLX_STATE==BTAKEN ||
				 DLX_STATE== JR ||  DLX_STATE==JALR;
				 
		assign add = DLX_STATE== DECODE ||  DLX_STATE==BTAKEN ||
				 DLX_STATE== JR ||  DLX_STATE==JALR ||  DLX_STATE==SAVEPC ||
					 DLX_STATE== ALUI ||  DLX_STATE==ADDRESSCMP;
					 
		assign A_en =  DLX_STATE== DECODE ; 
		
		assign B_en =  DLX_STATE== DECODE ; 
		
		assign E_en =  DLX_STATE== DECODE ; 
		
		assign C_en =  DLX_STATE== ALU || DLX_STATE==TESTI || 
			DLX_STATE == ALUI || DLX_STATE== SHIFT || DLX_STATE== SAVEPC ||
			DLX_STATE == COPYMDR2C || DLX_STATE== SHARPEN;
			
		assign mr =  DLX_STATE== FETCH || DLX_STATE== LOAD ;
		
		assign mw  = DLX_STATE== STORE; 
		
		assign MAR_en =  DLX_STATE==ADDRESSCMP;
		
		assign MDR_en  = DLX_STATE== LOAD &&(~busy) || DLX_STATE== COPYGPR2MDR ; 
		
		assign MDR_sel = DLX_STATE== LOAD ;
		
		assign test = DLX_STATE== TESTI ;
		
		assign Itype  = DLX_STATE== TESTI|| DLX_STATE== ALUI ||
			DLX_STATE== WBI ; 
			
		assign shift = DLX_STATE== SHIFT;
		
		assign right = DLX_STATE== SHIFT && IR[1] ==1'b1 ; 
		
		assign A_sel =  DLX_STATE== STORE || DLX_STATE== LOAD ;
		
		assign DINT_sel  =  DLX_STATE== SHIFT ||  DLX_STATE== COPYGPR2MDR ||
			DLX_STATE == COPYMDR2C; 
			
		assign jlink =  DLX_STATE==JALR ; 
		
		assign GPR_WE =  DLX_STATE==JALR || DLX_STATE== WBI || DLX_STATE== WBR ; 
		
		assign BRANCH_TAKEN = AEQZ ^ IR[26] ; 
		
		assign DLX_STATE_OUT = DLX_STATE;
		
	   assign SHARPEN_sel = DLX_STATE== SHARPEN ;

		
endmodule