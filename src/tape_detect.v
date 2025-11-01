module sync_detector #(
    parameter integer CLK_FREQ = 27000000, // 27 MHz
    parameter integer SYNC_MIN = CLK_FREQ/4000, // 250 µs
    parameter integer SYNC_MAX = CLK_FREQ/200  // 5 ms (voorbeeld)       
)(
    input  wire clk,        // measurement clock (bijv. clk_spectrum)
    input  wire reset_n,
    input  wire aud,        // audio input (signal from audio_io aud_out)
    output reg detected     // asserted when pilot is detected
);


    // registers
    reg aud_d;
    reg [15:0] edge_counter;
    reg [15:0] period;
    reg sync_detected;

    // edge detection and timing
    always @(posedge clk) begin
        aud_d <= aud;

        // rising edge detect
        if(aud && !aud_d) begin
            period <= edge_counter;
            edge_counter <= 0;

            // check periode voor sync
            if(period > SYNC_MIN && period < SYNC_MAX) begin
                detected <= 1;
            end else begin
                detected <= 0;
            end
        end else begin
            edge_counter <= edge_counter + 1;
        end
    end
endmodule
