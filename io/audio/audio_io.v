module audio_io (
    input wire clk,
    input wire ce,
    input wire rd,
    input wire wr,
    input wire [15:0] ad,
    inout wire [7:0] data_bus,
    input wire aud_in,
    output reg aud_out
);

always @(posedge clk) begin
    if (ce && wr) begin
        aud_out <= data_bus[4] ^ data_bus[3]; // data_bus[3] voor save
    end
end

endmodule