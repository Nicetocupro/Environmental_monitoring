`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/13 15:37:24
// Design Name: 
// Module Name: temperature
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module temperature(clk_out , rst_n ,scl ,sda , read_data , read_data1);

input clk_out,rst_n;
output scl;//������IIC�ӿ�
inout sda;//������IIC�ӿ�
output [7:0] read_data;//��λ
output [7:0] read_data1;//��λ

reg scl;
always@(posedge clk_out,negedge rst_n)
begin
if(!rst_n)
	scl <= 1'b1;
else
	scl <= ~scl;//250K
end

parameter  ready = 4'd0;
parameter  idle  = 4'd1;
parameter  start  = 4'd2; 
parameter  add1  = 4'd3; 
parameter  add2  = 4'd4; 
parameter  idle1  = 4'd5;
parameter  wait1 = 4'd6;
parameter  add3  = 4'd7; 
parameter  add4  = 4'd8; 
parameter  add5 = 4'd9; 
parameter  stop  = 4'd10; 
parameter  stop1 = 4'd11; 


reg[3:0] state; //״̬�Ĵ��� 
reg sda_r;  //������ݼĴ���  
reg sda_link; //�������sda�ź�inout�������λ    
reg [3:0] num; //
reg [7:0] mid_buf;
reg [7:0] read_data;
reg [7:0] read_data1;
reg [31:0] counter1;

//IICʱ�����״̬��
always @ (negedge clk_out or negedge rst_n) 
begin 
 if(!rst_n)    
		begin  
				sda_r <= 1'b1;   
				sda_link <= 1'b0; 
				state <= ready;
				num <= 4'd0;    
				read_data <= 8'b0000_0000;
				read_data1 <= 8'b0000_0000;
				mid_buf <= 8'b0000_0000;
				counter1 <= 32'd0;				
		end
 else
		case (state)	
				ready:begin
					if(counter1==32'd159999)	
					   begin 
					       state <=idle;
					       counter1 <= 32'd0;
					       sda_link <= 1'b0;
					   end
					else begin 
					   counter1 <= counter1 + 1'd1;
					   state <= ready;
					   end		
		       end
				idle:begin 
				    sda_link <= 1'b1;
				    state <= start;
				    mid_buf <= 8'b10010111;//��Ѱַ������ַ���������� 
				    end 				
				start:
				    if(scl) begin 
				        sda_r <= 1'b0;
				        state <= add1;
				        end
					else 
						 state <= start;				
				add1: begin
						if(!scl)
							begin
								if(num == 4'd8)
								begin
								num <= 4'd0;
								sda_link <= 1'b0;
								state <= add2;
								end
						     else    
									begin    
									   state <= add1;  
									    num <= num+1'd1;										 
									case (num)//����д�뱻Ѱַ������ַ����������          
									4'd0: sda_r <= mid_buf[7];        
									4'd1: sda_r <= mid_buf[6];       
									4'd2: sda_r <= mid_buf[5];         
									4'd3: sda_r <= mid_buf[4];          
									4'd4: sda_r <= mid_buf[3]; 
									4'd5: sda_r <= mid_buf[2];   
									4'd6: sda_r <= mid_buf[1];    
									4'd7: sda_r <= mid_buf[0];       
									default:  ;        
									endcase
									end
							end												
				     else state <= add1;	
					end
				add2:begin 
				    state <= add4;
				    end	
				add4:begin 
							if(num<=4'd7)
								begin         
									state <= add4;
									if(scl) 
									begin         
									num <= num+1'd1;							
									 case (num)//����λ        
									 4'd0: read_data[7] <= sda;  
									 4'd1: read_data[6] <= sda; 
									 4'd2: read_data[5] <= sda; 
									 4'd3: read_data[4] <= sda;
									 4'd4: read_data[3] <= sda;
									 4'd5: read_data[2] <= sda;
									 4'd6: read_data[1] <= sda;
									 4'd7: read_data[0] <= sda;
									 default:  ;          
									endcase 
									end
								end	
							else if((!scl) && (num==4'd8)) 
								begin         
								num <= 4'd0;          
								sda_r <= 1'b0;          
								state <= add3; 
								sda_link <= 1'b1;						         
								end       
							else begin state <= add4;end						  
						end						
					add3:begin state <= add5;end					
					add5:begin 
							if(num<=4'd7)
								begin         
									state <= add5;
									sda_link <= 1'b0;
									if(scl) 
									begin         
									num <= num+1'd1;
									 case (num)//����λ        
									 4'd0: read_data1[7] <= sda;  
									 4'd1: read_data1[6] <= sda; 
									 4'd2: read_data1[5] <= sda; 
									 4'd3: read_data1[4] <= sda;
									 4'd4: read_data1[3] <= sda;
									 4'd5: read_data1[2] <= sda;
									 4'd6: read_data1[1] <= sda;
									 4'd7: read_data1[0] <= sda;
									 default:  ;          
									endcase 
									end
								end	
							else if((!scl) && (num==4'd8)) 
								begin         
								num <= 4'd0;          
								state <= wait1;           
								sda_r <= 1'b1;      
						        sda_link <= 1'b1;   
								end       
							else 
							    state <= add5; 
						  
						end
						wait1:state <=stop;
					stop: 
					   if(!scl) begin 
                           sda_r <= 1'b0;
                           state <= stop1;
					       end 
						else 
						   state <= stop; 
					stop1:
					   if(scl)begin 
					       sda_r <= 1'b1;
					       state <= ready;
					       end
			endcase			
end

assign sda = sda_link ? sda_r:1'bz;//sda_linkΪ1ʱ�������������

endmodule