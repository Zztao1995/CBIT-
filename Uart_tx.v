`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:32:47 08/17/2020 
// Design Name: 
// Module Name:    Uart_tx 
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
module pic_tx(
    input clock_system,
    input [7:0] data_send,
	 input rstn,
	 input flag,	 
    input wr,
	 
    output reg idle,
    output reg tx
    );

reg send_fg;
reg [7:0] cnt;
reg wrr0;
reg wrr1;
wire wr_riseedge;
assign wr_riseedge = ~wrr1 & wrr0;

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
	 begin
		wrr0 <= 1'b0;
		wrr1 <= 1'b0;
	 end
	 else
	 begin
		wrr0 <= wr;
		wrr1 <= wrr0;
	 end
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		send_fg <= 1'b0;
	else if(wr_riseedge &&(~idle))
		send_fg <= 1'b1;
	else if(cnt == 16'd12499)
		send_fg <= 1'b0;
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
		cnt <= 16'd1;
	else if(send_fg)
		cnt <= cnt + 16'd1;
	else 
		cnt <= 16'd0;
end

always @(posedge clock_system or negedge rstn)
begin
	if(!rstn)
	begin
		tx <= 1'b1;
		idle <= 1'b0;
	end	
	else 
	begin
		if(send_fg && flag)
			case(cnt)
				16'd0:	  begin tx <= 1'b0; end
				16'd1249:  begin tx <= data_send[0]; idle <= 1'b1; end
				16'd2499:  begin tx <= data_send[1]; idle <= 1'b1; end
				16'd3749:  begin tx <= data_send[2]; idle <= 1'b1; end
			   16'd4999:  begin tx <= data_send[3]; idle <= 1'b1; end
				16'd6249:  begin tx <= data_send[4]; idle <= 1'b1; end
			   16'd7499:  begin tx <= data_send[5]; idle <= 1'b1; end
			   16'd8749:  begin tx <= data_send[6]; idle <= 1'b1; end
				16'd9999:  begin tx <= data_send[7]; idle <= 1'b1; end
				16'd11249: begin tx <= 1'b1; idle <= 1'b1; end
				16'd12499: begin tx <= tx; idle <= 1'b0; end
			   default:	  begin tx <= tx; idle <= idle; end
			endcase
		else begin
			   tx <= 1'b1;
				idle <= 1'b0;
		end
	end
end

endmodule
