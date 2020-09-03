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
      input      m2_udi,     //�յ�����������
      
      output     reg[7:0] recv_data_m2,   //���յ�����������ת���ɲ�������������
      output     reg  recv_data_m2_finish
    );
    
           
parameter IDLE = 4'b0001;	//����̬
parameter START = 4'b0010;	//����һλ����
parameter RECV_HEAD = 4'b0100; //����ͬ��ͷ
parameter RECV_DATA = 4'b1000; //��������

reg[3:0] current_state, next_state; //��ǰ״̬����һ��״̬
reg[9:0] sample_counter; //��������
reg[5:0] data_counter; //����λ����
reg[2:0] headreg;	//ͬ��ͷ�Ĵ���
reg[33:0] recv_datareg; //�������ݼĴ���
reg inc_datacounter, inc_samplecounter, clr_datacounter, clr_samplecounter, clr_datareg, clr_headreg; //�����ź�
reg shift_data, shift_head, en_write, load_data;
reg m2_udi_r1; 
reg m2_udi_r2;
  
always @(posedge clock_system or negedge Rst) //�����Ĵ������������ͬ������������̬
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
  
always @(posedge clock_system or negedge Rst) //״̬���ж�
begin
	if(!Rst)
		current_state <= IDLE;
	else
		current_state <= next_state;
end
  
 always @(current_state, m2_udi_r2, sample_counter, headreg, data_counter) 
//ÿ��������ı���(��current_state)�仯ʱbegin�µı�����Ҫ���¸�ֵ,���Բ���һֱ���Ƶ�
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
			if(m2_udi_r2 == 1'b1)   //�����յ�1ʱ����START̬������������ʱΪ�͵�ƽ
				next_state = START;
		end
	START:
		if(sample_counter != 10'd288) //���ù����������ݽ��в�����ȡ�����м�ֵ��Ϊ����ʱ�̣���ȡһλ
		// Ƶ����20.833Kbps ,����ÿ��576ȡһ����
			inc_samplecounter = 1'b1;
		else
			begin
				next_state = RECV_HEAD;
				clr_samplecounter = 1'b1;
				shift_head = 1'b1; //ͬ��ͷ�Ĵ������ƣ���ʱ hedreg = 001
			end
	RECV_HEAD:
		begin
			if(sample_counter != 10'd576) 
				inc_samplecounter = 1'b1;
			else
				begin
					clr_samplecounter = 1'b1;
					shift_head = 1'b1; //ͬ��ͷ�Ĵ������ƣ���ʱ hedreg = 011
				end
				/*******************************************************************************
				    ��һ��ִ�е����ʱ�� hedreg = 011�������������if��䣬�����������������µ�
				������sample_counter�仯,��ʱcurrent_state=RECV_HEAD��������288����ʱ������һ�Σ�
				��ʱ hedreg = 111��ִ������if���
				********************************************************************************/
			if(headreg == 3'b111)  //�ж�ͬ��ͷ �Ƿ���3'b111
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
				if(data_counter != 6'd20) //�ж��Ƿ������20����
				/*************************************************
				RECV_DATA ���״ִ̬��34�Σ�����34������
				*************************************************/
					begin
						shift_data = 1'b1;
						inc_datacounter = 1'b1;
					end
				else
					begin
						clr_datacounter = 1'b1;
						load_data = 1'b1; //�����ݽ��н���
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
			if(inc_samplecounter == 1'b1)  //������������
				sample_counter <= sample_counter + 10'd1;
			if(clr_samplecounter == 1'b1)  //������������
				sample_counter <= 10'd0;
			if(inc_datacounter == 1'b1)  //���յ�������λ����
				data_counter <= data_counter + 6'd1;
			if(clr_datacounter == 1'b1)  //���յ�������λ����
				data_counter <=6'd0; 
			if(shift_head == 1'b1) //���ƣ�����ͬ��ͷ
				headreg <= {headreg[1:0],m2_udi_r2};
			if(clr_headreg == 1'b1)  //ͷ����
				headreg <= 3'd0;
			if(shift_data == 1'b1) //���ƣ���������λ
				recv_datareg <= {recv_datareg[32:0],m2_udi_r2};
			if(clr_datareg == 1'b1)  //��������
				recv_data_m2 <= 16'd0;
			if(load_data == 1'b1) //����
				begin    // recv_datareg��ǰ��λ����żУ��λ���������
				/*****************************************************
				    ������ת���ɲ������룬�����10���ǲ��������1
					��λ��λ�Ŀ����������������ĸ�λ��һ����	
					����recv_datareg�ĸ�λ�ͺͲ����������
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
