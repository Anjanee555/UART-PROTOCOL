`timescale 1ns/1ps

//// p_enbl--> is a common input pin as given in transmitter for optional parity tracking 
//// rx_enbl--> receiver clk cycle 
//// info--> serial data coming from transmitter 
//// dout--> serial data bits received are orderly arranged as dout and given to the receiver fifo memory block
//// error--> output of the receiver in case the data received is wrong or not complete data frame is received
//// fb--> in case of error this pulse will be given to the transmitter to re-transmit the data
//// flag--> is a output given as write enable signal to the receiver fifo for data entry into the receiver memory block 

module receiver(
    input           areset, p_enbl, rx_enbl,
    input           info,
    output reg [7:0] dout,
    output reg      error,
    output reg      fb,
    output reg      flag
);

    parameter idle       = 3'b000, 
              start      = 3'b001, 
              active     = 3'b010, 
              stop       = 3'b011, 
              wait_state = 3'b100;

    reg [3:0] data_cnt, s_cnt;  //// data_cnt--> counting the receiving dataframe bits
                                //// s_cnt--> counting the samples tracking if data and start bit is received after sample count of 8
    reg [7:0] temp;             ///// is a srrial in parallel out register 
    reg [2:0] ps, ns;
    reg prev_p;                 //// storing previous parity enable value

always @(posedge rx_enbl or posedge areset) begin
    if (areset) begin
        ps       <= idle;
        data_cnt <= 4'd0;
        s_cnt    <= 4'd0;
        temp     <= 8'd0;
        dout     <= 8'd0;
        error    <= 0;
        fb       <= 0;
        flag     <= 0;
        prev_p   <= 0;
    end
    else begin
        ps <= ns;
    end

    case (ps)
        idle: begin
            temp     <= 8'd0;
            s_cnt    <= 4'd0;
            data_cnt <= 4'd0;
            error    <= 0;
            flag     <= 0;
        end

        start: begin
            prev_p <= (fb)?prev_p:p_enbl; // if error is there or dataframe is wrong then transmitter will resend the prev data,so storing prev parity enable value
            if (s_cnt == 4'd7) begin      // sample count of 8 for start bit after this switches to active state 
                s_cnt <= 4'd0;   
                fb<=0;
            end
            else begin
                s_cnt <= s_cnt + 1;
            end
        end

        active: begin
            if (s_cnt == 4'd15) begin              /// complete sample of 16 for receiving one bit of info
                s_cnt <= 4'd0;
                if (data_cnt <= 4'd7) begin        /// info captured at centre of sample count for min distortions 
                    temp     <= {info, temp[7:1]}; //// sipo logic 
                    data_cnt <= data_cnt + 1'b1;
                end
                else if (data_cnt == 4'd8) begin   
                    if (prev_p)begin
                        error <= (info != ^temp);
                    end
                    else error   <= 0;
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
                    fb   <= 1'b1;
                    dout <= 0;
                    flag <= 0;   /// dont need to add in the rec_fifo
                                 ///oversampling is not happening that is 
                                 //after detecting feedback bcz of stop bit it transits directly to start state therefore we should add a delay of 8 rx_enbl
                end
                else begin dout <= temp;
                    flag <= 1;    
                end
            s_cnt <= 4'd0;
            end
            else begin
                s_cnt <= s_cnt + 1;
            end
        end
        wait_state:begin
            if(s_cnt ==  7)begin
                s_cnt <= 0;
            end
            else s_cnt <= s_cnt+1;
        end

        default: begin
            temp     <= 8'd0;
            s_cnt    <= 4'd0;
            data_cnt <= 4'd0;
            error    <= 0;
        end
    endcase
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
            if (s_cnt == 4'd7) begin    // sample count of 8 for start bit after this switches to active state 
                ns = active;
            end
            else begin
                ns = start;
            end
        end

        active: begin
            if (data_cnt == 4'd8 && s_cnt == 4'd15) begin   //// data and parity bits received at the s_count of 16
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
            if(s_cnt == 7) ns=idle;  /// added to synchronize as there is bloacking assignment so state might switch instantly to start state
            else ns = wait_state;
        end
        default: ns = idle;
    endcase
end

endmodule