//
//File: CoreMD5.svh
//Device: 
//Created:  2018-4-19 23:18:36
//Description: MD5
//Revisions: 
//2018-4-19 23:18:43: created
//

`ifndef __CORE_MD5_SVH__
`define __CORE_MD5_SVH__
class CoreMD5 extends BaseHash#(512, 128, 128);
    protected tBlock block_reg;
    protected tDigest digest;
    typedef struct packed{
        tWord a, b, c, d;
    } sState;
    protected sState state;
    protected struct packed {
        tWord mw, lw;
    } bit_cnt;
    protected bit msg_reg[$];

    function new();
        this_type = HASH_MD5;
        initState();
    endfunction

    virtual function void initState ();
        bit_cnt = 0;
        block_reg = 0;
        msg_reg = '{};
        state.a = 'h67452301;
        state.b = 'hefcdab89;
        state.c = 'h98badcfe;
        state.d = 'h10325476;
    endfunction

endclass: CoreMD5 extends BaseHash#(512, 128, 128)
`endif

