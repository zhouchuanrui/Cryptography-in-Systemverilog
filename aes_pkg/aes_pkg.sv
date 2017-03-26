
package aes_pkg;

`define LOG(s, off) \
    `ifndef NO_LOG \
    if (!off) $write(s); \
    `endif

    `include "CoreAES.sv"

endpackage


