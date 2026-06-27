`timescale 1ns/1ps

module tb_refresh_timer;

    logic clk;
    logic rst;
    logic refresh_ack;

    logic refresh_req;

    refresh_timer
    #(
        .REFRESH_PERIOD(5)
    )
    dut
    (
        .clk(clk),
        .rst(rst),
        .refresh_ack(refresh_ack),
        .refresh_req(refresh_req)
    );

    
    // Clock
    initial
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test
    initial
    begin

        rst = 1;
        refresh_ack = 0;

        repeat(2)
            @(posedge clk);

        rst = 0;

    
        // Wait for refresh request
        wait(refresh_req);

        $display(
            "[PASS] Refresh request generated"
        );

       
        // Acknowledge refresh
        @(posedge clk);
        refresh_ack = 1;

        @(posedge clk);
        refresh_ack = 0;

        if (!refresh_req)
            $display(
                "[PASS] Refresh request cleared"
            );
        else
        begin
            $display(
                "[FAIL] Refresh request not cleared"
            );
            $finish;
        end


        // Verify second refresh generation
        wait(refresh_req);

        $display(
            "[PASS] Second refresh request generated"
        );

        $display(
            "\nAll refresh timer tests passed.\n"
        );

        $finish;

    end

endmodule