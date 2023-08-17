`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.06.2023 11:07:58
// Design Name: Synchronous FIFO
// Designed by : N.Manikanta
// Module Name: sync_fifo
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


module sync_fifo #(parameter ADDR_WIDTH = 8, parameter DATA_WIDTH = 32, parameter FIFO_DEPTH = 1<<ADDR_WIDTH)
                  (clk,rst_n,wr_data,rd_data,wr_en,rd_en,fifo_full,fifo_empty);

//---------------------------------PORT DECLARATIONS-----------------------------//
input clk,rst_n,wr_en,rd_en;
input [DATA_WIDTH-1:0]wr_data;
output reg [DATA_WIDTH-1:0]rd_data;
output reg fifo_full,fifo_empty;

//---------------------------------INTERMEDIATE SIGNAL DECLARATIONS-----------------------------//
reg [DATA_WIDTH-1:0]mem[FIFO_DEPTH-1:0];
reg [ADDR_WIDTH-1:0]wr_ptr,rd_ptr;
reg [ADDR_WIDTH:0]loc_counter;

//---------------------------------WRITING INTO FIFO-----------------------------//
always@(posedge clk)
    begin
        if(!fifo_full && wr_en) mem[wr_ptr] <= wr_data;
        else mem[wr_ptr] <= mem[wr_ptr];
    end

//---------------------------------READING FROM FIFO-----------------------------//
always@(posedge clk or negedge rst_n)
    begin
        if(!rst_n) rd_data <= 0;
        else
            begin
                if(!fifo_empty && rd_en) rd_data <= mem[rd_ptr];
                else rd_data <= rd_data;
            end
    end
    
//--------------------------UPDATING READ AND WRITE POINTERS----------------------------//  
always@(posedge clk or negedge rst_n)
    begin
       if(!rst_n)
        begin
             wr_ptr <= 0;
             rd_ptr <= 0;
        end
       else
        begin
            if(!fifo_full && wr_en) wr_ptr <= wr_ptr + 1;
            else wr_ptr <= wr_ptr;
            
            if(!fifo_empty && rd_en) rd_ptr <= rd_ptr + 1;
            else rd_ptr <= rd_ptr;
        end
     end
      
//--------------------------UPDATING FIFO COUNTER----------------------------//  
always@(posedge clk or negedge rst_n)
    begin
        if(!rst_n) loc_counter <= 0;
        else
            begin
                if((wr_en && !fifo_full) && (rd_en && !fifo_empty)) loc_counter <= loc_counter;
                else if(wr_en && !fifo_full) loc_counter <= loc_counter+1;
                else if(rd_en && !fifo_empty) loc_counter <= loc_counter-1;
                else loc_counter <= loc_counter;
           end
    end
    
//--------------------------FIFO_FULL AND FIFO_EMPTY SIGNALS----------------------------//
always@(loc_counter)
    begin
        if(loc_counter==0) fifo_empty <= 1;
        else if(loc_counter==FIFO_DEPTH) fifo_full <= 1;
        else 
            begin
                fifo_empty <= 0;
                fifo_full  <= 0;
            end
    end
endmodule
