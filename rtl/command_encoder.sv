module command_encoder
(
    input  logic [2:0] cmd,

    output logic cs_n,
    output logic ras_n,
    output logic cas_n,
    output logic we_n
);

    localparam CMD_NOP        = 3'd0;
    localparam CMD_ACTIVE     = 3'd1;
    localparam CMD_READ       = 3'd2;
    localparam CMD_WRITE      = 3'd3;
    localparam CMD_PRECHARGE  = 3'd4;
    localparam CMD_REFRESH    = 3'd5;
    localparam CMD_LOAD_MODE  = 3'd6;

    always_comb
    begin
        cs_n  = 1'b0;
        ras_n = 1'b1;
        cas_n = 1'b1;
        we_n  = 1'b1;

        unique case(cmd)

            CMD_NOP:
                {ras_n, cas_n, we_n} = 3'b111;

            CMD_ACTIVE:
                {ras_n, cas_n, we_n} = 3'b011;

            CMD_READ:
                {ras_n, cas_n, we_n} = 3'b101;

            CMD_WRITE:
                {ras_n, cas_n, we_n} = 3'b100;

            CMD_PRECHARGE:
                {ras_n, cas_n, we_n} = 3'b010;

            CMD_REFRESH:
                {ras_n, cas_n, we_n} = 3'b001;

            CMD_LOAD_MODE:
                {ras_n, cas_n, we_n} = 3'b000;

            default:
                {ras_n, cas_n, we_n} = 3'b111;

        endcase
    end

endmodule