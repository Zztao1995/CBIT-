`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:09:54 08/17/2020 
// Design Name: 
// Module Name:    UPLOAD 
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
module UPLOAD(
	input rstn,
	input clk_24m,
	
	input m2_udi,
	
	input m5_udi,
	input NVM_M5,
	input DCLK_M5,
	output CLOCK_M5,

	input m7_udi,
	input NVM_M7,
	input DCLK_M7,
	output CLOCK_M7,

	input [15:0] cmd,
	output m2_m5_m7_tx,
	
	output test_empty,
	output [7:0] m5_data,
	output m2_empty
   );

wire tx_wr;
wire idle;
wire m2_data_ready;
wire m5_data_ready;
wire m7_data_ready;

wire [7:0] m2_data;
wire [7:0] m5_data;
wire [7:0] m7_data;
wire [7:0] tx_data;
wire m2_empty;
wire m5_empty;
wire m7_empty;
wire [15:0] m2_recv_data;
wire [15:0] m5_recv_data;
wire [15:0] m7_recv_data;

wire [15:0] m2_recv_datar;
wire [15:0] m5_recv_datar;
wire [15:0] m7_recv_datar;

assign tx_wr = m2_rden | m5_rden | m7_rden;

//assign m2_recv_datar[15:8] = m2_recv_data[7:0];
//assign m2_recv_datar[7:0] = m2_recv_data[15:8];
//
//assign m5_recv_datar[15:8] = m5_recv_data[7:0];
//assign m5_recv_datar[7:0] = m5_recv_data[15:8];
//
//assign m7_recv_datar[15:8] = m7_recv_data[7:0];
//assign m7_recv_datar[7:0] = m7_recv_data[15:8];

assign m2_recv_datar[15:0] = m2_recv_data[15:0];
assign m5_recv_datar[15:0] = m5_recv_data[15:0];
assign m7_recv_datar[15:0] = m7_recv_data[15:0];

//≤‚ ‘
assign test_empty = m5_empty;

select select(
    .rstn(rstn), 
    .clk_24m(clk_24m), 
    .cmd(cmd), 
    .m2_empty(m2_empty), 
    .m5_empty(m5_empty), 
    .m7_empty(m7_empty), 
    .m2_data(m2_data), 
    .m5_data(m5_data), 
    .m7_data(m7_data), 
    .idle(idle), 

    .tx_data(tx_data), 
    .m2_rden(m2_rden), 
    .m5_rden(m5_rden), 
    .m7_rden(m7_rden)
    );

upload_tx upload_tx(
    .clock_system(clk_24m), 
    .data_send(tx_data), 
    .rstn(rstn),  
	 .wr(tx_wr),
	 
	 .idle(idle),
    .tx(m2_m5_m7_tx)
    );
//M2
decode_m2 m2(
    .clock_system(clk_24m), 
    .m2_udi(m2_udi), 
    .rstn(rstn), 
    .recv_data_m2(m2_recv_data), 
    .rden(m2_data_ready)
    );
	 
fifo_16to8  m2_fifo(
  .rst(!rstn), // input rst
  .wr_clk(clk_24m), // input wr_clk
  .rd_clk(clk_24m), // input rd_clk
  
  .din(m2_recv_datar), // input [15 : 0] din
  .wr_en(m2_data_ready), // input wr_en
  
  .rd_en(m2_rden), // input rd_en
  .dout(m2_data), // output [7 : 0] dout
  .full(), // output full
  .empty(m2_empty) // output empty
);

decode_6409 m5(
    .dclk(DCLK_M5), 
    .rstn(rstn), 
    .nvm(NVM_M5), 
    .sdo(m5_udi), 
    .clock_system(clk_24m), 
    .data_out(m5_recv_data), 
	 
    .counter(), 
    .count_en(), 
    .data_ready(m5_data_ready)
    );
	 
fifo_16to8 m5_fifo(
  .rst(!rstn), 
  .wr_clk(clk_24m), 
  .rd_clk(clk_24m), 
  .din(m5_recv_datar),
  
  .wr_en(m5_data_ready), 
  .rd_en(m5_rden), 
  
  .dout(m5_data), 
  .full(), 
  .empty(m5_empty)
);

//M7
decode_6409 m7(
    .dclk(DCLK_M7), 
    .rstn(rstn), 
    .nvm(NVM_M5), 
    .sdo(m7_udi), 
	 
    .clock_system(clk_24m), 
    .data_out(m7_recv_data), 
    .counter(), 
    .count_en(), 
    .data_ready(m7_data_ready)
    );

fifo_16to8 m7_fifo(
  .rst(!rstn), 
  .wr_clk(clk_24m),
  .rd_clk(clk_24m),
  .din(m7_recv_datar),
  
  .wr_en(m7_data_ready), 
  .rd_en(m7_rden), 
  .dout(m7_data),
  .full(), 
  .empty(m7_empty)
);
endmodule
