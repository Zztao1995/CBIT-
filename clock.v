`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:03:28 08/16/2020 
// Design Name: 
// Module Name:    clock 
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
module clock(
	input clock_in,
	input rstn,
	
	output clk_24m,
	output reg clk_12m,
	output reg clk_3m,
	output reg clk_1m,
	output reg clk_41p766k
);
reg [1:0] cnt3;
reg [2:0] cnt5;
reg [3:0] cnt11;

PLL my_pll
(
    .CLK_IN1(clock_in),      
    .CLK_OUT1(clk_24m)
); 
always@(posedge clk_24m or negedge rstn)
begin
	if(!rstn)
		clk_12m <= 1'b0;
	else
		clk_12m <= ~clk_12m;
end

always@(posedge clk_24m or negedge rstn)begin
	if(!rstn)begin
		cnt3 <= 3'b0;
		clk_3m <= 1'b0;
		end 
	else if(cnt3 == 2'd3)begin
			cnt3 <= 2'b0;
			clk_3m <= ~clk_3m;
		end 
	else
		cnt3 <= cnt3 + 2'b1;
	end

always@(posedge clk_12m or negedge rstn)begin
	if(!rstn)begin
		cnt5 <= 3'b0;
		clk_1m <= 1'b0;
		end 
	else if(cnt5 == 3'd5)begin
			cnt5 <= 3'b0;
			clk_1m <= ~clk_1m;
		end else
		cnt5 <= cnt5 + 3'b1;
	end
	
always@(posedge clk_1m or negedge rstn)begin
	if(!rstn)begin
		cnt11 <= 4'b0;
		clk_41p766k <= 1'b0;
		end 
	else if(cnt11 == 4'd11)begin
			cnt11 <= 4'b0;
			clk_41p766k <= ~clk_41p766k;
		end else
		cnt11 <= cnt11 + 4'b1;
	end
endmodule
