module top (
    input wire clk,
//    input wire reset_n,
    input wire rxd,

    input wire btn_play,
    input wire btn_rec,

    output wire [5:0] led,

    output wire tmds_clk_n,
    output wire tmds_clk_p,
    output wire [2:0] tmds_data_n,
    output wire [2:0] tmds_data_p
);

    wire reset_n;
    assign reset_n = (!btn_play && !btn_rec)? 1'b0 : 1'b1;

// =============== hdmi =================

hdmi my_hdmi (
    .clk(clk),
    .reset_n(reset_n),
    .tmds_clk_n(tmds_clk_n),
    .tmds_clk_p(tmds_clk_p),
    .tmds_data_n(tmds_data_n),
    .tmds_data_p(tmds_data_p),
    .rgb_clk(clk_video),
    .video_addr(video_addr),
    .video_dout(video_dout)
);

// =============== video ram ============
wire [12:0] video_addr;
wire [7:0] video_dout;
wire clk_video;


// ==============gowin dram ===========
Gowin_DPB gw_dram(
    .douta(douta), //output [7:0] douta
    .doutb(video_dout), //output [7:0] doutb
    .clka(clk), //input clka
    .ocea(~rd_n), //input ocea
    .cea(ram_cs[2]), //input cea
    .reseta(!reset_n), //input reseta
    .wrea(~wr_n), //input wrea
    .clkb(clk_video), //input clkb
    .oceb(1'b1), //input oceb
    .ceb(1'b1), //input ceb
    .resetb(!reset_n), //input resetb
    .wreb(1'b0), //input wreb
    .ada(address_bus[12:0]), //input [12:0] ada
    .dina(data_bus), //input [7:0] dina
    .adb(video_addr), //input [12:0] adb
    .dinb(8'b0) //input [7:0] dinb
);
// ============= tristate bus ===============

wire [7:0] douta;
assign data_bus = (!rd_n && ram_cs[2]) ? douta : 8'bz;

// ============= decoder =========
wire [7:0] ram_cs, io_cs;
decoder ula (
    .mreq_n(mreq_n),
    .iorq_n(iorq_n),
    .ad(address_bus),
    .ram_cs(ram_cs),
    .io_cs(io_cs)
);

// ============= cpu Z80a =========
wire [15:0] address_bus;
wire [7:0] data_bus;
wire int_n, iorq_n, mreq_n, rd_n, wr_n;
cpu_z80a Z80A (
    .clk(clk),
    .reset_n(reset_n),
    .address_bus(address_bus),
    .data_bus(data_bus),
    .halt_n(1'b1),
    .int_n(int_n),
    .iorq_n(iorq_n),
    .mreq_n(mreq_n),
    .rd_n(rd_n),
    .wr_n(wr_n)
);

// 50 Hz interrupt 
int50hz (
    .clk(clk_spectrum),
    .reset_n(reset_n),
    .int_n(int_n)
);

// ============== rom =================

rom0_reg rom0 (
    .clk(clk),
    .reset(!reset_n),
    .ce(ram_cs[0]),
    .oce(~rd_n),
    .wre(1'b0),
    .ad(address_bus[12:0]),
    .data_bus(data_bus)
);

rom1_reg rom1 (
    .clk(clk),
    .reset(!reset_n),
    .ce(ram_cs[1]),
    .oce(~rd_n),
    .wre(1'b0),
    .ad(address_bus[12:0]),
    .data_bus(data_bus)
);

ram8k_reg ram3 (
    .clk(clk),
    .reset(!reset_n),
    .ce(ram_cs[3]),
    .oce(~rd_n),
    .wre(~wr_n),
    .ad(address_bus[12:0]),
    .data_bus(data_bus)
);

ram8k_reg ram4 (
    .clk(clk),
    .reset(!reset_n),
    .ce(ram_cs[4]),
    .oce(~rd_n),
    .wre(~wr_n),
    .ad(address_bus[12:0]),
    .data_bus(data_bus)
);

ram8k_reg_0 ram5 (
    .clk(clk),
    .reset(!reset_n),
    .ce(ram_cs[5]),
    .oce(~rd_n),
    .wre(1'b0),
    .ad(address_bus[12:0]),
    .data_bus(data_bus)
);
/*
ram8k_reg_1 ram6 (
    .clk(clk),
    .reset(!reset_n),
    .ce(ram_cs[6]),
    .oce(~rd_n),
    .wre(1'b0),
    .ad(address_bus[12:0]),
    .data_bus(data_bus)
);
*/

keyboard_io keyboard (
    .clk(clk),
    .reset_n(reset_n),
    .ce(io_cs[1]),
    .rd(~rd_n),
    .wr(~wr_n),
    .ad(address_bus),
    .data_bus(data_bus),
    .aud_in(aud_in),
    .rxd(rxd)
);


wire clk_spectrum;
Gowin_OSC osc(
    .oscout(clk_spectrum)   // ~7 MHz
);




endmodule