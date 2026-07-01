module request_fifo
(
    input  logic        clk,
    input  logic        rst,

    input  logic        push,
    input  logic        pop,

    input  logic        rw_in,
    input  logic [21:0] addr_in,
    input  logic [15:0] wdata_in,

    output logic        rw_out,
    output logic [21:0] addr_out,
    output logic [15:0] wdata_out,

    output logic        full,
    output logic        empty
);

    localparam DEPTH = 4;

    logic [38:0] mem [0:DEPTH-1];

    logic [1:0] wr_ptr;
    logic [1:0] rd_ptr;
    logic [2:0] count;

    //-------------------------------------------------
    // Sequential FIFO Logic
    //-------------------------------------------------
    always_ff @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
        end
        else
        begin
            case ({push && !full, pop && !empty})

                //-------------------------------------------------
                // Push only
                //-------------------------------------------------
                2'b10:
                begin
                    mem[wr_ptr] <= {rw_in, addr_in, wdata_in};
                    wr_ptr <= wr_ptr + 1;
                    count  <= count + 1;
                end

                //-------------------------------------------------
                // Pop only
                //-------------------------------------------------
                2'b01:
                begin
                    rd_ptr <= rd_ptr + 1;
                    count  <= count - 1;
                end

                //-------------------------------------------------
                // Push and Pop simultaneously
                //-------------------------------------------------
                2'b11:
                begin
                    mem[wr_ptr] <= {rw_in, addr_in, wdata_in};
                    wr_ptr <= wr_ptr + 1;
                    rd_ptr <= rd_ptr + 1;
                    // count unchanged
                end

                default:
                begin
                    // no operation
                end

            endcase
        end
    end

    //-------------------------------------------------
    // Current Front Entry
    //-------------------------------------------------
    assign {rw_out, addr_out, wdata_out} = mem[rd_ptr];

    //-------------------------------------------------
    // Status Flags
    //-------------------------------------------------
    assign empty = (count == 0);
    assign full  = (count == DEPTH);

endmodule