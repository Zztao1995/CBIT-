`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:49:46 08/17/2020 
// Design Name: 
// Module Name:    pic_decode 
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
module pic_decode(
      input      Rst,
      input      clock_system,
      input      m2_udi,     //收到的曼码数据
      
      output     reg[7:0] recv_data_m2,   //将收到的曼码数据转换成不归零码后的数据
      output     reg  recv_data_m2_finish
    );
    
           
parameter IDLE = 4'b0001;	//空闲态
parameter START = 4'b0010;	//接收一位数据
parameter RECV_HEAD = 4'b0100; //接收同步头
parameter RECV_DATA = 4'b1000; //接收数据

reg[3:0] current_state, next_state; //当前状态和下一个状态
reg[9:0] sample_counter; //采样计数
reg[5:0] data_counter; //数据位计数
reg[2:0] headreg;	//同步头寄存器
reg[33:0] recv_datareg; //接收数据寄存器
reg inc_datacounter, inc_samplecounter, clr_datacounter, clr_samplecounter, clr_datareg, clr_headreg; //控制信号
reg shift_data, shift_head, en_write, load_data;
reg m2_udi_r1; 
reg m2_udi_r2;
  
always @(posedge clock_system or negedge Rst) //二级寄存器对输入进行同步并减少亚稳态
begin
	if(!Rst)
		begin
			m2_udi_r1 <= 1'b0;
			m2_udi_r2 <= 1'b0;
		end
	else
		begin
			m2_udi_r1 <= m2_udi;
			m2_udi_r2 <= m2_udi_r1;
		end
end
  
always @(posedge clock_system or negedge Rst) //状态的判断
begin
	if(!Rst)
		current_state <= IDLE;
	else
		current_state <= next_state;
end
  
 always @(current_state, m2_udi_r2, sample_counter, headreg, data_counter) 
//每当括号里的变量(如current_state)变化时begin下的变量都要重新赋值,所以不是一直左移的
begin
	inc_datacounter = 1'b0; 
	clr_samplecounter = 1'b0;
	inc_samplecounter = 1'b0;
	clr_datacounter = 1'b0;
	shift_data = 1'b0;
	shift_head = 1'b0;
	clr_headreg = 1'b0; 
	clr_datareg = 1'b0;
	en_write = 1'b0;
	load_data = 1'b0;
	next_state = current_state;
	
	case(current_state)
	IDLE:							
		begin
			clr_headreg = 1'b1;   
			if(m2_udi_r2 == 1'b1)   //当接收到1时进入START态，不接收数据时为低电平
				next_state = START;
		end
	START:
		if(sample_counter != 10'd288) //采用过采样对数据进行采样，取计数中间值作为采样时刻，先取一位
		// 频率是20.833Kbps ,所以每隔576取一个数
			inc_samplecounter = 1'b1;
		else
			begin
				next_state = RECV_HEAD;
				clr_samplecounter = 1'b1;
				shift_head = 1'b1; //同步头寄存器左移，此时 hedreg = 001
			end
	RECV_HEAD:
		begin
			if(sample_counter != 10'd576) 
				inc_samplecounter = 1'b1;
			else
				begin
					clr_samplecounter = 1'b1;
					shift_head = 1'b1; //同步头寄存器左移，此时 hedreg = 011
				end
				/*******************************************************************************
				    第一次执行到这的时候 hedreg = 011，不满足下面的if语句，所以跳出结束，等新的
				触发，sample_counter变化,此时current_state=RECV_HEAD，等再来288个数时再左移一次，
				此时 hedreg = 111，执行下面if语句
				********************************************************************************/
			if(headreg == 3'b111)  //判断同步头 是否是3'b111
				begin
					clr_headreg = 1'b1;
					next_state = RECV_DATA;
				end
			if(headreg == 3'b000)
				begin
					next_state = IDLE;
				end
			end
	RECV_DATA:
		if(sample_counter != 10'd576) 
			inc_samplecounter = 1'b1;
		else
			begin
				clr_samplecounter = 1'b1;
				if(data_counter != 6'd20) //判断是否接收了20个数
				/*************************************************
				RECV_DATA 这个状态执行34次，接收34个数据
				*************************************************/
					begin
						shift_data = 1'b1;
						inc_datacounter = 1'b1;
					end
				else
					begin
						clr_datacounter = 1'b1;
						load_data = 1'b1; //对数据进行解码
						en_write = 1'b1;
						next_state = IDLE;
					end
			end
	endcase
end
 
  

always@(posedge clock_system or negedge Rst)
begin
	if(!Rst)
		begin
			sample_counter <= 10'd0;
			data_counter <= 6'd0;
			headreg <= 3'd0;
			recv_data_m2 <= 16'd0;
			recv_data_m2_finish <= 1'b0;
			recv_datareg <= 34'd0;
		end
	else
		begin
			if(inc_samplecounter == 1'b1)  //采样计数递增
				sample_counter <= sample_counter + 10'd1;
			if(clr_samplecounter == 1'b1)  //采样计数清零
				sample_counter <= 10'd0;
			if(inc_datacounter == 1'b1)  //接收到的数据位递增
				data_counter <= data_counter + 6'd1;
			if(clr_datacounter == 1'b1)  //接收到的数据位清零
				data_counter <=6'd0; 
			if(shift_head == 1'b1) //左移，接收同步头
				headreg <= {headreg[1:0],m2_udi_r2};
			if(clr_headreg == 1'b1)  //头清零
				headreg <= 3'd0;
			if(shift_data == 1'b1) //左移，接收数据位
				recv_datareg <= {recv_datareg[32:0],m2_udi_r2};
			if(clr_datareg == 1'b1)  //数据清零
				recv_data_m2 <= 16'd0;
			if(load_data == 1'b1) //解码
				begin    // recv_datareg的前两位是奇偶校验位，不用输出
				/*****************************************************
				    将曼码转换成不归零码，曼码的10就是不归零码的1
					两位两位的看，不归零码和曼码的高位是一样的	
					曼码recv_datareg的高位就和不归零码相等
				*****************************************************/
//					recv_data_m2[15] <= recv_datareg[33];
//					recv_data_m2[14] <= recv_datareg[31];
//					recv_data_m2[13] <= recv_datareg[29];
//					recv_data_m2[12] <= recv_datareg[27];
//					recv_data_m2[11] <= recv_datareg[25];
//					recv_data_m2[10] <= recv_datareg[23];
//					recv_data_m2[9] <= recv_datareg[21];
//					recv_data_m2[8] <= recv_datareg[19];
					recv_data_m2[0] <= recv_datareg[2];   //////////////
					recv_data_m2[1] <= recv_datareg[4];
					recv_data_m2[2] <= recv_datareg[6];
					recv_data_m2[3] <= recv_datareg[8];
					recv_data_m2[4] <= recv_datareg[10];
					recv_data_m2[5] <= recv_datareg[12];
					recv_data_m2[6] <= recv_datareg[14];
					recv_data_m2[7] <= recv_datareg[16];					
				end
			if(en_write == 1'b1)
				recv_data_m2_finish <= 1'b1;
			else 
				recv_data_m2_finish <= 1'b0;		
		end
end

endmodule
