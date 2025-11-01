module datapijp (
    input wire clk,
    input wire reset_n,
    input wire de,
    input wire [10:0] hcnt,
    input wire [10:0] vcnt,
    output reg [24:0] rgb,
    output wire [12:0] video_addr,
    input wire [7:0] video_dout

);
    // Pixel & attribute berekeningen

    wire [7:0] h = hcnt[9:2];
    wire [7:0] v = vcnt[9:2];
    wire [13:0] pix_addr  = { v[7:6], v[2:0], v[5:3], h[7:3] };
    wire [13:0] attr_addr = 6144 + {v[7:3], h[7:3]};  
    wire [2:0] bitpos = 8 - h[2:0];

    // Pipelined registers
    reg [7:0] pixel_byte, pixel_byte_d;
    reg [7:0] attr_byte, attr_byte_d;
    reg [1:0] read_phase;

    reg [12:0] video_addr;
    wire [7:0] video_dout;

    always @(posedge clk) begin
        if (!reset_n) begin
            video_addr <= 0;
        end else if (de) begin
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

            rgb <= pixel_byte_d[bitpos] ? {
                attr_byte_d[2] ? 8'hC0 : 8'h00, 
                attr_byte_d[1] ? 8'hC0 : 8'h00, 
                attr_byte_d[0] ? 8'hC0 : 8'h00} : {
                attr_byte_d[5] ? 8'hC0 : 8'h00, 
                attr_byte_d[4] ? 8'hC0 : 8'h00, 
                attr_byte_d[3] ? 8'hC0 : 8'h00} ;
        end
    end

endmodule