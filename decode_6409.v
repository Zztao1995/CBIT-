`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:14:45 08/17/2020 
// Design Name: 
// Module Name:    decode_6409 
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
module decode_6409(
	input dclk,
	input rstn,
	input nvm,
	input sdo,
	input clock_system,
	output reg [15:0] data_out,
	output reg [17:0] counter,
	output reg count_en,
	output reg data_ready
	);

reg sdo_0;
reg sdo_1;
reg dclk0;
reg dclk1;
reg [4:0] cnt;
reg cnt_en;
// reg count_en;
reg [15:0]data_reg;
wire dclk_falledge;

assign dclk_falledge = ~dclk0 &dclk1;

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		begin
			dclk0 <= 1'b0;
			dclk1 <= 1'b0;
		end
	else
		begin
			dclk0 <= dclk;
			dclk1 <= dclk0;
		end
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		begin
			sdo_0 <= 1'b0;
			sdo_1 <= 1'b0;
		end
	else
		begin
			sdo_0 <= sdo;
			sdo_1 <= sdo_0;
		end
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		cnt_en <= 1'b0;
	else if(nvm && dclk_falledge)
		cnt_en <= 1'b1;
	else
		cnt_en <= 1'b0;
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		cnt <= 1'b0;
	else if(cnt_en)
		cnt <= cnt + 5'd1;
	else if(cnt == 5'd16 || (!nvm))
		cnt <= 5'd0;
end

always @(posedge clock_system or negedge rstn)
begin
	if (!rstn)
		data_reg <=  16'd0;
	else
		if(nvm && dclk_falledge)
			data_reg <= {data_reg[14:0],sdo_1};
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		data_ready <= 1'b0;
	else if(cnt == 5'd16)
		data_ready <= 1'b1;
	else 
		data_ready <= 1'b0;
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		count_en <= 1'b0;
	else if(data_ready)
		count_en <= 1'b1;
	else
		count_en <= 1'b0;
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		counter <= 18'd0;
	else if(count_en)
		counter <= counter + 18'd1;
	else 
		counter <= counter; 
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		data_out <= 16'd0;
	else if(cnt == 5'd16)
		data_out <= data_reg;
end

endmodule
