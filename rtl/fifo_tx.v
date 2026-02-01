///// trans_fifo
`timescale 1ns / 1ps

module trans_fifo
(
    input  wire tx_enbl,
    input  wire areset,
    input  wire write_en,
    input  wire [7:0] din,
    input  wire rd_enbl,  //// reading from trans_fifo
    input wire busy,
    output reg  [7:0] temp,
    output wire empty
);

    reg [7:0] mem [0:15];
    reg [3:0] rear_ptr;
    reg [3:0] front_ptr;
   
    reg [4:0] count; //// [depth:0]

    always @(posedge tx_enbl or posedge areset) begin
        if (areset) begin
            rear_ptr <= 0;
        end
        else if (write_en ) begin
            if(count<5'd16) begin
            mem[rear_ptr] <= din;
            rear_ptr <= rear_ptr + 1'b1;  
            end
            else if(count==5'd16)
                rear_ptr<=0;  
        end
    end


    always @(posedge tx_enbl or posedge areset) begin
        if (areset) begin
            front_ptr <= 0;
            temp <= 0; // Optional reset of output
        end
        else if (rd_enbl && !empty) begin
            temp <= mem[front_ptr]; // Output the data
            front_ptr <= front_ptr + 1'b1;
        end
    end

    always @( posedge tx_enbl or posedge areset) begin     
        if (areset) begin
            count <= 0;
        end
        else begin
            case ({write_en && count!=5'd16,rd_enbl && !empty})/// first case means data is being writtem so cnt will increase // in 2nd case data is popped from front of queue
                2'b10: count <= count + 1;
                2'b01: count <= count - 1;
                default: count <= count;  
            endcase
        end
    end


    assign empty = (count == 0);

endmodule