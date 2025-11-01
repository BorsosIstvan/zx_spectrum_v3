module hdmi (
    input wire clk,
    input wire reset_n,

    output wire tmds_clk_n,
    output wire tmds_clk_p,
    output wire [2:0] tmds_data_n,
    output wire [2:0] tmds_data_p,

    output wire rgb_clk,
    output wire [12:0] video_addr,
    input wire [7:0] video_dout
);

wire serial_clk, rgb_clk, rgb_vs, rgb_hs, rgb_de;
wire [23:0] rgb;
// ============== tmds serialiser =========================

	DVI_TX_Top your_instance_name(
		.I_rst_n(reset_n),
		.I_serial_clk(serial_clk),
		.I_rgb_clk(rgb_clk),
		.I_rgb_vs(rgb_vs),
		.I_rgb_hs(rgb_hs),
		.I_rgb_de(rgb_de),
		.I_rgb_r(rgb[23:16]),
		.I_rgb_g(rgb[15:8]),
		.I_rgb_b(rgb[7:0]),
		.O_tmds_clk_p(tmds_clk_p),
		.O_tmds_clk_n(tmds_clk_n),
		.O_tmds_data_p(tmds_data_p),
		.O_tmds_data_n(tmds_data_n)
	);

// =============== timing 1024x768 ========================
wire de, hs, vs;
wire [10:0] hcnt, vcnt;
    timing timing1024x768 (
        .clk_pixel(rgb_clk),
        .reset_n(reset_n),
        .de(rgb_de),
        .hs(rgb_hs),
        .vs(rgb_vs),
        .hcnt(hcnt),
        .vcnt(vcnt)
    );
// ================ pattern gen ==========================
/*
wire [23:0] rgb;
    pattern colorbaar (
        .clk_pixel(rgb_clk),
        .reset_n(reset_n),
        .hcnt(hcnt),
        .vcnt(vcnt),
        .rgb(rgb)
    );
*/
// ================ clock 125 mHz 25 mHz =================
    Gowin_rPLL_125_mhz clk_125(
        .clkout(serial_clk), //output clkout
        .clkin(clk) //input clkin
    );
    Gowin_CLKDIV_25_mhz clk_25(
        .clkout(rgb_clk), //output clkout
        .hclkin(serial_clk), //input hclkin
        .resetn(reset_n) //input resetn
    );

// ================ dram voor test ======================
    datapijp_fb dpijp (
        .clk(rgb_clk),
        .reset_n(reset_n),
        .de(rgb_de),
        .hcnt(hcnt),
        .vcnt(vcnt),
        .rgb(rgb),
        .video_addr(video_addr),
        .video_dout(video_dout)
    );

endmodule