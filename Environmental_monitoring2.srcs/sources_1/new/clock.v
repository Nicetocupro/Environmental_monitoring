`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/13 21:57:24
// Design Name: 
// Module Name: clock
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

module clock(
    input clk_100MHz,
    input rst_time,      
    output [3:0] L_sec,
    output [3:0] H_sec,
    output [3:0] L_min,
    output [3:0] H_min,
    output [3:0] L_hour,
    output [3:0] H_hour
    );
    reg clk_1Hz = 1'b0;
    parameter time_N = 1_0000_0000;      //默认系统时钟频率100MHz，转化为1000Hz，需要除以十万
    reg [31:0] cnt;
    always @ (posedge clk_100MHz, negedge rst_time)
    begin
        if(!rst_time)
        begin
            cnt <= 0; 
            clk_1Hz <= 0;
        end
        else if(cnt == time_N/2 - 1)
        begin
            cnt <= 0;
            clk_1Hz <= ~clk_1Hz;
        end
        else
            cnt <= cnt + 1;
    end
    
    //中间变量分别表示自动计时与手动输入计时
    reg [3:0] L_sec_auto;
    reg [3:0] H_sec_auto;
    reg [3:0] L_min_auto;
    reg [3:0] H_min_auto;
    reg [3:0] L_hour_auto;
    reg [3:0] H_hour_auto;
    reg [3:0] L_sec_hand;
    reg [3:0] H_sec_hand;
    reg [3:0] L_min_hand;
    reg [3:0] H_min_hand;
    reg [3:0] L_hour_hand;
    reg [3:0] H_hour_hand;
    
    always @ (posedge clk_1Hz or negedge rst_time)//输出时钟写错了
    begin
        if(!rst_time)
        begin
            L_sec_auto <= 4'b0000;
            H_sec_auto <= 4'b0000;
            L_min_auto <= 4'b0000;
            H_min_auto <= 4'b0000;
            L_hour_auto <= 4'b0000;
            H_hour_auto <= 4'b0000;
        end
        else
        begin
            //末状态恢复初始值
            if(L_sec_auto == 4'b1001 && H_sec_auto == 4'b0101 && L_min_auto == 4'b1001 && H_min_auto == 4'b0101 && L_hour_auto == 4'b0011 && H_hour_auto == 4'b0010)
            begin
                L_sec_auto <= 4'b0000;
                H_sec_auto <= 4'b0000;
                L_min_auto <= 4'b0000;
                H_min_auto <= 4'b0000;
                L_hour_auto <= 4'b0000;
                H_hour_auto <= 4'b0000;
            end
            else
            begin
                if(L_sec_auto == 9)
                begin
                    L_sec_auto <= 0;
                    if(H_sec_auto == 5)
                    begin
                        H_sec_auto <= 0;
                        if(L_min_auto == 9)
                        begin
                            L_min_auto <= 0;
                            if(H_min_auto == 5)
                            begin
                                H_min_auto <= 0;
                                if(L_hour_auto == 9)        //09时到10时
                                begin
                                    L_hour_auto <= 0;
                                    H_hour_auto <= H_hour_auto + 1;
                                end
                                else
                                    L_hour_auto <= L_hour_auto + 1;
                                end
                            else
                                H_min_auto <= H_min_auto + 1;
                            end
                        else
                            L_min_auto <= L_min_auto + 1;    
                        end
                    else
                        H_sec_auto <= H_sec_auto + 1;    
                    end
                else
                    L_sec_auto <= L_sec_auto + 1;
                end
            end
    end
    
    //时间变化的周期为1s，在此基础上给输出赋值，自动手动选择其一即可，可以在assign
    assign L_sec =  L_sec_auto;
    assign H_sec =  H_sec_auto;
    assign L_min =  L_min_auto;
    assign H_min =  H_min_auto;
    assign L_hour = L_hour_auto;
    assign H_hour = H_hour_auto;
    
endmodule