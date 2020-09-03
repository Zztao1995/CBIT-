`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:59:37 08/25/2020 
// Design Name: 
// Module Name:    Switch 
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
module Switch(
	input rstn,
	input clk_24m,
	input [15:0] cmd,
	
	output reg speed   // speed = 1'b0  ËÄ±¶ËÙ, speed = 1'b1 µ¥±¶ËÕ
   );

always@(posedge clk_24m or negedge rstn)
begin
	if(!rstn)
		speed <= 1'b0;
	else if(cmd == 16'hc891)
		speed <= 1'b1;
	else if(cmd == 16'hc894)
		speed <= 1'b0;
end
	
endmodule
