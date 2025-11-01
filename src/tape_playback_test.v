module tape_playback_test #(
    parameter CLK_FREQ      = 27000000,
    parameter PILOT_FREQ    = 1200,         // pilot 1200 Hz
    parameter PILOT_CYCLES  = 2168,         // aantal pilot pulsen (~1 sec)
    parameter BIT0_FREQ     = 2400,         // halve golf bit 0
    parameter BIT1_FREQ     = 1200          // halve golf bit 1
)(
    input  wire clk,
    input  wire reset_n,
    input  wire play_start,
    output reg  aud_out
);

    // interne registers
    reg [1:0] state; // 0=pilot1,1=header+pilot2,2=data
    reg [15:0] clk_cnt;
    reg [12:0] bit_idx;
    reg [12:0] byte_idx;
    reg [7:0] cur_byte;
    reg phase;
    reg [12:0] pilot_cnt;

    localparam STATE_PILOT1 = 2'd0;
    localparam STATE_HEADER  = 2'd1;
    localparam STATE_PILOT2  = 2'd2;
    localparam STATE_DATA    = 2'd3;

    // clock cycles per half wave
    localparam PILOT_PERIOD = CLK_FREQ / (PILOT_FREQ * 2);
    localparam BIT0_PERIOD  = CLK_FREQ / (BIT0_FREQ * 2);
    localparam BIT1_PERIOD  = CLK_FREQ / (BIT1_FREQ * 2);

    // tape content (header + data)
    reg [7:0] tape_mem [0:26]; // 17 header + 9 data
    initial begin
        // header
        tape_mem[0]  = 8'h00; // type
        tape_mem[1]  = 8'h07; tape_mem[2] = 8'h00; // length
        tape_mem[3]  = 8'h00; tape_mem[4] = 8'h5B; // start addr
        tape_mem[5]  = 8'h48; tape_mem[6] = 8'h45; tape_mem[7] = 8'h4C; tape_mem[8] = 8'h4C; tape_mem[9] = 8'h4F;
        tape_mem[10] = 8'h20; tape_mem[11] = 8'h20; tape_mem[12] = 8'h20; tape_mem[13] = 8'h20; tape_mem[14] = 8'h20;
        tape_mem[15] = 8'h00; // checksum (dummy)
        tape_mem[16] = 8'h00;
        // data
        tape_mem[17] = 8'h0A; tape_mem[18] = 8'h00; tape_mem[19] = 8'hF0;
        tape_mem[20] = 8'h48; tape_mem[21] = 8'h45; tape_mem[22] = 8'h4C; tape_mem[23] = 8'h4C; tape_mem[24] = 8'h4F;
        tape_mem[25] = 8'h0D; tape_mem[26] = 8'h00; // checksum dummy
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            aud_out <= 1'b1;
            state <= STATE_PILOT1;
            clk_cnt <= 0;
            pilot_cnt <= 0;
            byte_idx <= 0;
            bit_idx <= 0;
            cur_byte <= 0;
            phase <= 0;
        end else begin
            if(play_start) begin
                clk_cnt <= clk_cnt + 1;

                case(state)
                    STATE_PILOT1: begin
                        if(clk_cnt >= PILOT_PERIOD) begin
                            clk_cnt <= 0;
                            aud_out <= ~aud_out;
                            phase <= ~phase;
                            if(phase) pilot_cnt <= pilot_cnt + 1;
                            if(pilot_cnt >= PILOT_CYCLES) begin
                                state <= STATE_HEADER;
                                byte_idx <= 0;
                                bit_idx <= 0;
                                cur_byte <= tape_mem[0];
                                clk_cnt <= 0;
                            end
                        end
                    end

                    STATE_HEADER: begin
                        // bits LSB first
                        if(clk_cnt >= ((cur_byte[7-bit_idx]) ? BIT1_PERIOD : BIT0_PERIOD)) begin
                            clk_cnt <= 0;
                            aud_out <= ~aud_out;
                            phase <= ~phase;
                            if(phase) begin
                                if(bit_idx == 7) begin
                                    bit_idx <= 0;
                                    byte_idx <= byte_idx + 1;
                                    if(byte_idx == 16) begin
                                        state <= STATE_PILOT2;
                                        pilot_cnt <= 0;
                                        clk_cnt <= 0;
                                        aud_out <= 1'b1;
                                    end else begin
                                        cur_byte <= tape_mem[byte_idx+1];
                                    end
                                end else begin
                                    bit_idx <= bit_idx + 1;
                                end
                            end
                        end
                    end

                    STATE_PILOT2: begin
                        if(clk_cnt >= PILOT_PERIOD) begin
                            clk_cnt <= 0;
                            aud_out <= ~aud_out;
                            phase <= ~phase;
                            if(phase) pilot_cnt <= pilot_cnt + 1;
                            if(pilot_cnt >= 2) begin // korte pilot (2 pulses)
                                state <= STATE_DATA;
                                byte_idx <= 17;
                                bit_idx <= 0;
                                cur_byte <= tape_mem[17];
                            end
                        end
                    end

                    STATE_DATA: begin
                        if(clk_cnt >= ((cur_byte[7-bit_idx]) ? BIT1_PERIOD : BIT0_PERIOD)) begin
                            clk_cnt <= 0;
                            aud_out <= ~aud_out;
                            phase <= ~phase;
                            if(phase) begin
                                if(bit_idx == 7) begin
                                    bit_idx <= 0;
                                    byte_idx <= byte_idx + 1;
                                    if(byte_idx > 26) begin
                                        state <= STATE_PILOT1; // stop playback
                                        aud_out <= 1'b1;
                                    end else begin
                                        cur_byte <= tape_mem[byte_idx+1];
                                    end
                                end else begin
                                    bit_idx <= bit_idx + 1;
                                end
                            end
                        end
                    end
                endcase
            end
        end
    end

endmodule
