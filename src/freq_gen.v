module freq_gen #(
    parameter CLK_FREQ = 27000000,   // klokfrequentie in Hz
    parameter TARGET_FREQ = 1000     // gewenste frequentie in Hz
)(
    input  wire clk,
    output reg  out = 0
);

    parameter DIVIDER = CLK_FREQ / TARGET_FREQ;

    reg [25:0] cnt = 0;
    wire tick = (cnt == DIVIDER - 1);

    always @(posedge clk) begin
        if (tick) begin
            cnt <= 0;
            out <= !out;
        end else
            cnt <= cnt + 1;
    end

endmodule