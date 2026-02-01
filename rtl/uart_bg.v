`timescale 1ns / 1ps

module uart_baud_rate_gen 
#(
    parameter integer CLK_FREQ  = 48000000,  // System clock (Hz)
    parameter integer BAUD_RATE = 1000000    // UART baud rate
)( 
    input  wire clk,
    input  wire areset,
    output reg  tx_enbl,   // Baud rate clock (TX)
    output reg  rx_enbl    // 16x Baud rate clock (RX)
);

    localparam integer TX_DIV_HALF = (CLK_FREQ) / (BAUD_RATE);   //// division factor showing how many system clk cycles are required to constitute 1 cycle tx and rx clk
    localparam integer RX_DIV_HALF = CLK_FREQ / (16 * BAUD_RATE);        

    reg [$clog2(TX_DIV_HALF)-1:0] tx_cnt;  //// this function is used to avoid the decimal counts 
    reg [$clog2(RX_DIV_HALF)-1:0] rx_cnt;

    always @(posedge clk or posedge areset) begin
        if (areset) begin
            tx_cnt   <= 0; 
            rx_cnt   <= 0;
            tx_enbl  <= 1'b0;
            rx_enbl  <= 1'b0;
        end else begin
            // TX Clock Generation (Baud Rate)
            if (tx_cnt == TX_DIV_HALF - 1) begin
                tx_cnt  <= 0;
                tx_enbl <= ~tx_enbl; // Toggle to create 50% duty cycle clock
            end else begin
                tx_cnt  <= tx_cnt + 1'b1;
            end

            // RX Clock Generation (16x Baud Rate)   /// 16 rx cllk cycles == 1 tx clk cycle
            if (rx_cnt == RX_DIV_HALF - 1) begin 
                rx_cnt <= 0;
                rx_enbl <= ~rx_enbl; // Toggle to create 50% duty cycle clock
            end else begin
                rx_cnt  <= rx_cnt + 1'b1;
            end
        end
    end

endmodule