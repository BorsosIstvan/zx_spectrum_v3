module timing (
        input clk_pixel,
        input reset_n,
        output reg de,
        output reg hs,
        output reg vs,
        output reg [10:0] hcnt,
        output reg [10:0] vcnt
    );
localparam integer H_ACTIVE = 1024;
localparam integer H_FRONT = 24;
localparam integer H_SYNC = 136;
localparam integer H_BACK = 160;
localparam integer H_TOTAL = H_ACTIVE + H_FRONT + H_SYNC + H_BACK;

localparam integer V_ACTIVE = 768;
localparam integer V_FRONT = 3;
localparam integer V_SYNC = 6;
localparam integer V_BACK = 29;
localparam integer V_TOTAL = V_ACTIVE + V_FRONT + V_SYNC + V_BACK;


always @(posedge clk_pixel or negedge reset_n) begin
    if (!reset_n) begin
        hcnt <= 0;
        vcnt <= 0;
    end else begin
        if (hcnt == H_TOTAL-1) begin
            hcnt <= 0;
            if (vcnt == V_TOTAL-1) begin
                vcnt <= 0;
            end else begin
                vcnt <= vcnt + 1;
            end
        end else begin
            hcnt <= hcnt + 1;
        end
    end
end

always @(posedge clk_pixel) begin
    // Data Enable (DE): binnen actieve resolutie
    if ((hcnt < H_ACTIVE) && (vcnt < V_ACTIVE)) begin
        de <= 1'b1;
    end else begin
        de <= 1'b0;
    end

    // Horizontal Sync (HS)
    if ((hcnt >= H_ACTIVE + H_FRONT) &&
        (hcnt <  H_ACTIVE + H_FRONT + H_SYNC)) begin
        hs <= 1'b1;
    end else begin
        hs <= 1'b0;
    end

    // Vertical Sync (VS)
    if ((vcnt >= V_ACTIVE + V_FRONT) &&
        (vcnt <  V_ACTIVE + V_FRONT + V_SYNC)) begin
        vs <= 1'b1;
    end else begin
        vs <= 1'b0;
    end
end


assign hcount = hcnt;
assign vcount = vcnt;

endmodule