module address_decoder
(
    input  logic [21:0] addr,
    output logic [1:0]  bank,
    output logic [11:0] row,
    output logic [7:0]  col
);

    assign bank = addr[21:20];
    assign row  = addr[19:8];
    assign col  = addr[7:0];

endmodule