`timescale 1ns / 1ps


module topmodule(
    input clk, 
    input areset,
    input strt_enbl, 
    input [7:0] din,
    input write_en,
    input p_enbl,
    //output busy,
    //output [7:0] dout, 
    output error
    );
    
    wire tx_enbl;
    wire rx_enbl;  
    wire info;
    wire flag;
    wire [7:0] dout;
    wire rd_enbl;
    wire [7:0] temp;
    wire empty;
    wire busy;
    
    // FIFO for Tx instantiation
    trans_fifo txf(
        .tx_enbl(tx_enbl),
        .areset(areset),
        .write_en(write_en),
        .din(din),
        .rd_enbl(rd_enbl),
        .busy(busy),
        .temp(temp),
        .empty(empty)
    );
    
    //Tx instantiation
    transmitter tx(
        .areset(areset),
        .tx_enbl(tx_enbl),
        .strt_enbl(strt_enbl),
        .p_enbl(p_enbl),
        .fb(fb),
        .empty(empty),
        .temp(temp), 
        .info(info),
        .busy(busy),
        .rd_enbl(rd_enbl)
    );
    
    // Baud Rate Generator instantiation
    uart_baud_rate_gen baud(
        .clk(clk),
        .areset(areset),
        .tx_enbl(tx_enbl),
        .rx_enbl(rx_enbl)
    );
    
    //Rx instantiation
    receiver_2 rx(
        .areset(areset),
        .p_enbl(p_enbl),
        .rx_enbl(rx_enbl),
        .info(info),
        .dout(dout),
        .error(error),
        .fb(fb),
        .flag(flag)
    );
    
    //// FIFO for Rx instantiation
    rec_fifo rxf(
        .rx_enbl(rx_enbl),
        .areset(areset),
        .flag(flag),
        .dout(dout)
    );
endmodule