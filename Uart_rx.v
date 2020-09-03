`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:42:44 08/16/2020 
// Design Name: 
// Module Name:    Uart_rx 
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
module Uart_rx(
	input clock_system,
	input rstn,
	input rx,
	
	output pic_readyr,
   output cmd_readyr,
   output [7:0] pic_datar,
   output [7:0] cmd_datar,
	output reg flag
   );

reg pic_ready;
reg cmd_ready;
reg [7:0] pic_data;
reg [7:0] cmd_data;

//rx数据 两种波特率都在收，但是由flag来控制
assign pic_readyr = flag?pic_ready:0;
assign pic_datar = flag?pic_data:0;

assign cmd_readyr = flag?0:cmd_ready;
assign cmd_datar = flag?0:cmd_data;

reg rxr0;
reg rxr1;
reg cmd_en;
reg pic_en;

reg [15:0] cmd_cnt;
reg [15:0] pic_cnt;
wire rx_falledge;

assign rx_falledge = ~rxr0 &rxr1;

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		begin
			rxr0 <= 1'b0;
			rxr1 <= 1'b0;
		end
	else
		begin
			rxr0 <= rx;
			rxr1 <= rxr0;
		end
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
	begin
		cmd_en <= 1'b0;
		pic_en <= 1'b0;
	end
	else if(rx_falledge)
	begin
		cmd_en <= 1'b1;
		pic_en <= 1'b1;
	end
	else if(cmd_cnt == 16'd490)
		cmd_en <= 1'b0;
	else if(pic_cnt == 16'd11870)
		pic_en <= 1'b0;
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		pic_cnt <= 16'd0;
	else if(pic_en)
		pic_cnt <= pic_cnt + 16'd1;
	else
		pic_cnt <= 16'd0;
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		cmd_cnt <= 16'd0;
	else if(cmd_en)
		cmd_cnt <= cmd_cnt + 16'd1;
	else
		cmd_cnt <= 16'd0;
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		  cmd_data <= 8'd0;
	else if(cmd_en)
		case(cmd_cnt)
			 16'd78 :  cmd_data[0] <= rxr1;
			 16'd130:  cmd_data[1] <= rxr1;
			 16'd182:  cmd_data[2] <= rxr1;
			 16'd234:  cmd_data[3] <= rxr1;
			 16'd286:  cmd_data[4] <= rxr1;
			 16'd338:  cmd_data[5] <= rxr1;
			 16'd390:  cmd_data[6] <= rxr1;
			 16'd442:  cmd_data[7] <= rxr1;
			 default:  cmd_data <= cmd_data;
		endcase
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		  pic_data <= 8'd0;
	else if(pic_en)
		case(pic_cnt)
			 16'd1875:  pic_data[0] <= rxr1;
			 16'd3125:  pic_data[1] <= rxr1;
			 16'd4375:  pic_data[2] <= rxr1;
			 16'd5625:  pic_data[3] <= rxr1;
			 16'd6875:  pic_data[4] <= rxr1;
			 16'd8125:  pic_data[5] <= rxr1;
			 16'd9375:  pic_data[6] <= rxr1;
			 16'd10625:  pic_data[7] <= rxr1;
			 default:    pic_data <= pic_data;
		endcase
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		cmd_ready <= 1'b0;
	else if(cmd_cnt == 16'd490)
		cmd_ready <= 1'b1;
	else
		cmd_ready <= 1'b0;
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		pic_ready <= 1'b0;
	else if(pic_cnt == 16'd11870)
		pic_ready <= 1'b1;
	else
		pic_ready <= 1'b0;
end

// fpga的正常模式和PIC模式全由flag来控制了,
always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		flag <= 1'b0;
	else if(pic_cnt == 16'd472 && cmd_cnt == 16'd472 && rx == 1'b0)
		flag <= 1'b1;
	else if(pic_cnt == 16'd472 && cmd_cnt == 16'd472 && rx == 1'b1)
		flag <= 1'b0;
end
endmodule
