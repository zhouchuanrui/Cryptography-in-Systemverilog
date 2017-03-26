
package aes_pkg;

`define LOG(s, off) \
    `ifndef NO_LOG \
    if (!off) $write(s); \
    `endif

    `include "CoreAES.svh"
    typedef CoreAES#(128) AES128;
    typedef CoreAES#(192) AES192;
    typedef CoreAES#(256) AES256;

endpackage


