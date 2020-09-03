`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:17:49 08/17/2020 
// Design Name: 
// Module Name:    PIC 
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
module PIC(
	input rstn,
	input clk_24m,
	input clk_41p766k,
	input [7:0] pic_data,
   input pic_ready,
	
	input flag,
	input m2_udi,

	output pic_tx,
	output pic_bzo,
	output pic_boo
   );

wire [7:0] cmd_data;
wire [7:0] m2_recv_data;
wire [7:0] m2_data;

pic_fifo pic_cmd_fifo(
	 .rst(!rstn), 
    .wr_clk(clk_24m), 
    .rd_clk(clk_41p766k),
    .din(pic_data), 
	 
    .wr_en(pic_ready), // input wr_en
    .rd_en(cmd_rd_en), // input rd_en
	 
    .dout(cmd_data), // output [7 : 0] dout
    .full(), // output full
    .empty(cmd_fifo_empty) // output empty
);

pic_encode  pic_encode(
    .empty(cmd_fifo_empty), 
    .Rst(rstn), 
    .clock_41p766k(clk_41p766k), 
    .data(cmd_data), 
    .rd_en(cmd_rd_en), 
    .m2_bzo(pic_bzo), 
    .m2_boo(pic_boo)
    );

pic_decode pic_decode(
    .Rst(rstn), 
    .clock_system(clk_24m), 
    .m2_udi(m2_udi), 
    .recv_data_m2(m2_recv_data), 
    .recv_data_m2_finish(m2_data_recv_finish)
    );

pic_fifo pic_m2_fifo(
	 .rst(!rstn), // input rst
    .wr_clk(clk_24m), // input wr_clk
    .rd_clk(clk_24m), // input rd_clk
    .din(m2_recv_data), // input [7 : 0] din
	 
    .wr_en(m2_data_recv_finish),
    .rd_en(m2_rd_en),
    .dout(m2_data),
    .full(), 
    .empty(m2_fifo_empty)
);

contrl_tx contrl_en(
    .clock_system(clk_24m), 
    .empty(m2_fifo_empty), 
    .idle(idle), 
    .rstn(rstn), 
    .rd_en(tx_rd_en)
    );
	 
pic_tx pictx(
    .clock_system(clk_24m), 
    .data_send(m2_data), 
    .rstn(rstn),  
    .wr(tx_rd_en), 
    .idle(idle), 
    .tx(tx)
    );
endmodule
