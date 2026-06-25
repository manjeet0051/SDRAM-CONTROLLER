`timescale 1ns/1ps

module tb_command_encoder;

    logic [2:0] cmd;

    logic cs_n;
    logic ras_n;
    logic cas_n;
    logic we_n;

    // DUT
    command_encoder dut (
        .cmd   (cmd),
        .cs_n  (cs_n),
        .ras_n (ras_n),
        .cas_n (cas_n),
        .we_n  (we_n)
    );

    // Self-checking task
    task automatic check_command(
        input logic [2:0] command,
        input logic expected_cs,
        input logic expected_ras,
        input logic expected_cas,
        input logic expected_we
    );
    begin
        cmd = command;
        #1;

        if ({cs_n, ras_n, cas_n, we_n} !==
            {expected_cs,
             expected_ras,
             expected_cas,
             expected_we})
        begin
            $fatal(1,
                "[FAIL] cmd=%0d exp=%b%b%b%b got=%b%b%b%b",
                command,
                expected_cs,
                expected_ras,
                expected_cas,
                expected_we,
                cs_n,
                ras_n,
                cas_n,
                we_n
            );
        end

        $display(
            "[PASS] cmd=%0d -> CS=%0b RAS=%0b CAS=%0b WE=%0b",
            command,
            cs_n,
            ras_n,
            cas_n,
            we_n
        );
    end
    endtask


    // Test Sequence
    initial begin

        $display("\n----- Command Encoder Test -----");

        check_command(3'd0, 0,1,1,1); // NOP
        check_command(3'd1, 0,0,1,1); // ACTIVE
        check_command(3'd2, 0,1,0,1); // READ
        check_command(3'd3, 0,1,0,0); // WRITE
        check_command(3'd4, 0,0,1,0); // PRECHARGE
        check_command(3'd5, 0,0,0,1); // REFRESH
        check_command(3'd6, 0,0,0,0); // LOAD MODE
        check_command(3'd7, 0,1,1,1); // INVALID -> NOP

        $display("\nAll command encoder tests passed.\n");
        $finish;

    end

endmodule

