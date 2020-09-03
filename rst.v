`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:20:44 08/16/2020 
// Design Name: 
// Module Name:    rst 
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
module rst(
	input clock_in,
	output reg rstn
    );

reg [15:0] cnt = 0;

always@(posedge clock_in)begin
	if(cnt == 16'hbfff)
		cnt <= 16'hbffd;
	else
		cnt <= cnt + 16'b1;
end

always@(negedge clock_in)begin
	if(cnt < 16'h4fff)
		rstn <= 1'b1;
	else if( cnt > 16'hbffc)
		rstn <= 1'b1;
	else
		rstn <= 1'b0;
end

endmodule
