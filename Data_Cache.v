`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2020 03:40:53 AM
// Design Name: 
// Module Name: Data_Cache
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Cache_Controller(input clk, input [9:0] data, input [9:0] address, input R_W, output [9:0] out, input ready);
    
    reg [9:0] temp_out;
    reg [3:0] index; // for keeping index of current address
    reg [4:0] tag;  // for keeping tag of current address
    reg dirty [15:0];
    reg [4:0] prev_tag [15:0];
    
    DataMemory ram();
    Data_Cache cache(.ready(ready));

    reg [1:0] state, next_state;
    parameter [1:0] s1 = 2'b00, s2 = 2'b01, s3 = 2'b10, s4 = 2'b11;
    
    /*always block statements to transfer between states*/   
    always @(posedge clk) 
        if (ready == 0)
            state <= s1;
        else
            state <= next_state; 
    
    always @(state, ready, s1, s2, s3, s4)
    begin
        case(state)
                s1: begin   /*In idle state, checks to see of the cache is ready or not*/
                        if (ready == 1)
                        begin
                            index = address[4:1];
                            tag = address[9:5];
                            next_state = s2;
                        end
                        else
                        begin
                            next_state = s1;
                        end
                    end
                
                s2: begin   /*Check the dirty flag for specific memory address. Then, check
                            for a tag match. If tag matches, cahce hit data access and output
                            in same cycle and move to idle*/
                        if(dirty[index] == 1)
                            begin
                                if (tag == prev_tag[index])
                                    begin
                                        if (R_W == 1)
                                            //Read(load) from the memory and transfer to cache
                                            begin
                                                cache.cache[index] = ram.ram[index];
                                            end
                                        else
                                            //write(store) to the memory from cahce
                                            begin
                                                ram.ram[index] = cache.cache[index];
                                            end
                                        next_state = s1;
                                    end
                                else
                                    begin
                                        cache.tag = tag;
                                        cache.index = index;
                                        next_state = s3;
                                    end
                            end
                        else
                            begin
                                cache.tag = tag;
                                cache.index = index; 
                                next_state <= s3;
                            end
                    end
                
                s3: begin    /*If no tag match or no dirty flag move to third state and save 
                                the previous tag in a register and move to fourth state*/
                        prev_tag[index] = cache.tag;
                        next_state <= s4;
                    end
                    
                s4: begin   //read/write
                        if (R_W == 1)
                            begin
                            //Read the new data directly from the cache
                                cache.cache[index] = data;
                                dirty[index] = 1;
                            end
                        else
                            begin
                            //Write the new data into the memory and then write into cache
                                ram.ram[index] = data;
                                cache.cache[index] = ram.ram[index];
                                dirty[index] = 1;
                            end
                        temp_out = cache.cache[index]; //temporary output value
                        next_state <= s1; //Go to idle state
                    end
                    
                default:
                        next_state <= s1;
        endcase    
    end        

assign out = temp_out;

endmodule

module Data_Cache(input [9:0] data, input [9:0] address, input R_W, input ready);
   
        reg [9:0] cache [15:0]; //registers for the data in cache
        reg [4:0] tag; 
        reg [3:0] index;
        reg offset; 

initial
    begin: initialization
        integer i;
        for (i = 0; i < 16; i = i + 1)
            begin
                cache[i] = 10'b0000000000;
                tag = cache[i][9:5];
                index = cache[i][4:1];
                offset = cache[i][0];
            end
    end
endmodule

module DataMemory(input clk, input [3:0] address, input [9:0] write_data, input write_en, input mem_read, 
                    output [9:0] read_data);
        integer i;
        reg [9:0] ram [15:0];
        wire [3:0] ram_address = address;
        
        initial begin
            for(i = 0; i < 16; i = i + 1)
                ram[i] <= 10'b0000000000;
        end
        
        always @(posedge clk) begin
            if (write_en)
                ram[ram_address] <= write_data;
        end
        assign read_data = (mem_read) ? ram[ram_address] : 10'b0000000000;
endmodule
