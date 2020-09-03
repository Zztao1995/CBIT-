`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:21:05 08/17/2020 
// Design Name: 
// Module Name:    select 
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
module select(
	input rstn,
	input clk_24m,
	input [15:0] cmd,
	input m2_empty,
	input m5_empty,
	input m7_empty,
	input [7:0] m2_data,
	input [7:0] m5_data,
	input [7:0] m7_data,
	
	input idle,
	
	output reg [7:0] tx_data,
	output reg m2_rden,
	output reg m5_rden,
	output reg m7_rden
   );

reg idler0;
reg idler1;
reg m2_emptyr0;
reg m2_emptyr1;
reg m5_emptyr0;
reg m5_emptyr1;	
reg m7_emptyr0;
reg m7_emptyr1;

reg[7:0] current_state;
reg[7:0] next_state;
parameter IDLE = 11'b000_0000_0001;
parameter M2_RD0 = 11'b000_0000_0010;
parameter M2_RD1 = 11'b000_0000_0100;
parameter M5_RD0 = 11'b000_0000_1000;
parameter M5_RD1 = 11'b000_0001_0000;
parameter M7_RD0 = 11'b000_0010_0000;
parameter M7_RD1 = 11'b000_0100_0000;
parameter SEND = 11'b000_1000_0000;

parameter M2_RD2 = 11'b001_0000_0000;
parameter M5_RD2 = 11'b010_0000_0000;
parameter M7_RD2 = 11'b100_0000_0000;

wire idle_risedge = ~idler1 & idler0;

	always @(posedge clk_24m or negedge rstn)
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
	
	always @(posedge clk_24m or negedge rstn)
	begin
		if(!rstn)
			begin
				m2_emptyr0 <= 1'b1;
				m2_emptyr1 <= 1'b1;
			end
		else
			begin
				m2_emptyr0 <= m2_empty;
				m2_emptyr1 <= m2_emptyr0;
			end
	end
	
	always @(posedge clk_24m or negedge rstn)
	begin
		if(!rstn)
			begin
				m5_emptyr0 <= 1'b1;
				m5_emptyr1 <= 1'b1;
			end
		else
			begin
				m5_emptyr0 <= m5_empty;
				m5_emptyr1 <= m5_emptyr0;
			end
	end
	
	always @(posedge clk_24m or negedge rstn)
	begin
		if(!rstn)
			begin
				m7_emptyr0 <= 1'b1;
				m7_emptyr1 <= 1'b1;
			end
		else
			begin
				m7_emptyr0 <= m7_empty;
				m7_emptyr1 <= m7_emptyr0;
			end
	end

	always @(posedge clk_24m or negedge rstn)
	begin
		if(!rstn)
			current_state <= IDLE;
		else
			current_state <= next_state;
	 end
	 
always @(idler1, m2_emptyr1, m5_emptyr1, m7_emptyr1, current_state, idle_risedge)
begin
		next_state = current_state;
		case(current_state)
			IDLE:
				begin
					if((m5_emptyr1 == 1'b0) && (idler1 == 1'b0))
							next_state = M5_RD0;
					else if((m7_emptyr1 == 1'b0) && (idler1 == 1'b0))
							next_state = M7_RD0;
					else if((m2_emptyr1 == 1'b0) && (idler1 == 1'b0))
							next_state = M2_RD0;
				end
			M2_RD0:
				next_state = M2_RD1;
			M5_RD0:
				next_state = M5_RD1;	
			M7_RD0:
				next_state = M7_RD1;
			M2_RD1:
				next_state = M2_RD2;
			M5_RD1:
				next_state = M5_RD2;	
			M7_RD1:
				next_state = M7_RD2;
				
			M2_RD2:
				next_state = SEND;
			M5_RD2:
				next_state = SEND;	
			M7_RD2:
				next_state = SEND;
			SEND:
				if(idle_risedge)
				next_state = IDLE;
		endcase
end

always@(posedge clk_24m or negedge rstn)
begin
	if(!rstn)
	begin
		m2_rden <= 1'b0;
		m5_rden <= 1'b0;
		m7_rden <= 1'b0;
		tx_data <= m5_data;
	end
	else begin
		case(next_state)
		IDLE:
		begin
				m2_rden <= 1'b0;
				m5_rden <= 1'b0;
				m7_rden <= 1'b0;
		end
		M2_RD0:
				m2_rden <= 1'b1;
		M5_RD0:
				m5_rden <= 1'b1;	
		M7_RD0:
				m7_rden <= 1'b1;
				
		M2_RD1:
				m2_rden <= 1'b0;
		M5_RD1:
				m5_rden <= 1'b0;
		M7_RD1:
				m7_rden <= 1'b0;
				
		M2_RD2:
		begin
				m2_rden <= 1'b0;
				tx_data <= m2_data;
		end
		M5_RD2:
		begin
				m5_rden <= 1'b0;	
				tx_data <= m5_data;
		end
		M7_RD2:
		begin
				m7_rden <= 1'b0;
				tx_data <= m7_data;
		end
		SEND:
			begin
				m2_rden <= 1'b0;
				m5_rden <= 1'b0;
				m7_rden <= 1'b0;
			end
		endcase
	end
end

//always@(posedge clk_24m or negedge rstn)
//begin
//	if(!rstn)
//			tx_data <= m5_data;
//	else if(m5_emptyr1 == 1'b0)
//			tx_data <= m5_data;
//	else if(m7_emptyr1 == 1'b0)
//			tx_data <= m7_data;
//	else if(m2_emptyr1 == 1'b0)
//			tx_data <= m2_data;
//end
endmodule
