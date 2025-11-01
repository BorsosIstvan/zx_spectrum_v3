module datapijp_fb (
    input wire clk,
    input wire reset_n,
    input wire de,
    input wire [10:0] hcnt,
    input wire [10:0] vcnt,
    output reg [23:0] rgb,
    output reg [12:0] video_addr,
    input wire [7:0] video_dout
);

    // =================== Pixel & Attribute berekening ===================
    wire [7:0] h = hcnt[9:2];
    wire [7:0] v = vcnt[9:2];

    wire [13:0] pix_addr  = { v[7:6], v[2:0], v[5:3], h[7:3] };
    wire [13:0] attr_addr = 14'd6144 + {v[7:3], h[7:3]};
    wire [2:0] bitpos = 3'd7 - h[2:0];

    // =================== Pipelined registers ===================
    reg [7:0] pixel_byte, pixel_byte_d;
    reg [7:0] attr_byte, attr_byte_d;
    reg [1:0] read_phase;

    // =================== Flash generator ===================
    reg flash;
    reg [5:0] flash_cnt;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            flash <= 0;
            flash_cnt <= 0;
        end else if (vcnt == 0 && hcnt == 0) begin
            if (flash_cnt == 31) begin
                flash_cnt <= 0;
                flash <= ~flash;
            end else begin
                flash_cnt <= flash_cnt + 1;
            end
        end
    end

    // =================== Main datapipeline ===================
    reg [2:0] final_color;
    always @(posedge clk) begin
        if (!reset_n) begin
            video_addr <= 0;
            pixel_byte <= 0;
            pixel_byte_d <= 0;
            attr_byte <= 0;
            attr_byte_d <= 0;
            read_phase <= 0;
            rgb <= 0;
            final_color <= 0;
        end else if (de) begin
            // Pipelined read: pixel byte en attr byte
            case (read_phase)
                0: begin
                    video_addr <= pix_addr;
                    pixel_byte <= video_dout;
                    read_phase <= 1;
                end
                1: begin
                    video_addr <= attr_addr;
                    attr_byte <= video_dout;
                    read_phase <= 0;
                end
            endcase

            pixel_byte_d <= pixel_byte;
            attr_byte_d <= attr_byte;

            // =================== Bereken final_color ===================
            if (attr_byte_d[7] && flash) begin
                // Flash actief: swap ink en paper
                final_color <= pixel_byte[bitpos] ? attr_byte_d[5:3] : attr_byte_d[2:0];
            end else begin
                final_color <= pixel_byte[bitpos] ? attr_byte_d[2:0] : attr_byte_d[5:3];
            end

            // =================== Bereken RGB met Bright ===================
            rgb[23:16] <= final_color[2] ? (attr_byte_d[6] ? 8'hFF : 8'hC0) : 8'h00;
            rgb[15:8]  <= final_color[1] ? (attr_byte_d[6] ? 8'hFF : 8'hC0) : 8'h00;
            rgb[7:0]   <= final_color[0] ? (attr_byte_d[6] ? 8'hFF : 8'hC0) : 8'h00;
        end
    end

endmodule
