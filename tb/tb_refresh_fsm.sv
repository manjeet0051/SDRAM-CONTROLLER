`timescale 1ns/1ps

module tb_refresh_fsm;

    logic clk;
    logic rst;

    logic refresh_req;
    logic timer_done;

    logic [2:0] cmd;
    logic timer_start;
    logic [7:0] timer_cycles;
    logic refresh_ack;

  
    // DUT
    refresh_fsm dut (
        .clk          (clk),
        .rst          (rst),
        .refresh_req  (refresh_req),
        .timer_done   (timer_done),
        .cmd          (cmd),
        .timer_start  (timer_start),
        .timer_cycles (timer_cycles),
        .refresh_ack  (refresh_ack)
    );

    
    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    
    // Test
    initial begin

        rst         = 1;
        refresh_req = 0;
        timer_done  = 0;

        repeat (2)
            @(posedge clk);

        rst = 0;

       
        // Request refresh
        @(posedge clk);
        refresh_req = 1;

        @(posedge clk);
        refresh_req = 0;

        
        // PRECHARGE
        @(posedge clk);

        if (cmd == 3'd4)
            $display("[PASS] PRECHARGE command issued");
        else
            $fatal(1, "[FAIL] PRECHARGE missing");

        
        // REFRESH
        @(posedge clk);

        if (cmd == 3'd5 &&
            timer_start &&
            timer_cycles == 7)
        begin
            $display("[PASS] REFRESH command issued");
        end
        else
            $fatal(1, "[FAIL] REFRESH state failed");

        // Complete tRFC wait
        repeat (3)
            @(posedge clk);

        timer_done = 1;
        @(posedge clk);
        timer_done = 0;

        
        // DONE state
        @(posedge clk);

        if (refresh_ack)
            $display("[PASS] Refresh acknowledged");
        else
            $fatal(1, "[FAIL] Refresh acknowledgement missing");

        $display("\nAll refresh FSM tests passed.\n");

        $finish;

    end

endmodule