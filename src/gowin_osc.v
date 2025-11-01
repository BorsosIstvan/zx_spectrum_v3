module Gowin_OSC (oscout);

output oscout;

OSC osc_inst (
    .OSCOUT(oscout)
);

defparam osc_inst.FREQ_DIV = 64;   //  16
defparam osc_inst.DEVICE = "GW1NR-9C";

endmodule //Gowin_OSC