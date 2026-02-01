//// transmittert
`timescale 1ns / 1ps
//// trans_enbl-->coming from prev trans_enbl output of brg
//// strt_enbl pulse has to be generated for indicating transmisison of start bit
//// similarly for stop_enbl
module transmitter(input areset,tx_enbl,strt_enbl,p_enbl,fb,empty,input [7:0] temp,output reg info,output reg busy,output reg rd_enbl);
    parameter idle=2'b00, 
              start=2'b01,
              data=2'b10,
              stop=2'b11;
    reg [1:0] ps,ns;
    reg [3:0] count;
    reg [7:0] piso;
    reg pin;
    reg [7:0] fb_reg;
   // wire [7:0] temp;
    //wire empty;
    reg prev_p;
    //trans_fifo tx(tx_enbl,areset,write_enbl,din,busy,temp,empty);
    always@(posedge tx_enbl or posedge areset) begin
        if(areset) begin
            ps <= idle;  
            count <= 4'd0;
            piso <= 8'd0;
            pin <= 0;
            info <= 1'b1;  
            busy <= 1'b0;
            fb_reg <= 0;
            prev_p<=0;
         end
         else begin
            ps <= ns;
            
            if(ns != idle) begin
                if(count <= 4'd11) begin
                    if(count == 0) begin
                        piso <= fb?fb_reg:temp;  
                        fb_reg <= fb?fb_reg:temp;
                        pin <= fb?^fb_reg:^temp;
                        prev_p <= fb?prev_p:p_enbl;
                        //busy <= 1'b1;  
                    end      
                    else if(count > 4'd1 && count <= 4'd9) begin
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
                //busy <= 1'b0;  
            end
            case(ps)
                idle:    begin
                            info <= 1'b1;
                            busy<=0;
                            if(ns==start && !fb)
                                rd_enbl<=1;
                            else
                                rd_enbl<=0;
                         end   
                start:   begin
                            rd_enbl<=0;
                            info <= 1'b0; 
                            busy<=1;
                         end   
                data:    begin
                            info <= (count == 4'd10) ? ((prev_p) ? pin : 1'b0) : piso[0];
                            busy<=1;
                         end   
                stop:    begin
                            info <= 1'b1; 
                            busy<=1;
                         end   
                default: begin
                            info <= 1'b1;
                            busy<=0;
                         end   
            endcase
         end
    end 
  
    always@(*)begin
        ns = ps; 
        
        case(ps)
            idle: begin
                    if(strt_enbl && !empty) begin 
                        ns = start;  
                    end
                    else if(fb)
                        ns=start;
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
//                    if(strt_enbl &&  fb) begin
//                        ns = start;
//                    end
//                    else begin
//                        ns = idle;
//                    end
                        ns=idle;
                  end
            default: begin 
                    ns = idle;
                    end      
        endcase                                       
    end
   // assign rd_enbl=(ps==idle && ns==start&& !fb);
endmodule