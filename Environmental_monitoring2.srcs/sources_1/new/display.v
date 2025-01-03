`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/13 15:44:52
// Design Name: 
// Module Name: display
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

module display(
    input            clk_vga,    // VGAʱ���ź�
    input            rst_n,         // ��λ�ź�
    input         [15:0]temp1,
    
    input [3:0] L_sec,
    input [3:0] H_sec,
    input [3:0] L_min,
    input [3:0] H_min,
    input [3:0] L_hour,
    input [3:0] H_hour,     //���������������
        
    input [9:0] vga_xpos,
    input [9:0] vga_ypos,
    
    output [11:0] vga_data
    );
     //vga���ݼĴ���
     reg [11:0] data;
     
    parameter TONGJI_WIDTH = 640;  //ͼƬ�Ŀ��
    parameter TONGJI_HEIGHT = 200; //ͼƬ�ĸ߶�
       
    parameter CHARAC_WIDTH = 80;  //����ͼƬ�Ŀ��
    parameter CHARAC_HEIGHT = 150 - 31; //����ͼƬ�ĸ߶�
    parameter CHARAC_H_OFFSET = 140;
    parameter CHARAC_V_OFFSET = 210; //����ͼƬλ��ƫ����
    
    parameter image_WIDTH = 728;  //ͼƬ�Ŀ��
    parameter image_HEIGHT = 172; //ͼƬ�ĸ߶�
    parameter image_H_OFFSET = 0;
    parameter image_V_OFFSET = 400; //����ͼƬλ��ƫ����
       
    //ip��ROM�Ĵ洢����
    reg [13:0] charac_addr = 0;
    wire [15:0] charac_data , tongji_data , image_data;   //ͼƬ������Ϣ
    reg [16:0] tongji_addr = 0 ;
    reg [16:0] image_addr = 0;
    
    parameter colon = 10, blank = 12, point = 11;   //ð����հ�
    //ȷ���ֵ���ʾ��Χ
    wire [3:0] tep_H , tep_L  , tem_point;
    
    parameter SHIFT_AMOUNT = 3;
    parameter X = 0.6;
    wire [15:0] temp = (temp1 >> SHIFT_AMOUNT);
    
    assign tep_L = temp[15]? (temp[14:0] / 10 ) %10 : (temp[15 : 0] / 10) % 10;
    assign tep_point = temp[15]? temp[14:0] % 100 : temp [15 : 0] % 100;
    assign tep_H = temp[15]? ((temp[14:0] - 10 * tep_L) / 100) :((temp[15 : 0] - 10 * tep_L)/100);          //�����¶�Ϊ�������
    
    wire time_en;
    assign time_en = ((vga_xpos >= 368 && vga_xpos <= 559 && vga_ypos >= 250 && vga_ypos <= 281)||(vga_xpos >= 440 && vga_xpos <= 535 && vga_ypos >= 300 && vga_ypos <= 331)) ? 1 : 0;
    
    reg [3:0] temp_num;
    reg [5:0] x_locate, y_locate;
    
      // ״̬����
      reg [2:0] state;
      localparam IDLE = 3'b000;
      localparam CHARAC_DISPLAY = 3'b001;
      localparam TONGJI_DISPLAY = 3'b010;
      localparam IMAGE_DISPLAY = 3'b011;
      reg display_done = 0;
       // ״̬��         
       always @(posedge clk_vga or negedge rst_n) begin
             if (!rst_n) begin
                 state <= IDLE;
                 data <= 12'b111111111111;
                 charac_addr <= 14'd0;
                 tongji_addr <= 17'd0;
                 image_addr <= 17'd0;
             end else begin
                 // Ĭ��״̬
                 //state <= IDLE;
     
                 // ״̬Ǩ���߼�
                 case (state)
                     IDLE: begin
                         if (vga_xpos >= 144 + CHARAC_H_OFFSET && vga_xpos < 144 + CHARAC_WIDTH + CHARAC_H_OFFSET && vga_ypos >= 35 + CHARAC_V_OFFSET && vga_ypos < 35 + CHARAC_HEIGHT + CHARAC_V_OFFSET) 
                         begin
                             state <= CHARAC_DISPLAY;
                         end else if (vga_xpos >= 144 && vga_xpos < 144 + TONGJI_WIDTH && vga_ypos >= 35 && vga_ypos < 35 + TONGJI_HEIGHT)
                          begin
                             state <= TONGJI_DISPLAY;
                         end else if (vga_xpos >= 144 + image_H_OFFSET && vga_xpos < 144 + image_WIDTH + image_H_OFFSET && vga_ypos >= 35 + image_V_OFFSET && vga_ypos < 35 + image_HEIGHT + image_V_OFFSET) begin
                             state <= IMAGE_DISPLAY;
                         end
                         else
                            begin
                                data <= 12'b111111111111;
                            end
                     end
                     CHARAC_DISPLAY: begin
                         // CHARAC_DISPLAY ״̬�߼�
                         // ...
                         data <= charac_data[11:0];
                         charac_addr <= (vga_ypos - (35 + CHARAC_V_OFFSET)) * CHARAC_WIDTH + vga_xpos - (144 + CHARAC_H_OFFSET);
                         state <= IDLE;
                         // ������ʾ����ź�
                     end
                     TONGJI_DISPLAY: begin
                         // TONGJI_DISPLAY ״̬�߼�
                         // ...
                         data <= tongji_data[11:0];
                         tongji_addr <= (vga_ypos - 35) * TONGJI_WIDTH + vga_xpos - 144;
                         state <= IDLE;
                     end
                     IMAGE_DISPLAY: begin
                         // IMAGE_DISPLAY ״̬�߼�
                         // ...
                         data <= image_data[11:0];
                         image_addr <= (vga_ypos - (35 + image_V_OFFSET)) * image_WIDTH + vga_xpos - (144 + image_H_OFFSET);
                         state <= IDLE;
                     end
                    
                 endcase
             end
         end


    /*
    always @ (posedge clk_vga or negedge rst_n)
     begin
         if(!rst_n)
         begin 
             data <= 12'b111111111111;
             charac_addr <= 14'd0;
         end
         else
            begin
          if(vga_xpos >= 144 + CHARAC_H_OFFSET  && vga_xpos < 144 + CHARAC_WIDTH + CHARAC_H_OFFSET && vga_ypos >= 35 + CHARAC_V_OFFSET  && vga_ypos < 35 + CHARAC_HEIGHT + CHARAC_V_OFFSET)
                begin
                    data <= charac_data[11:0];
                    charac_addr <= (vga_ypos - (35 + CHARAC_V_OFFSET)) * CHARAC_WIDTH + vga_xpos - (144 + CHARAC_H_OFFSET);            
                end
            else if(vga_xpos >= 144  && vga_xpos < 144 + TONGJI_WIDTH  && vga_ypos >= 35  && vga_ypos < 35 + TONGJI_HEIGHT)       //��ʼ��ΪH/V_Start+ƫ��,�յ�ΪͼƬ��ʼ��+ͼƬ��/�߶�
                          begin
                            data <= tongji_data[11:0];
                            tongji_addr <= (vga_ypos - 35) * TONGJI_WIDTH + vga_xpos - 144; 
                           end
            else if(vga_xpos >= 144 + image_H_OFFSET && vga_xpos < 144 + image_WIDTH + image_H_OFFSET && vga_ypos >= 35 + image_V_OFFSET && vga_ypos < 35 + image_HEIGHT+ image_V_OFFSET)       //��ʼ��ΪH/V_Start+ƫ��,�յ�ΪͼƬ��ʼ��+ͼƬ��/�߶�
                       begin
                            data <= image_data[11:0];
                            image_addr <= (vga_ypos - (35 + image_V_OFFSET)) * image_WIDTH + vga_xpos - (144 + image_H_OFFSET); 
                       end
            else
                begin
                    data <= 12'b111111111111;
                end  
            end
      end
      */
      
      blk_mem_gen_0 charac_uut(
          .clka(clk_vga),
          .addra(charac_addr),
          .douta(charac_data)
      );
      
      blk_mem_gen_2 tongji_uut(
          .clka(clk_vga),
          .addra(tongji_addr),
          .douta(tongji_data)
      );
      
       blk_mem_gen_3 image_uut(
             .clka(clk_vga),
             .addra(image_addr),
             .douta(image_data)
         );
         

   
    always @ (*) 
        begin
        if(vga_ypos >= 250 && vga_ypos <= 281)              //��ʾʱ��ķ�Χ
            begin
                y_locate = vga_ypos - 250;
                if(vga_xpos >= 368  && vga_xpos <= 383)  
                begin
                    temp_num = H_hour;
                    x_locate  = vga_xpos - 368;  
                end
                else if(vga_xpos >= 384  && vga_xpos <= 399)  
                begin
                    temp_num = L_hour;
                    x_locate  = vga_xpos - 384;  
                end
                else if(vga_xpos >= 400 && vga_xpos <= 415)  
                begin
                    temp_num = blank;
                    x_locate  = vga_xpos - 400;  
                end
                else if(vga_xpos >= 416  && vga_xpos <= 431)  
                begin
                    temp_num = colon;
                    x_locate  = vga_xpos - 416;  
                end
                else if(vga_xpos >= 432  && vga_xpos <= 447)  
                begin
                    temp_num = blank;
                    x_locate  = vga_xpos - 432;  
                end
                else if(vga_xpos >= 448  && vga_xpos <= 463)  
                begin
                    temp_num = H_min;
                    x_locate  = vga_xpos - 448;  
                end
                else if(vga_xpos >= 464  && vga_xpos <= 479)  
                begin
                    temp_num = L_min;
                    x_locate  = vga_xpos - 464;  
                end
                else if(vga_xpos >= 480  && vga_xpos <= 495)  
                begin
                    temp_num = blank;
                    x_locate  = vga_xpos - 480;  
                end
                else if(vga_xpos >= 496  && vga_xpos <= 511)  
                begin
                    temp_num = colon;
                    x_locate  = vga_xpos - 496;  
                end
                else if(vga_xpos >= 512 && vga_xpos <= 527)  
                begin
                    temp_num = blank;
                    x_locate  = vga_xpos - 512;  
                end
                else if(vga_xpos >= 528 && vga_xpos <= 543)  
                begin
                    temp_num = H_sec;
                    x_locate  = vga_xpos - 528; 
                   end
                else if(vga_xpos >= 544 && vga_xpos <= 559)  
                begin
                    temp_num = L_sec;
                    x_locate  = vga_xpos - 544;  
                end
                else 
                begin
                    temp_num = blank;
                    x_locate = 0;  
                end
            end
             else if(vga_ypos >= 300 && vga_ypos <= 331)
               begin
                   y_locate = vga_ypos - 300;
                   if(vga_xpos >= 440 && vga_xpos <= 455)
                   begin
                       temp_num = colon;
                       x_locate = vga_xpos - 440;                                                
                   end
                   else if(vga_xpos >= 456 && vga_xpos <= 471)
                   begin
                       temp_num = temp[15] ? 0 : blank;
                       x_locate = vga_xpos - 456;    
                   end
                   else if(vga_xpos >= 472 && vga_xpos <= 487)
                   begin
                       temp_num = tep_H;
                       x_locate = vga_xpos - 472;    
                   end
                   else if(vga_xpos >= 488 && vga_xpos <= 503)
                   begin
                       temp_num = tep_L;
                       x_locate = vga_xpos - 488;    
                   end
                   else if(vga_xpos >= 504 && vga_xpos <= 519)
                   begin
                       temp_num = point;
                       x_locate = vga_xpos - 504;    
                   end
                   else if(vga_xpos >= 520 && vga_xpos <= 535)
                   begin
                       temp_num = (tep_point < 10) ? tep_point : 0;
                       x_locate = vga_xpos - 520;    
                   end                                    
         end
   end
                reg [9:0] base_addr;        //���ڶ�ȡ��Ӧλ������ģcoe�ļ���������
                always@( * ) 
                begin
                    case(temp_num)
                    4'd0 :
                        base_addr = 0;
                    4'd1 :
                        base_addr = 32;
                    4'd2 :
                        base_addr = 64;
                    4'd3 :
                        base_addr = 96;
                    4'd4 :
                        base_addr = 128;
                    4'd5 :
                        base_addr = 160;
                    4'd6 :
                        base_addr = 192;
                    4'd7 :
                        base_addr = 224;
                    4'd8 :
                        base_addr = 256;
                    4'd9 :
                        base_addr = 288;
                    4'd10:
                        base_addr = 320;
                    4'd11:
                        base_addr = 352;
                    4'd12:
                        base_addr = 384;
                    4'd13:
                        base_addr = 416;
                    4'd14:
                        base_addr = 448;
                    4'd15:
                        base_addr = 480;
                    default:
                        base_addr =0;
                    endcase
                end
                 
            wire [8:0] addra;
            assign addra = base_addr + y_locate;      //��λ��һ�������������е����ص㣬��������
            wire [15:0] douta;
            blk_mem_gen_1 character_uut
            (
              .clka(clk_vga), 
              .addra(addra), 
              .douta(douta) //��ȡÿ�����ֵ�16λһ�е�����
            );
            
            wire [15:0] douta_initial;
            assign douta_initial = douta << x_locate;     //ÿ����Χ�ڵĵ�ַ����ӳ�䵽��Ե�ַ��Ȼ���������������λ�õ����λ�����Ǹõ��rgbֵ
            assign num = douta_initial[15];
            
            assign vga_data = time_en ? {12{~num}} : data;
            
endmodule
