`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/13 20:21:13
// Design Name: 
// Module Name: display_tb2
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
/////////////////////////////////////////////////////////////////////////////////

module top_tb;

    // ���峣��
    reg CLK;
    reg In_rst;
    reg rst_time;
    wire temp_SCL;
    wire temp_SDA;
    wire vga_hs;
    wire vga_vs;
    wire [11:0] vga_rgb;
    
    // ʵ�����������
    top uut (
        .CLK(CLK),
        .In_rst(In_rst),
        .rst_time(rst_time),
        .temp_SCL(temp_SCL),
        .temp_SDA(temp_SDA),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs),
        .vga_rgb(vga_rgb)
    );

    // ʱ������
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    // ģ�������������
    initial begin
        // ��ʼ���ź�
        In_rst = 1;
        rst_time = 0;
        
        // �ȴ�һЩʱ������ʹϵͳ�ȶ�
        #100;

        // ģ������ʱ��
        In_rst = 0;
        
        // ģ�⸴λʱ��
        #100;
        rst_time = 1;
        
        // �����������Ĳ�������
        // ���磬�����ڲ�ͬ��ʱ�����������źţ��۲�����ı仯

        #100; // ģ�����
        $stop; // ֹͣ����
    end

endmodule

module display_tb;

  reg clk_vga;
  reg rst_n;
  reg [15:0] temp1;
  reg [3:0] L_sec, H_sec, L_min, H_min, L_hour, H_hour;
  reg [9:0] vga_xpos, vga_ypos;
  wire [11:0] vga_data;

  display display_uut (
    .clk_vga(clk_vga),
    .rst_n(rst_n),
    .temp1(temp1),
    .L_sec(L_sec),
    .H_sec(H_sec),
    .L_min(L_min),
    .H_min(H_min),
    .L_hour(L_hour),
    .H_hour(H_hour),
    .vga_xpos(vga_xpos),
    .vga_ypos(vga_ypos),
    .vga_data(vga_data)
  );

  initial begin
    // Test Case 1: Displaying Time
    $display("Test Case 1: Displaying Time");
    // Set inputs for displaying time
    clk_vga = 0; rst_n = 1; temp1 = 16'h0000; // Set temperature to 0
    L_sec = 4'b0000; H_sec = 4'b0000;
    L_min = 4'b0000; H_min = 4'b0000;
    L_hour = 4'b0000; H_hour = 4'b0000;
    vga_xpos = 384; vga_ypos = 250; // Set coordinates for displaying time
    #10;
    
    // Test Case 2: Displaying Temperature
    $display("Test Case 2: Displaying Temperature");
    // Set inputs for displaying temperature
    clk_vga = 0; rst_n = 1; temp1 = 16'h0A00; // Set temperature to 10��C
    L_sec = 4'b0000; H_sec = 4'b0000;
    L_min = 4'b0000; H_min = 4'b0000;
    L_hour = 4'b0000; H_hour = 4'b0000;
    vga_xpos = 520; vga_ypos = 310; // Set coordinates for displaying temperature
    #10;

    // Add more test cases as needed

    // End simulation
    $stop;
  end

  // Clock generation
  always #5 clk_vga = ~clk_vga;

  // Reset generation
  initial begin
    rst_n = 0;
    #20 rst_n = 1;
  end

endmodule
          
 module tb_temperature();
          
            // ����ʱ��
            reg clk_out;
            reg rst_n;
            wire scl;
            wire sda;
            wire [7:0] read_data;
            wire [7:0] read_data1;
          
            // ʵ��������ģ��
            temperature uut(
              .clk_out(clk_out),
              .rst_n(rst_n),
              .scl(scl),
              .sda(sda),
              .read_data(read_data),
              .read_data1(read_data1)
            );
          
            // ʱ���ź�����
            always begin
              #10 clk_out = ~clk_out; // ʱ������Ϊ10��ʱ�䵥λ
            end
          
            // ��ʼ����
            initial begin
              clk_out = 0;
              rst_n = 0;
              //scl = 1;
              force sda = 1;
          
              // �����źű���һ��ʱ��
              #20 rst_n = 1;
          
              // �ȴ�ʱ���ȶ�
              #10;
          
              // �����ǲ�������
          
              // Case 1: ��ȡ�¶�
              $display("=== Case 1: ��ȡ�¶� ===");
              #10;
              $display("��ʼ״̬:");
              $monitor("scl=%b, sda=%b, read_data=%h, read_data1=%h", scl, sda, read_data, read_data1);
              #10;
              $display("��ʼ��ȡ:");
              //scl = 0;
              #10;
              force sda = 0; // ���������ź�
              #10;
              force sda = 1;
              #10;
              $display("��������:");
              #100;
              $display("��ȡ���:");
              $monitor("scl=%b, sda=%b, read_data=%h, read_data1=%h", scl, sda, read_data, read_data1);
          
              // ������������
          
              // ...
          
              #100;
              $stop;
            end
          
          endmodule
module tb_VGA_RGB_Control;
          
            // ʱ�Ӻ͸�λ�ź�
            reg clk;
            reg rst_n;
          
            // ��������
            reg [11:0] vga_data;
          
            // ����ź�
            wire [11:0] vga_rgb;
            wire vga_hs;
            wire vga_vs;
            wire [9:0] vga_xpos;
            wire [9:0] vga_ypos;
          
            // ʵ���������Ե�ģ��
            VGA_RGB_Control uut (
              .clk_vga(clk),
              .rst_n(rst_n),
              .vga_data(vga_data),
              .vga_rgb(vga_rgb),
              .vga_hs(vga_hs),
              .vga_vs(vga_vs),
              .vga_xpos(vga_xpos),
              .vga_ypos(vga_ypos)
            );
          
            // ʱ������
            initial begin
              clk = 0;
              forever #5 clk = ~clk;
            end
          
            // ��ʼ��
            initial begin
              rst_n = 0;
              vga_data = 12'h000;
              #10 rst_n = 1;
            end
          
            // ��������1�����ʱ�Ӻ͸�λ
            initial begin
              #20;
              $display("Test Case 1: Clock and Reset");
              #20 rst_n = 0;
              #20 rst_n = 1;
              #20;
              $finish;
            end
          
            // ��������2�������������
            initial begin
              $display("Test Case 2: Input Data");
              #20 vga_data = 12'h123;
              #20 vga_data = 12'h456;
              #20 vga_data = 12'hABC;
              #20;
              $finish;
            end
          
            // ��Ӹ���Ĳ�������...
          
          endmodule
          
 `timescale 1ns / 1ps
          
          module tb_clock;
          
            // ʱ�Ӻ͸�λ�ź�
            reg clk_100MHz;
            reg rst_time;
          
            // ����ź�
            wire [3:0] L_sec;
            wire [3:0] H_sec;
            wire [3:0] L_min;
            wire [3:0] H_min;
            wire [3:0] L_hour;
            wire [3:0] H_hour;
          
            // ʵ���������Ե�ģ��
            clock uut (
              .clk_100MHz(clk_100MHz),
              .rst_time(rst_time),
              .L_sec(L_sec),
              .H_sec(H_sec),
              .L_min(L_min),
              .H_min(H_min),
              .L_hour(L_hour),
              .H_hour(H_hour)
            );
          
            // ʱ������
            initial begin
              clk_100MHz = 0;
              forever #5 clk_100MHz = ~clk_100MHz;
            end
          
            // ��ʼ��
            initial begin
              rst_time = 0;
              #10 rst_time = 1;
              #100 $finish;
            end
          
            // ��������1�����ʱ�Ӻ͸�λ
            initial begin
              #20;
              $display("Test Case 1: Clock and Reset");
              #20 rst_time = 0;
              #20 rst_time = 1;
              #20;
            end
          
            // ��������2���Զ���ʱģʽ
            initial begin
              $display("Test Case 2: Auto Time Mode");
              #20;
              // ��Ӷ��Զ���ʱģʽ�Ĳ���
              #100;
            end
          
            // ��������3���ֶ���ʱģʽ
            initial begin
              $display("Test Case 3: Manual Time Mode");
              #20;
              // ��Ӷ��ֶ���ʱģʽ�Ĳ���
              #100;
            end
          
          
          endmodule