`timescale 1ns / 1ps

module rec_fifo(
    input rx_enbl,areset,flag,
    input [7:0] dout);    /////////// dout--> is output from the receiver


    reg [7:0] mem [0:15];
    reg [3:0] rear_ptr;                          
    reg [4:0] count; //// [depth:0]
    integer   i;


    always @(posedge flag or posedge areset) begin
        if (areset) begin
            rear_ptr <= 0;
            for (i = 0; i < 16; i = i + 1) begin   /// emptying the memory block
            mem[i] <= 8'd0;
        end
        end
        else if(flag) begin
            if (count!=16) begin
                mem[rear_ptr] <= dout;
                rear_ptr <= rear_ptr + 1'b1;
                count <= count + 1;
            end
            else begin
                mem[0] <= dout;
                count  <= 1; ////// assuming we are overwriting the validated dout into rec_fifo
                rear_ptr <= 1;
        end
      end
    end
endmodule