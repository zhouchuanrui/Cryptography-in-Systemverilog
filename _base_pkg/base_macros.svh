//
//File: base_macros.svh
//Device: 
//Created:  2017-4-9 21:37:05
//Description: base macros
//Revisions: 
//2017-4-9 21:37:12: created
//

`ifndef __BASE_MACROS
`define __BASE_MACROS

`define LOG(s, off) \
    `ifndef NO_LOG \
    if (!off) $write(s); \
    `endif

`define _LOG(s) `LOG(s, is_muted)

`define rotl(variable, shift_n) \
    variable = (variable << shift_n)|(variable >> ($bits(variable)-shift_n));

`define rotr(variable, shift_n) \
    variable = (variable >> shift_n)|(variable << ($bits(variable)-shift_n));


`endif

