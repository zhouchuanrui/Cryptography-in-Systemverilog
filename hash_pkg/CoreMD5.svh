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
    protected byte msg_reg[$];

    function new();
        this_type = HASH_MD5;
        initState();
    endfunction

    virtual function void initState ();
        //bit_cnt.mw = 0;
        //bit_cnt.lw = 0;
        this.bit_cnt = 0;
        this.block_reg = 0;
        this.msg_reg.delete();
        this.state.a = 32'h67452301;
        this.state.b = 32'hefcdab89;
        this.state.c = 32'h98badcfe;
        this.state.d = 32'h10325476;
        //$display("bit_cnt: %0d", bit_cnt);
        //$display("bit_cnt: %0h", state);
    endfunction

    static const protected byte unsigned
        S11 = 7, S12 = 12, S13 = 17, S14 = 22,
        S21 = 5, S22 = 9,  S23 = 14, S24 = 20,
        S31 = 4, S32 = 11, S33 = 16, S34 = 23,
        S41 = 6, S42 = 10, S43 = 15, S44 = 21;

    `define F(x, y, z) (((x) & (y)) | ((~x) & (z)))
    `define G(x, y, z) (((x) & (z)) | ((y) & (~z)))
    `define H(x, y, z) ((x) ^ (y) ^ (z))
    `define I(x, y, z) ((y) ^ ((x) | (~z)))

    `define _add_fun(fn) \
    static protected function void fn``fn ( \
        tWord b, c, d, Wk, Rn, Ti, \
        ref tWord a \
    ); \
        a += `fn(b, c, d) + Wk + Ti; \
        a = ROTL(a, Rn); \
        a += b; \
    endfunction

    `_add_fun(F)
    `_add_fun(G)
    `_add_fun(H)
    `_add_fun(I)

    `undef F
    `undef G
    `undef H
    `undef I
    `undef _add_fun

    static protected function sState transMD5 (
        sState stin, tBlock blkin
    );
        tWord aa, bb, cc, dd, X[0:15];
        sState st_tmp;

        st_tmp = stin;
        {aa, bb, cc, dd} = stin;
        for(byte i=0; i<16; i++) begin
            X[15-i] = endianSwitch32(blkin[31:0]);
            blkin >>= BLOCK_SISE/16;
        end

        FF (bb, cc, dd, X[ 0], S11, 32'hd76aa478, aa); /* 1 */
        FF (aa, bb, cc, X[ 1], S12, 32'he8c7b756, dd); /* 2 */
        FF (dd, aa, bb, X[ 2], S13, 32'h242070db, cc); /* 3 */
        FF (cc, dd, aa, X[ 3], S14, 32'hc1bdceee, bb); /* 4 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))
        FF (bb, cc, dd, X[ 4], S11, 32'hf57c0faf, aa); /* 5 */
        FF (aa, bb, cc, X[ 5], S12, 32'h4787c62a, dd); /* 6 */
        FF (dd, aa, bb, X[ 6], S13, 32'ha8304613, cc); /* 7 */
        FF (cc, dd, aa, X[ 7], S14, 32'hfd469501, bb); /* 8 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))
        FF (bb, cc, dd, X[ 8], S11, 32'h698098d8, aa); /* 9 */
        FF (aa, bb, cc, X[ 9], S12, 32'h8b44f7af, dd); /* 10 */
        FF (dd, aa, bb, X[10], S13, 32'hffff5bb1, cc); /* 11 */
        FF (cc, dd, aa, X[11], S14, 32'h895cd7be, bb); /* 12 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))
        FF (bb, cc, dd, X[12], S11, 32'h6b901122, aa); /* 13 */
        FF (aa, bb, cc, X[13], S12, 32'hfd987193, dd); /* 14 */
        FF (dd, aa, bb, X[14], S13, 32'ha679438e, cc); /* 15 */
        FF (cc, dd, aa, X[15], S14, 32'h49b40821, bb); /* 16 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))
        GG (bb, cc, dd, X[ 1], S21, 32'hf61e2562, aa); /* 17 */
        GG (aa, bb, cc, X[ 6], S22, 32'hc040b340, dd); /* 18 */
        GG (dd, aa, bb, X[11], S23, 32'h265e5a51, cc); /* 19 */
        GG (cc, dd, aa, X[ 0], S24, 32'he9b6c7aa, bb); /* 20 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))
        GG (bb, cc, dd, X[ 5], S21, 32'hd62f105d, aa); /* 21 */
        GG (aa, bb, cc, X[10], S22,  32'h2441453, dd); /* 22 */
        GG (dd, aa, bb, X[15], S23, 32'hd8a1e681, cc); /* 23 */
        GG (cc, dd, aa, X[ 4], S24, 32'he7d3fbc8, bb); /* 24 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))
        GG (bb, cc, dd, X[ 9], S21, 32'h21e1cde6, aa); /* 25 */
        GG (aa, bb, cc, X[14], S22, 32'hc33707d6, dd); /* 26 */
        GG (dd, aa, bb, X[ 3], S23, 32'hf4d50d87, cc); /* 27 */
        GG (cc, dd, aa, X[ 8], S24, 32'h455a14ed, bb); /* 28 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))
        GG (bb, cc, dd, X[13], S21, 32'ha9e3e905, aa); /* 29 */
        GG (aa, bb, cc, X[ 2], S22, 32'hfcefa3f8, dd); /* 30 */
        GG (dd, aa, bb, X[ 7], S23, 32'h676f02d9, cc); /* 31 */
        GG (cc, dd, aa, X[12], S24, 32'h8d2a4c8a, bb); /* 32 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))
        HH (bb, cc, dd, X[ 5], S31, 32'hfffa3942, aa); /* 33 */
        HH (aa, bb, cc, X[ 8], S32, 32'h8771f681, dd); /* 34 */
        HH (dd, aa, bb, X[11], S33, 32'h6d9d6122, cc); /* 35 */
        HH (cc, dd, aa, X[14], S34, 32'hfde5380c, bb); /* 36 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))
        HH (bb, cc, dd, X[ 1], S31, 32'ha4beea44, aa); /* 37 */
        HH (aa, bb, cc, X[ 4], S32, 32'h4bdecfa9, dd); /* 38 */
        HH (dd, aa, bb, X[ 7], S33, 32'hf6bb4b60, cc); /* 39 */
        HH (cc, dd, aa, X[10], S34, 32'hbebfbc70, bb); /* 40 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))
        HH (bb, cc, dd, X[13], S31, 32'h289b7ec6, aa); /* 41 */
        HH (aa, bb, cc, X[ 0], S32, 32'heaa127fa, dd); /* 42 */
        HH (dd, aa, bb, X[ 3], S33, 32'hd4ef3085, cc); /* 43 */
        HH (cc, dd, aa, X[ 6], S34,  32'h4881d05, bb); /* 44 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))
        HH (bb, cc, dd, X[ 9], S31, 32'hd9d4d039, aa); /* 45 */
        HH (aa, bb, cc, X[12], S32, 32'he6db99e5, dd); /* 46 */
        HH (dd, aa, bb, X[15], S33, 32'h1fa27cf8, cc); /* 47 */
        HH (cc, dd, aa, X[ 2], S34, 32'hc4ac5665, bb); /* 48 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))
        II (bb, cc, dd, X[ 0], S41, 32'hf4292244, aa); /* 49 */
        II (aa, bb, cc, X[ 7], S42, 32'h432aff97, dd); /* 50 */
        II (dd, aa, bb, X[14], S43, 32'hab9423a7, cc); /* 51 */
        II (cc, dd, aa, X[ 5], S44, 32'hfc93a039, bb); /* 52 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))
        II (bb, cc, dd, X[12], S41, 32'h655b59c3, aa); /* 53 */
        II (aa, bb, cc, X[ 3], S42, 32'h8f0ccc92, dd); /* 54 */
        II (dd, aa, bb, X[10], S43, 32'hffeff47d, cc); /* 55 */
        II (cc, dd, aa, X[ 1], S44, 32'h85845dd1, bb); /* 56 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))
        II (bb, cc, dd, X[ 8], S41, 32'h6fa87e4f, aa); /* 57 */
        II (aa, bb, cc, X[15], S42, 32'hfe2ce6e0, dd); /* 58 */
        II (dd, aa, bb, X[ 6], S43, 32'ha3014314, cc); /* 59 */
        II (cc, dd, aa, X[13], S44, 32'h4e0811a1, bb); /* 60 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))
        II (bb, cc, dd, X[ 4], S41, 32'hf7537e82, aa); /* 61 */
        II (aa, bb, cc, X[11], S42, 32'hbd3af235, dd); /* 62 */
        II (dd, aa, bb, X[ 2], S43, 32'h2ad7d2bb, cc); /* 63 */
        II (cc, dd, aa, X[ 9], S44, 32'heb86d391, bb); /* 64 */
        `_LOG($sformatf("a:%0h, b:%0h, c:%0h, d:%0h \n", aa, bb, cc, dd))

        st_tmp.a += aa;
        st_tmp.b += bb;
        st_tmp.c += cc;
        st_tmp.d += dd;
        return st_tmp;
    endfunction: transMD5

    virtual function void update (
        byte msg[$]
    );
        bit_cnt += msg.size()*8;
        msg_reg = {msg_reg, msg};
        while(msg_reg.size() >= BLOCK_SISE/8) begin
            repeat(BLOCK_SISE/8-1) begin
                block_reg[7:0] = msg_reg.pop_front();
                block_reg <<= 8;
            end
            block_reg[7:0] = msg_reg.pop_front();
            state = transMD5(state, block_reg);
            block_reg = 0;
        end
    endfunction: update

    virtual function tDigestTr getDigest ();
        int pad_len;
        tWord pad_word;
        sState st_tmp;
        byte pad_msg[$];
        `_LOG($sformatf("Total Message size: %0d bit \n", bit_cnt))
        msg_reg.push_back(8'h80);
        pad_len = (msg_reg.size()< BLOCK_SISE/8 - 8)?
            (BLOCK_SISE/8 - msg_reg.size() - 8):
            (BLOCK_SISE/8 - msg_reg.size() - 8 + BLOCK_SISE/8);
        repeat(pad_len) pad_msg.push_back(0);
        pad_word = bit_cnt.lw;
        repeat(4) begin
            pad_msg.push_back(pad_word[7:0]);
            pad_word >>= 8;
        end
        pad_word = bit_cnt.mw;
        repeat(4) begin
            pad_msg.push_back(pad_word[7:0]);
            pad_word >>= 8;
        end
        assert((msg_reg.size()+pad_msg.size())%(BLOCK_SISE/8) == 0)
        else
            $fatal(1, "Wrong msg padding..");
        update(pad_msg);
        st_tmp = {
            endianSwitch32(state.a),
            endianSwitch32(state.b),
            endianSwitch32(state.c),
            endianSwitch32(state.d)
        };
        initState();
        `_LOG($sformatf("[%s]Message digest: %0h \n", this_type.name(), st_tmp))
        return st_tmp;
    endfunction

endclass: CoreMD5 
`endif

