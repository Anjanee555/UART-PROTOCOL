`timescale 1ns / 1ps

module tb_topmodule;

    reg       clk;
    reg       areset;
    reg       strt_enbl; 
    reg [7:0] din;
    reg       write_en;
    reg       p_enbl;
    
    //wire busy;
    //wire [7:0] dout;
     
    wire error;
    integer i;

    topmodule uut (
        .clk(clk),
        .areset(areset),
        //.write_en(write_en),
        .strt_enbl(strt_enbl),
        .din(din), 
        .write_en(write_en),
        .p_enbl(p_enbl),
        //.busy(busy),
        //.dout(dout),
        .error(error)
    );
    always begin
        #10 clk = ~clk;
    end
    
    //task to enter value in txfifo
    task fifo_write(input [7:0] data);
        begin
            @(posedge uut.baud.tx_enbl);
            din=data;
            write_en=1;
            @(negedge uut.baud.tx_enbl);
            write_en=0; 
            //@(posedge uut.baud.tx_enbl);
        end
    endtask
    
    //task to give output to tx from fifo
    task transmit(input parity_enbl);
        begin
            p_enbl=parity_enbl;
           // @(posedge uut.baud.tx_enbl);
            strt_enbl=1;
            @(posedge uut.baud.tx_enbl);
            strt_enbl=0;
            @(posedge uut.baud.tx_enbl);
            @(posedge uut.baud.tx_enbl);
            
            wait(uut.tx.busy==0);
            
        end
    endtask
    
    
    initial begin
        clk       = 0;
        areset    = 1;
        strt_enbl = 0;
        write_en  =0;
        din = 8'h10;
        p_enbl    = 0;
        
        #10;
        areset = 0;
        //@(posedge uut.baud.tx_enbl);
        fifo_write(8'h23);
        //@(posedge uut.baud.tx_enbl);
        fifo_write(8'h33);
        //@(posedge uut.baud.tx_enbl);
        fifo_write(8'h43);
        //@(posedge uut.baud.tx_enbl);
        fifo_write(8'h53);
        //@(posedge uut.baud.tx_enbl);
        fifo_write(8'h63);
//        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h01);
        fifo_write(8'h12);
        fifo_write(8'h24);
        fifo_write(8'h33);
        fifo_write(8'h46);
        fifo_write(8'h77);
        fifo_write(8'h81);
        fifo_write(8'h13);  
        fifo_write(8'h15);  
        fifo_write(8'h67);
        fifo_write(8'h69);  
        fifo_write(8'h96);
        fifo_write(8'h66);
        
         
        
        @(posedge uut.baud.tx_enbl);  ///we need one clock cycle before writing the data on to the transmitter
        transmit(0);
        transmit(1);
        transmit(1);
        transmit(1);
        transmit(1); 
        transmit(1);
        transmit(1);
        transmit(1);
        transmit(1);
        transmit(1);
        transmit(1); 
        transmit(1);
        transmit(1);
        transmit(1); 
        transmit(1);
        transmit(1);
        transmit(1);
        @(posedge uut.baud.tx_enbl);
        p_enbl=0;
        
        check_fifo_tx;
        repeat(8) @(posedge uut.baud.tx_enbl);
        check_fifo_rx;
        $finish;
    end
    
    //forcing parity error for 77 so the flag goes low for 77 and it does not go into rx fifo 
    //and the fb signal asks the tx buffer to resend the next data as the prev data(77) is not received correctly
    
    initial begin
        #331192
        force uut.rx.info = 1;
        @(posedge uut.baud.tx_enbl);
        release uut.rx.info;
    end
    
    
    //task for checking tx fifo
    task check_fifo_tx;
    begin
    @(posedge uut.baud.tx_enbl);
    $display("fifo content %t",$time);
    for(i = 0; i < 16; i = i+1)begin
        $display("addr[%d]: data = %h",i,uut.txf.mem[i]);
    end
    end
    endtask
    
    //task for checking fifo buffer of rx
    task check_fifo_rx;
    begin
    $display("fifo content %t",$time);
    for(i = 0; i < 16; i = i+1)begin
        $display("addr[%d]: data = %h",i,uut.rxf.mem[i]);
    end
    end
   endtask
endmodule