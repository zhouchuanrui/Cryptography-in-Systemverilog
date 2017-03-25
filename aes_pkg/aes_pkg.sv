
package aes_pkg;

`define LOG(s, off) \
    `ifndef NO_LOG \
    if (!off) $display(s); \
    `endif

    `include "CoreAES.sv"

endpackage


