`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:00:38 08/16/2020 
// Design Name: 
// Module Name:    top 
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
module top(
	input clock_in,

	output rstn_6409,
	
	input rx,
	output tx,
	output m2_bzo,
	output m2_boo,
	
	input m2_udi,
	
	input m5_udi,
	input NVM_M5,
	input DCLK_M5,
	output CLOCK_M5,

	input m7_udi,
	input NVM_M7,
	input DCLK_M7,
	output CLOCK_M7,
	//≤‚ ‘
	output io_4,
	output io_3,
	output io_2,
	output io_1,
	output io_0,
	
	output led1,
	output led2,

	input m5_udi2,
   input m7_udi2,
   output rx_485,
	output ctl_485,
	input tx_485,

   output rx1,
	output tx1
);

wire[15:0] cmd;
wire cmd_bzo,cmd_boo;
wire pic_ready,cmd_ready;
wire [7:0] pic_data;
wire [7:0] cmd_data;

wire cmd_udi, pic_dui;
wire m2m5m7_tx;
assign rstn_6409 = rstn;
assign CLOCK_M5 = speed?clk_3m:clk_12m;
assign CLOCK_M7 = speed?clk_12m:clk_3m;
assign m2_bzo = cmd_bzo | pic_bzo;
assign m2_boo = cmd_boo | pic_boo;
assign pic_udi = flag?m2_udi:0;
assign cmd_udi = flag?0:m2_udi;
assign tx = m2m5m7_tx | pic_tx;

//≤‚ ‘
assign io_4 = NVM_M5;
assign io_3 = m2_empty;
assign io_2 = test_empty;
assign io_1 = m2_bzo;
assign io_0 = m5_udi2;

assign led1 = flag;
assign led2 = rstn;
assign rx1 = 0;
assign tx1 = 0;
assign ctl_485 = 0;
assign rx_485 = 0;

wire [15:0] m5_recv_datar;
wire [7:0] m5_data;

wire test_empty;
wire m2_empty;

clock my_clock(
    .clock_in(clock_in), 
	 .rstn(rstn),
    .clk_24m(clk_24m), 
    .clk_12m(clk_12m), 
    .clk_3m(clk_3m), 
    .clk_1m(clk_1m), 
    .clk_41p766k(clk_41p766k)
    );
	 
rst my_rst(
    .clock_in(clk_24m), 
    .rstn(rstn)
    );
	 
Uart_rx my_rx(
    .clock_system(clk_24m), 
    .rstn(rstn), 
    .rx(rx), 
    .pic_readyr(pic_ready), 
    .cmd_readyr(cmd_ready), 
    .pic_datar(pic_data), 
    .cmd_datar(cmd_data), 
    .flag(flag)
    );
	 
CMD my_cmd(
    .rstn(rstn), 
    .clk_24m(clk_24m), 
    .clk_41p766k(clk_41p766k), 
    .data(cmd_data), 
    .data_ready(cmd_ready), 
    .cmd(cmd), 
    .bzo(cmd_bzo), 
    .boo(cmd_boo)
    );

Switch swap_speed(
    .rstn(rstn), 
    .clk_24m(clk_24m), 
    .cmd(cmd), 
    .speed(speed)
    );


PIC my_pic(
    .rstn(rstn), 
    .clk_24m(clk_24m), 
    .clk_41p766k(clk_41p766k), 
    .pic_data(pic_data), 
    .pic_ready(pic_ready), 
    .flag(flag), 
    .m2_udi(pic_udi), 
    .pic_tx(pic_tx), 
    .pic_bzo(pic_bzo), 
    .pic_boo(pic_boo)
    );

UPLOAD  my_upload(
    .rstn(rstn), 
    .clk_24m(clk_24m), 
    .m2_udi(cmd_udi), 
    .m5_udi(m5_udi), 
    .NVM_M5(NVM_M5), 
    .DCLK_M5(DCLK_M5), 
    .CLOCK_M5(CLOCK_M5), 
    .m7_udi(m7_udi), 
    .NVM_M7(NVM_M7), 
    .DCLK_M7(DCLK_M7), 
    .CLOCK_M7(CLOCK_M7), 
    .cmd(cmd), 
    .m2_m5_m7_tx(m2m5m7_tx),
	 //≤‚ ‘
	 .test_empty(test_empty),
//	 .m5_recv_datar(m5_recv_datar)
	 .m5_data(),
	 .m2_empty(m2_empty)
    );
endmodule
