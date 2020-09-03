`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:35:11 08/17/2020 
// Design Name: 
// Module Name:    contrl_tx 
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
module contrl_tx(
	input clock_system,
	input empty,
	input idle,
	input rstn,
	output reg rd_en
    );
	
	parameter IDLE = 4'b0001;
	parameter RD0 = 4'b0010;
	parameter RD1 = 4'b0100;
	parameter SEND = 4'b1000;
	
	reg[3:0] current_state;
	reg[3:0] next_state;
	reg idler0;
	reg idler1;
	reg emptyr0;
	reg emptyr1;
	
	wire idle_risedge = ~idler1 & idler0;
	
	always @(posedge clock_system or negedge rstn)
	begin
		if(!rstn)
			begin
				idler0 <= 1'b0;
				idler1 <= 1'b0;
			end
		else
			begin
				idler0 <= idle;
				idler1 <= idler0;
			end
	end

	always @(posedge clock_system or negedge rstn)
	begin
		if(!rstn)
			begin
				emptyr0 <= 1'b1;
				emptyr1 <= 1'b1;
			end
		else
			begin
				emptyr0 <= empty;
				emptyr1 <= emptyr0;
			end
	end
	
	always @(posedge clock_system or negedge rstn)
	begin
		if(!rstn)
			current_state <= IDLE;
		else
			current_state <= next_state;
	end
	
	always @(idler1,emptyr1,current_state,idle_risedge)
	begin
		next_state = current_state;
		case(current_state)
		IDLE:
			if((emptyr1 == 1'b0) && (idler1 == 1'b0))
				next_state = RD0;
		RD0:
			next_state = RD1;
		RD1:
			next_state = SEND;
		SEND:
			if(idle_risedge)
			next_state = IDLE;
		endcase
	end
	
	always @(posedge clock_system or negedge rstn)
	begin
		if(!rstn)
		begin
			rd_en = 1'b0;
		end
		else
		begin
			case(next_state)
			IDLE:
				rd_en = 1'b0;
			RD0:
				rd_en = 1'b1;
			RD1:
				rd_en = 1'b0;
			SEND:
				rd_en = 1'b0;
			endcase
		end
	end

endmodule
