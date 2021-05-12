`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2020 12:06:13 AM
// Design Name: 
// Module Name: Cache_test
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


module Cache_test();
    reg clk; reg R_W; reg ready;
    reg [9:0] data; reg [9:0] address;
    wire [9:0] out;
    
    Cache_Controller Cache_test(.clk(clk), .data(data), .address(address), .R_W(R_W), .out(out), .ready(ready));
    
    initial
    begin
        clk = 1'b1;
        ready = 1'b0;
        
        #100
        
        address = 10'b0000000010;         // 0
        data =    10'b0011000011;      //0C3   
        R_W = 1'b1;
        
        #25
        ready = 1'b1;
        
        #75
        address = 10'b1010100101;    //2A5  %  16   
        data =    10'b0000100101;     //025    // 526421
        R_W = 1'b1;
    
        #100
        address = 10'b0000000010;         // 0
        data =    10'b0011000011;      //0C3   
        R_W = 1'b0;
    
        #100
        address = 10'b1010100101;     //2A5  %  16    
        data =    10'b0000100101;         //025
        R_W = 1'b0;
    
        #100
        address = 10'b0110101001;      //1A9  %  16   
        data =    10'b1101101110;         // 26E
        R_W = 1'b1;
    
        #100
        address = 10'b0110101001;         // 1A9  % 16 
        data =    10'b1101101110;         // 26E
        R_W = 1'b0;
    
        #100
        address = 10'b1010100101;         // 2A5  %  16
        data =    10'b0000100101;         // 025
        R_W = 1'b1;
    
        #100
        address = 10'b0000101100;         // 2C
        data =    10'b1111111111;         // 3FF
        R_W = 1'b1;
    
        #100
        address = 10'b0000101101;         // 2D
        data =    10'b0000000001;         // 1
        R_W = 1'b0;
    
        #100
        address = 10'b1010100101;         // 2A5
        data =    10'b0000000010;         // 2
        R_W = 1'b0;
    end

    always #12.5 clk = ~clk;

endmodule
