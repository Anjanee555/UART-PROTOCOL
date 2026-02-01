//// transmitter

`timescale 1ns / 1ps

//// trans_enbl-->coming from prev trans_enbl output of brg
//// strt_enbl pulse has to be generated for indicating transmisison of start bit
//// p_enbl--> fulfilling requirement of optional parity
//// empty--> tracking the status of transmitter fifo memory block 
//// fb--> is the output of the receiver through which it feedbacks the transmitter if the data is sent is correct or not
//// temp--> is a temporary register that is holding the data sent by transmitter fifo (memory block)
//// busy--> is high when transmitter is sending the bits serially to the receiver and low when is at the idle state
//// rd_enbl--> pulse used to fetch data from trans_fifo, is high only when ps->idle and ns->start and eedback signal is low

module transmitter(
    input areset,tx_enbl,strt_enbl,p_enbl,fb,empty,
    input [7:0] temp,
    output reg info,
    output reg busy,
    output reg rd_enbl
    );

    parameter idle=2'b00, 
              start=2'b01,
              data=2'b10,
              stop=2'b11;


    reg [1:0] ps,ns;    ///ps--> present state   ns--> next state
    reg [3:0] count;    ////// counting the bits of dataframe that are serially transmitted 
    reg [7:0] piso;     ///// parallel in serial out register 
    reg       pin;      ///// parity input register 
    reg [7:0] fb_reg;   //// it is holding the prev data sent by the transmitter, in case the data sent is discarded fb_reg will be loaded into fifo
    reg       prev_p;   ///// holding the prev p_enbl value 


    always@(posedge tx_enbl or posedge areset) begin
        if(areset) begin
            ps     <= idle;  
            count  <= 4'd0;
            piso   <= 8'd0;
            pin    <= 0;
            info   <= 1'b1;  
            busy   <= 1'b0;
            fb_reg <= 0;
            prev_p <=0;
         end
         else begin
            ps <= ns;
            
            if(ns != idle) begin
                if(count <= 4'd11) begin
                    if(count == 0) begin
                        piso   <= fb?fb_reg:temp;   /// data loading into piso register 
                        fb_reg <= fb?fb_reg:temp;   /// storing the current data in feedback register for future purposes 
                        pin    <= fb?^fb_reg:^temp; /// storing the parity bit into pin 
                        prev_p <= fb?prev_p:p_enbl; // storing the current parity enable in parity feedback register for future purposes
                    end      
                    else if(count > 4'd1 && count <= 4'd9) begin    //// sending data bits 
                        piso <= {1'b0, piso[7:1]};
                    end
                    count <= count + 1'b1;
                end
                else begin
                    count <= 4'd0;
                end
            end 
            else begin 
                count <= 4'd0;
                piso <= temp; 
            end
            case(ps)
                idle:    begin
                            info <= 1'b1;     //// idle state sending 1's
                            busy <= 0;        //// transmitter is free to accept data 
                            if(ns==start && !fb)
                                rd_enbl <= 1;
                            else
                                rd_enbl <= 0;
                         end   
                start:   begin
                            rd_enbl <= 0;    //// rd_enbl is low as right now transmitter is already inlvolved in transferring one dataframe , it cannot fetch another data
                            info    <= 1'b0; ////start state sending bit 0
                            busy    <= 1;
                         end   
                data:    begin
                            info <= (count == 4'd10) ? ((prev_p) ? pin : 1'b0) : piso[0];
                            busy <= 1;
                         end   
                stop:    begin
                            info <= 1'b1;    //// stop state sending bit 1
                            busy <= 1;
                         end   
                default: begin
                            info <= 1'b1;
                            busy <=0;
                         end   
            endcase
         end
    end 
  
  // combinational block concerned with state switching 
    always@(*)begin
        ns = ps; 
        
        case(ps)
            idle: begin
                    if(strt_enbl && !empty) begin 
                        ns = start;  
                    end
                    else if(fb)
                        ns =start;
                    else begin
                        ns = idle;
                    end
                  end
            start: begin
                    if(count == 4'd1) begin
                        ns = data;
                    end
                    else begin
                        ns = start;
                    end
                   end
            data: begin                                                  
                    if(count == 4'd10) begin
                        ns = stop;
                    end
                    else begin
                        ns = data;
                    end
                  end          
            stop: begin 
                        ns = idle;
                  end
            default: begin 
                        ns = idle;
                    end      
        endcase                                       
    end
endmodule