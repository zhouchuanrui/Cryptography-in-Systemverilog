
package aes_pkg;

`define LOG(s) \
    if (!muted) $display(s);

    `include "CoreAES.sv"

endpackage


