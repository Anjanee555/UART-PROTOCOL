///// trans_fifo
`timescale 1ns / 1ps

module trans_fifo
(
    input  wire       tx_enbl,
    input  wire       areset,
    input  wire       write_en,
    input  wire [7:0] din,
    input  wire       rd_enbl,  //// reading from trans_fifo
    input  wire       busy,
    output reg  [7:0] temp,
    output wire       empty
);

    reg [7:0] mem [0:15];
    reg [3:0] rear_ptr;
    reg [3:0] front_ptr;
   
    reg [3:0] count; //// [depth:0]

    always @(posedge tx_enbl or posedge areset) begin
        if (areset) begin
            rear_ptr <= 0;
            count    <= 0;
        end
        else if (write_en ) begin
            mem[rear_ptr] <= din;
            count  <=  count+1;
            if(rear_ptr < 4'd15) begin
                rear_ptr <= rear_ptr + 1'b1;  
            end
            else if(rear_ptr == 4'd15) begin
                rear_ptr <= 0;
                //count<=0;
            end      
        end
    end


    always @(posedge tx_enbl or posedge areset) begin
        if (areset) begin
            front_ptr <= 0;
            temp      <= 0; 
        end
        else if (rd_enbl && !empty) begin
            temp <= mem[front_ptr]; // Output the data
            //count<=count-1;
            if(front_ptr < 4'd15)begin
                front_ptr <= front_ptr + 1'b1;
            end
            else begin
                front_ptr <= 0;
                
            end    
        end
    end
    assign empty = (count == 0);

endmodule