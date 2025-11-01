module tape_recorder (
    input  wire        clk,        // kies clk_spectrum of 27MHz sysclk
    input  wire        reset_n,
    input  wire        aud_out,    // MIC / signal from spectrum when recording
    output reg         aud_in,     // EAR -> to spectrum during play
    input  wire        btn_rec,
    input  wire        btn_play
);

    // parameters: stel deze in voor jouw klok
    parameter integer SAMPLE_RATE = 8000; // gewenste sample rate in Hz
    parameter integer CLK_FREQ = 27000000; // zet hier jouw sample-klokfrequentie (Hz)
    localparam integer DIVIDER = CLK_FREQ / SAMPLE_RATE;

    // 8 KB RAM - we store 8 samples per byte (bitpacked LSB-first)
    reg [7:0] tape_mem [0:8191];
    reg [12:0] byte_addr;
    reg [2:0] bit_idx;   // 0..7
    reg [12:0] length_bytes;
    reg [2:0] length_bits; // remainder bits
    reg [1:0] state;
    localparam IDLE=2'd0, RECORD=2'd1, PLAY=2'd2;

    // sample divider
    reg [31:0] cnt;

    // detect sample tick
    wire sample_tick = (cnt >= DIVIDER-1);

    // sample divider logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            cnt <= 0;
        end else begin
            if (sample_tick)
                cnt <= 0;
            else
                cnt <= cnt + 1;
        end
    end

    // recorder state machine with bitpacking
    reg [7:0] cur_byte;
    integer i;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            byte_addr <= 0;
            bit_idx <= 0;
            cur_byte <= 8'h00;
            length_bytes <= 0;
            length_bits <= 0;
            aud_in <= 1'b1;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    aud_in <= 1'b1;
                    if (btn_rec) begin
                        byte_addr <= 0;
                        bit_idx <= 0;
                        cur_byte <= 8'h00;
                        state <= RECORD;
                    end else if (btn_play) begin
                        byte_addr <= 0;
                        bit_idx <= 0;
                        state <= PLAY;
                    end
                end

                RECORD: begin
                    if (sample_tick) begin
                        // pack LSB-first
                        cur_byte[bit_idx] <= aud_out;
                        bit_idx <= bit_idx + 1;
                        if (bit_idx == 3'd7) begin
                            // store byte
                            tape_mem[byte_addr] <= cur_byte;
                            byte_addr <= byte_addr + 1;
                            cur_byte <= 8'h00;
                            bit_idx <= 0;
                            if (byte_addr == 13'd8191) begin
                                // memory full -> stop
                                length_bytes <= 13'd8191;
                                length_bits <= 0;
                                state <= IDLE;
                            end
                        end
                    end
                    if (!btn_rec) begin
                        // stop recording: write any partial byte
                        if (bit_idx != 0) begin
                            tape_mem[byte_addr] <= cur_byte;
                            length_bytes <= byte_addr;
                            length_bits <= bit_idx;
                        end else begin
                            length_bytes <= byte_addr - 1;
                            length_bits <= 3'd7; // full last byte
                        end
                        state <= IDLE;
                    end
                end

                PLAY: begin
                    if (sample_tick) begin
                        // output LSB-first
                        aud_in <= tape_mem[byte_addr][bit_idx];
                        bit_idx <= bit_idx + 1;
                        if (bit_idx == 3'd7) begin
                            bit_idx <= 0;
                            if (byte_addr < length_bytes) begin
                                byte_addr <= byte_addr + 1;
                            end else begin
                                // if last byte and last bit done -> stop
                                state <= IDLE;
                                aud_in <= 1'b1;
                            end
                        end
                    end
                    if (!btn_play) begin
                        state <= IDLE;
                        aud_in <= 1'b1;
                    end
                end

            endcase
        end
    end
endmodule
