module tape_bit_reader #(
    parameter integer CLK_FREQ = 27000000, // systeemklok
    // tijdsvensters voor Spectrum tape pulsen
    parameter integer TICKS_0_MIN = 5400,   // ~200 µs
    parameter integer TICKS_0_MAX = 9000,   // ~333 µs
    parameter integer TICKS_1_MIN = 10800,  // ~400 µs
    parameter integer TICKS_1_MAX = 18000   // ~667 µs
)(
    input  wire clk,
    input  wire reset_n,
    input  wire aud,           // audio signaal van de Spectrum (digital waveform)
    input  wire start,         // start van bitdetectie (sync_detected)
    output reg  data_out,      // 0 of 1 bit
    output reg  data_valid,    // 1 clk puls bij nieuwe bit
    output reg  edge_led       // knippert bij elke flank (debug)
);

    reg aud_d;
    reg [31:0] edge_counter;
    reg [31:0] period;
    reg active;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            aud_d        <= 0;
            edge_counter <= 0;
            period       <= 0;
            data_out     <= 0;
            data_valid   <= 0;
            edge_led     <= 0;
            active       <= 0;
        end else begin
            data_valid <= 0; // standaard laag

            // Starten als sync gedetecteerd is
            if (start)
                active <= 1;

            if (active) begin
                // flankdetectie
                aud_d <= aud;
                edge_counter <= edge_counter + 1;

                if (aud && !aud_d) begin
                    // toggle debug LED
                    edge_led <= ~edge_led;

                    // meet periode
                    period <= edge_counter;
                    edge_counter <= 0;

                    // bepaal bitwaarde
                    if (period > TICKS_0_MIN && period < TICKS_0_MAX) begin
                        data_out   <= 0;
                        data_valid <= 1;
                    end
                    else if (period > TICKS_1_MIN && period < TICKS_1_MAX) begin
                        data_out   <= 1;
                        data_valid <= 1;
                    end
                    else begin
                        // te lang → waarschijnlijk einde van blok
                        data_out   <= 0;
                        data_valid <= 0;
                    end
                end
            end
        end
    end
endmodule
