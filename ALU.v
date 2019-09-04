`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Rachel Hamilton
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


module Seven_Segment_BCD(A, B, rst, clk, BTN, seg, an, ovf, brw, eq);
    input   [7:0] A;
    input   [7:0] B;
    input   rst;
    input   clk;
    input   [3:0] BTN; 
    output  [6:0] seg;
    output  [3:0] an;
    output  ovf;
    output  brw;
    output  eq;

    reg eq;
    reg ovf;
    reg brw;
    reg [15:0] result;
    reg [15:0] display;
    reg [6:0] seg;
    reg [3:0] an;
    reg [3:0] bcd;
    reg [2:0] state;
    reg [28:0] clkdiv;
    reg [28:0] clkCnt;
    reg toggle;
    reg toggle2x;
    reg toggle2xCount;
    reg display_op;
    reg display_res;
    
    /*
    Utilizes three states:
        - Reset/idle
        - Display operand
        - Display result
    */
    always @(posedge clk or posedge rst)
    begin
    
        if(rst)
        begin
            state       <= 3'b000;
            clkCnt      <= 0;
            display_op  <= 1'b0;
            display_res <= 1'b0;
        end
        
        else
        begin  
            case(state)
            3'b000: begin   // Reset/idle; turns on operand flag if button press
                        if(BTN == 4'b0000) 
                        begin
                            state       <= 3'b000;
                            display_op  <= 1'b0;
                            display_res <= 1'b0;
                        end
                        else
                        begin
                            state       <= 3'b001; 
                            display_op  <= 1'b1;  
                        end 
                    end                 
            3'b001: begin   // Display operand; turns off operand and turns on result at time
                        if(clkCnt == 200000000)
                        begin
                            display_op  <= 1'b0;
                            display_res  <= 1'b1;
                            clkCnt      <= 0;
                            state       <= 3'b010;
                        end
                        else
                        begin
                            clkCnt      <= clkCnt + 1;
                            state       <= 3'b001;
                        end
                    end
            3'b010: begin   // Disp/ay result; turns off result flag at time
                        if(clkCnt == 200000000)
                        begin
                            display_res <= 1'b0;
                            clkCnt      <= 0;
                            state       <= 3'b000;
                        end
                        else
                        begin
                            clkCnt      <= clkCnt + 1;
                            state       <= 3'b010;
                        end
                    end
            default: state <= 3'b000;    
            endcase
        end
    end    
    
    //Calculate result and ASPR flags
    always @(posedge clk)
    begin
    
        // If state is 0 (state is 0 on reset), clear all the flags
        if(state == 0)
        begin
            ovf <= 0;
            brw <= 0;
            eq  <= 0;
        end
        
        case(BTN)
        4'b0001:    begin
                        result  <= A+B;
                        ovf     <= (result>4'b1111) ? 1 : 0;      
                    end
        4'b0010:    begin
                        result  <= A-B;
                        brw     <= (B>A) ? 1 : 0; 
                    end
        4'b0100:    begin
                        result  <= A<<1;
                        ovf     <= (result>4'b1111) ? 1 : 0;  
                    end
        4'b1000:    begin
                        result  <= A==B;
                        eq      <= (B==A) ? 1 : 0;
                    end
        default:    result      <= result;
        endcase 
    end


    // Displays the desired state values, ie operand or result
    always @(posedge clk)
    begin
        if(display_op)
        begin
            display[7:0] <= A;
            display[15:8] <= B;
        end
        else if(display_res)
        begin
            display <= result;
        end
    end
    
    /*
    The clock generates two period (toggle), one of which is 
    double the other. This generates a 2-bit select. Each anode
    is activated at a different of the 4 combinations
    */
    always @(posedge clk or posedge rst)
    begin
       if( rst || state==3'b000 )
       begin
            an  <= 4'b1111;
       end
       else
       begin
            if(toggle == 1 && toggle2x == 1)
            begin
                an  <= 4'b1110;
                bcd <= display[3:0];
            end
            else if(toggle == 1 && toggle2x == 0)
            begin
                an  <= 4'b1101;
                bcd <= display[7:4];
            end
            else if(toggle == 0 && toggle2x == 1)
            begin
                an  <= 4'b1011;
                bcd <= display[11:8];
            end
            else if(toggle == 0 && toggle2x == 0)
            begin
                an  <= 4'b0111;
                bcd <= display[15:12];
            end
        end
   end
   
    always @(posedge clk)
    begin
        case(bcd)   
        default: seg = 7'b0000001;
        4'b0000: seg = 7'b0000001; //0
        4'b0001: seg = 7'b1001111; //1
        4'b0010: seg = 7'b0010010; //2
        4'b0011: seg = 7'b0000110; //3
        4'b0100: seg = 7'b1001100; //4
        4'b0101: seg = 7'b0100100; //5
        4'b0110: seg = 7'b0100000; //6
        4'b0111: seg = 7'b0001111; //7
        4'b1000: seg = 7'b0000000; //8
        4'b1001: seg = 7'b0000100; //9
        4'b1010: seg = 7'b0001000; //A
        4'b1011: seg = 7'b1100000; //B
        4'b1100: seg = 7'b0110001; //C
        4'b1101: seg = 7'b1000010; //D
        4'b1110: seg = 7'b0110000; //E
        4'b1111: seg = 7'b0111000; //F    
        endcase  
    end
   
   
    //Toggle 2x has a period that is 2x the first toggle   
    always @ (posedge clk)
    begin
   
    if (clkdiv == 100000) 
        begin
            clkdiv <= 0;
            toggle <= ~toggle;
            if(toggle2xCount == 1) // triggers every 2 "toggles"
            begin
                toggle2xCount   <= 0;
                toggle2x        <= ~toggle2x;
            end
            else     
            begin
                toggle2xCount   <= toggle2xCount + 1;
            end
        end  
        else 
        begin
            clkdiv <= clkdiv + 1;
        end
       
   end   
    
endmodule