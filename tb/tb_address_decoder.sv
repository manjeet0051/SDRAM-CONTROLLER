`timescale 1ns/1ps

module tb_address_decoder;

    logic [21:0] addr;

    logic [1:0]  bank;
    logic [11:0] row;
    logic [7:0]  col;

   
    // DUT
    address_decoder dut (
        .addr (addr),
        .bank (bank),
        .row  (row),
        .col  (col)
    );

    
    // Self-checking task
    task automatic check_addr(
        input logic [21:0] address
    );
    begin
        addr = address;
        #1;

        if (bank !== address[21:20] ||
            row  !== address[19:8]  ||
            col  !== address[7:0])
        begin
            $fatal(
                1,
                "[FAIL] addr=%h bank=%h row=%h col=%h",
                address,
                bank,
                row,
                col
            );
        end

        $display(
            "[PASS] addr=%h -> bank=%0d row=%0d col=%0d",
            address,
            bank,
            row,
            col
        );
    end
    endtask

    
    // Test Sequence
    initial begin

        $display("\n----- Address Decoder Test -----");

        check_addr(22'h000000);
        check_addr(22'h123456);
        check_addr(22'h2ABCDE);
        check_addr(22'h3FFFFF);

        $display("\nAll address decoder tests passed.\n");

        $finish;

    end

endmodule