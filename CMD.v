`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:48:03 08/16/2020 
// Design Name: 
// Module Name:    CMD 
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
module CMD(
	input rstn,
	input clk_24m,
	input clk_41p766k,
	
	input [7:0]data,
	input data_ready,
	
	output [15:0] cmd,
	output bzo,
	output boo
    );

wire [15:0] dout;

fifo_8to16 cmd_fifo(
    .rst(!rstn),
    .wr_clk(clk_24m), 
    .rd_clk(clk_41p766k), 
    .din(data),
    .wr_en(data_ready), 
	 
    .rd_en(rd_en), 
    .dout(dout), 
    .full(), 
    .empty(empty) 
);

cmd_encode cmd_encode(
    .empty(empty), 
    .rstn(rstn), 
    .clock_41p766k(clk_41p766k), 
	 
    .data(dout), 
    .cmd(cmd), 
    .rd_en(rd_en), 
    .m2_bzo(bzo), 
    .m2_boo(boo)
    );
endmodule
