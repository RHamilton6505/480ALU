`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.05.2019 21:07:25
// Design Name: 
// Module Name: Seven_Segment_BCD
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


module Seven_Segment_BCD(sw, toggle, rst, clk, seg, an);
    input [7:0] sw;
    input rst;
    input clk;
    input toggle;
    output [6:0] seg;
    output [3:0] an;


    reg [6:0] seg;
    reg [3:0] an;
    reg [3:0] bcd;
    reg [28:0] clkdiv;
    wire clk;
    
    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            seg <= 7'b1111111;
            an  <= 4'b1111;
        end
        else
        begin
            an <= 4'b1111;

            if(toggle == 1)
            begin
                an  <= 4'b1110;
                bcd <= sw[3:0];
            end
            else
            begin
                an  <= 4'b1101;
                bcd <= sw[7:4];
            end
            
            case(bcd)   
            default: seg = 7'b0000001;
            4'b0000: seg = 7'b0000001;
            4'b0001: seg = 7'b1001111;
            4'b0010: seg = 7'b0010010;
            4'b0011: seg = 7'b0000110;
            4'b0100: seg = 7'b1001100;
            4'b0101: seg = 7'b0100100;
            4'b0110: seg = 7'b0100000;
            4'b0111: seg = 7'b0001111;
            4'b1000: seg = 7'b0000000;
            4'b1001: seg = 7'b0000001; 
            endcase  
        end  
   end
   
 
    
endmodule
