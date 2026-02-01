`timescale 1ns/1ps

module receiver_2(
input clk, areset, p_enbl, rx_enbl,
input info,
output reg [7:0] dout,
output reg error,
output reg fb,
output reg flag
);
parameter idle=3'b000, start=3'b001, active=3'b010, stop=3'b011, wait_state=3'b100;
reg [3:0] data_cnt, s_cnt;
reg [7:0] temp;
reg [2:0] ps, ns;
reg prev_p;
//rec_fifo rx(rx_enbl,areset,flag,dout);

always @(posedge rx_enbl or posedge areset) begin
if (areset) begin
ps <= idle;
data_cnt <= 4'd0;
s_cnt <= 4'd0;
temp <= 8'd0;
dout <= 8'd0;
error <= 0;
fb <= 0;
flag<=0;
prev_p<=0;
end
else begin
ps <= ns;


case (ps)
idle: begin
temp <= 8'd0;
s_cnt <= 4'd0;
data_cnt <= 4'd0;
error <= 0;
flag<=0;
//feedback<=0;
end

start: begin
prev_p<=(fb)?prev_p:p_enbl;
if (s_cnt == 4'd7) begin
s_cnt <= 4'd0;
fb<=0;
end
else begin
s_cnt <= s_cnt + 1;
end
end

active: begin
if (s_cnt == 4'd15) begin
s_cnt <= 4'd0;
if (data_cnt <= 4'd7) begin
temp <= {info, temp[7:1]};
data_cnt <= data_cnt + 1'b1;
end
else if (data_cnt == 4'd8) begin
if (prev_p)begin
error <= (info != ^temp);
end
else error <= 0;
data_cnt <= 0;
end
end
else begin
s_cnt <= s_cnt + 1;
end
end

stop: begin
if (s_cnt == 4'd15) begin
if(error || info==0)begin
fb<=1'b1;
dout<=0;
flag<=0;//// dont need to add in the rec_fifo
///oversampling is not happening that is after detecting feedback bcz of stop bit it transits directly to start state therefore we should add a delay of 8 rx_enbl
end
else begin dout<=temp;
flag<=1;
end
s_cnt <= 4'd0;
end
else begin
s_cnt <= s_cnt + 1;
end
end
wait_state:begin
if(s_cnt==7)begin
s_cnt<=0;
end
else s_cnt<=s_cnt+1;
end

default: begin
temp <= 8'd0;
s_cnt <= 4'd0;
data_cnt <= 4'd0;
error <= 0;
end
endcase
end
end

// Combinational next state logic
always @(*) begin
ns = ps;

case (ps)
idle: begin
if (info == 0) ns = start;
else ns = idle;
end

start: begin
if (s_cnt == 4'd7) begin
ns = active;
end
else begin
ns = start;
end
end

active: begin
if (data_cnt == 4'd8 && s_cnt == 4'd15) begin
ns = stop;
end
else begin
ns = active;
end
end

stop: begin
if (s_cnt == 4'd15) begin
ns = wait_state;
end
else begin
ns = stop;
end
end
wait_state:begin
if(s_cnt==7) ns=idle;
else ns=wait_state;
end
default: ns = idle;
endcase
end
endmodule



//module rec_fifo(input rx_enbl,rst,write_enbl,input [7:0] dout);    /////////// dout--> is output from the receiver
//    reg [7:0] mem [0:15];
//    reg [3:0] rear_ptr;                          
//    reg [4:0] count; //// [depth:0]
//    integer i;
//    always @(posedge write_enbl or posedge rst) begin
//        if (rst) begin
//            rear_ptr <= 0;
//            for (i = 0; i < 16; i = i + 1) begin
//            mem[i] <= 8'd0;
//        end
//        end
//        else if(write_enbl) begin
//            if (count!=16) begin
//                mem[rear_ptr] <= dout;
//                rear_ptr <= rear_ptr + 1'b1;
//                count<=count+1;
//            end
//            else begin
//                mem[0]<=dout;
//                count<=1; ////// assuming we are overwriting the validated dout into rec_fifo
//                rear_ptr<=1;
//        end
//      end
//    end
//endmodule