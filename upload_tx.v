`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:11:58 08/17/2020 
// Design Name: 
// Module Name:    upload_tx 
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
module upload_tx(
    input clock_system,
    input [7:0] data_send,
	 input rstn,
	 input wr,
    output reg idle,
    output reg tx
    );

reg send_fg;
reg [15:0] cnt;
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
	else if(wr_riseedge && (~idle))
		send_fg <= 1'b1;
	else if(cnt == 16'd520)
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
		if(send_fg)
			case(cnt)
				16'd0:	  begin tx <= 1'b0; idle <= 1'b1;end
				16'd51: 	  begin tx <= data_send[0]; idle <= 1'b1;end
				16'd103:	  begin tx <= data_send[1]; idle <= 1'b1;end
				16'd155:   begin tx <= data_send[2]; idle <= 1'b1;end
			   16'd207:   begin tx <= data_send[3]; idle <= 1'b1;end
				16'd259:   begin tx <= data_send[4]; idle <= 1'b1;end
			   16'd311:   begin tx <= data_send[5]; idle <= 1'b1;end
			   16'd363:	  begin tx <= data_send[6]; idle <= 1'b1;end
				16'd420:   begin tx <= data_send[7]; idle <= 1'b1;end
				16'd472:   begin tx <= 1'b1; idle <= 1'b1;end
				16'd520:	  begin tx <= tx; idle <= 1'b0;end
			   default:	  begin tx <= tx; idle <= idle;end
			endcase
		else begin
			   tx <= 1'b1;
				idle <= 1'b0;
		end
	end
end

endmodule
