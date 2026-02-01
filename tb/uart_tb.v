`timescale 1ns / 1ps

module tb_topmodule;

    reg clk;
    reg areset;
    reg strt_enbl; 
    reg [7:0] din;
    reg write_en;
    reg p_enbl;
    
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
   // integer i;
//    initial begin
//    // 1. Initialize signals
//        areset = 1;
//        write_en = 0;
//        din = 8'h00;
//        #10 areset = 0;
//        @(posedge clk);

//    // 2. Loop through all 16 locations
//        for (i = 0; i < 16; i = i + 1) begin
//            write_en = 1;
        
//        // Use $random to generate a 32-bit random number 
//        // and assign it to the 8-bit wire (the simulator truncates the rest)
//            din = i+10; 
        
//            @(posedge clk);
//        end

//    // 3. Stop writing
//    write_en=0;
//    din=0;
    
//    $display("FIFO is successfully filled with random data.");
//end
    always begin
        #10 clk = ~clk;
    end
    task fifo_write(input [7:0] data);
        begin
            din=data;
            write_en=1;
        end
    endtask
    initial begin
        clk = 0;
        areset = 1;
        strt_enbl = 0;
        write_en=0;
        din = 8'h10;
        p_enbl = 0;
        
        #10;
        areset = 0;
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h23);
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h33);
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h43);
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h53);
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h63);
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h21);
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h31);
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h41);
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h51);
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h61);
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h27);
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h37);
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h47);
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h57);
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h67);
        @(posedge uut.baud.tx_enbl);
        fifo_write(8'h70);
        @(posedge uut.baud.tx_enbl);
        check_fifo_tx;
        #10;
        write_en=0;
        p_enbl = 0;
        //din = 8'h55;
        
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
//        repeat(11) @(posedge uut.tx_enbl);
//        force uut.info = 0;
//        @(posedge uut.tx_enbl);
//        release uut.info;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        wait(uut.tx.busy == 0);
        p_enbl = 1;
        strt_enbl = 1;
        @(posedge uut.baud.tx_enbl);
        strt_enbl = 0;
        
        
        //wait(busy == 0); 
        #35000;
           
        p_enbl = 0;
        
        
        #1000;
        check_fifo_rx;
        $finish;
    end
//    initial begin
//        #67190
//        force uut.rx.error = 1;
//        @(posedge uut.baud.tx_enbl);
//        release uut.rx.error;
//    end
//    initial begin
//        #118071
//        force uut.info = 1'b1;
//        @(posedge uut.tx_enbl);
//        release uut.info;
//    end
    task check_fifo_tx;
    begin
    $display("fifo content %t",$time);
    for(i=0; i<16; i=i+1)begin
        $display("addr[%d]: data=%h",i,uut.txf.mem[i]);
    end
    end
    endtask
    
    
    task check_fifo_rx;
    begin
    $display("fifo content %t",$time);
    for(i=0; i<16; i=i+1)begin
        $display("addr[%d]: data=%h",i,uut.rxf.mem[i]);
    end
    end
   endtask
endmodule