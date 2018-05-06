//
//File: CoreSHA2S5.svh
//Device: 
//Created:  2018-5-5 11:53:09
//Description: SHA-2 512bit
//Revisions: 
//2018-5-5 11:53:22: created
//

`ifndef __CORE_SHA2_5S_SVH
`define __CORE_SHA2_5S_SVH

virtual class CoreSHA2S5#(DL=512) extends BaseHash#(1024, 512, DL);
    protected tBlock block_reg;
    typedef struct packed{
        tWord h0, h1, h2, h3, h4, h5, h6, h7;
    } sState;
    protected sState state;
    protected struct packed {
        tWord mw, lw;
    } bit_cnt;
    protected byte msg_reg[$];
    static const protected tWord K[0:79] = {
        64'h428a2f98d728ae22, 64'h7137449123ef65cd, 64'hb5c0fbcfec4d3b2f, 64'he9b5dba58189dbbc,
        64'h3956c25bf348b538, 64'h59f111f1b605d019, 64'h923f82a4af194f9b, 64'hab1c5ed5da6d8118,
        64'hd807aa98a3030242, 64'h12835b0145706fbe, 64'h243185be4ee4b28c, 64'h550c7dc3d5ffb4e2,
        64'h72be5d74f27b896f, 64'h80deb1fe3b1696b1, 64'h9bdc06a725c71235, 64'hc19bf174cf692694,
        64'he49b69c19ef14ad2, 64'hefbe4786384f25e3, 64'h0fc19dc68b8cd5b5, 64'h240ca1cc77ac9c65,
        64'h2de92c6f592b0275, 64'h4a7484aa6ea6e483, 64'h5cb0a9dcbd41fbd4, 64'h76f988da831153b5,
        64'h983e5152ee66dfab, 64'ha831c66d2db43210, 64'hb00327c898fb213f, 64'hbf597fc7beef0ee4,
        64'hc6e00bf33da88fc2, 64'hd5a79147930aa725, 64'h06ca6351e003826f, 64'h142929670a0e6e70,
        64'h27b70a8546d22ffc, 64'h2e1b21385c26c926, 64'h4d2c6dfc5ac42aed, 64'h53380d139d95b3df,
        64'h650a73548baf63de, 64'h766a0abb3c77b2a8, 64'h81c2c92e47edaee6, 64'h92722c851482353b,
        64'ha2bfe8a14cf10364, 64'ha81a664bbc423001, 64'hc24b8b70d0f89791, 64'hc76c51a30654be30,
        64'hd192e819d6ef5218, 64'hd69906245565a910, 64'hf40e35855771202a, 64'h106aa07032bbd1b8,
        64'h19a4c116b8d2d0c8, 64'h1e376c085141ab53, 64'h2748774cdf8eeb99, 64'h34b0bcb5e19b48a8,
        64'h391c0cb3c5c95a63, 64'h4ed8aa4ae3418acb, 64'h5b9cca4f7763e373, 64'h682e6ff3d6b2b8a3,
        64'h748f82ee5defb2fc, 64'h78a5636f43172f60, 64'h84c87814a1f0ab72, 64'h8cc702081a6439ec,
        64'h90befffa23631e28, 64'ha4506cebde82bde9, 64'hbef9a3f7b2c67915, 64'hc67178f2e372532b,
        64'hca273eceea26619c, 64'hd186b8c721c0c207, 64'heada7dd6cde0eb1e, 64'hf57d4f7fee6ed178,
        64'h06f067aa72176fba, 64'h0a637dc5a2c898a6, 64'h113f9804bef90dae, 64'h1b710b35131c471b,
        64'h28db77f523047d84, 64'h32caab7b40c72493, 64'h3c9ebe0a15c9bebc, 64'h431d67c49c100d4c,
        64'h4cc5d4becb3e42b6, 64'h597f299cfc657e2a, 64'h5fcb6fab3ad6faec, 64'h6c44198c4a475817
    };

    static protected function tWord ucSigma0 (tWord x);
        return ROTR(x, 28)^ROTR(x, 34)^ROTR(x, 39);
    endfunction

    static protected function tWord ucSigma1 (tWord x);
        return ROTR(x, 14)^ROTR(x, 18)^ROTR(x, 41);
    endfunction

    static protected function tWord lcSigma0 (tWord x);
        return ROTR(x, 1)^ROTR(x, 18)^(x >> 7);
    endfunction

    static protected function tWord lcSigma1 (tWord x);
        return ROTR(x, 19)^ROTR(x, 51)^(x >> 6);
    endfunction

    virtual function sState trans (
        sState stin, tBlock blkin
    );
        tWord a, b, c, d, e, f, g, h, T1, T2, W[0:79];
        {a, b, c, d, e, f, g, h} = stin;
        for(byte i=0; i<16; i++) begin
            W[15-i] = blkin[63:0];
            blkin >>= 64;
            `_LOG($sformatf("W[%02d] = %016h\n", 15-i, W[15-i]))
        end
        for(byte i=16; i<80; i++) begin
            W[i] = lcSigma1(W[i-2]) + W[i-7] +
                   lcSigma0(W[i-15]) + W[i-16];
        end
        for(byte t=0; t<80; t++) begin
            T1 = h + ucSigma1(e) + fCh(e, f, g) + K[t] + W[t];
            T2 = ucSigma0(a) + fMaj(a, b, c);
            {h, g, f, e, d, c, b, a} = 
                {g, f, e, d+T1, c, b, a, T1+T2};
            `_LOG($sformatf("[t=%02d]abcdefgh: %08h %08h %08h %08h %08h %08h %08h %08h\n",
                t, a, b, c, d, e, f, g, h))
        end
        stin.h0 += a;
        stin.h1 += b;
        stin.h2 += c;
        stin.h3 += d;
        stin.h4 += e;
        stin.h5 += f;
        stin.h6 += g;
        stin.h7 += h;
        return stin;
    endfunction: trans

    virtual function void update (byte msg[$]); 
        bit_cnt += msg.size()*8;
        msg_reg = {msg_reg, msg};
        while(msg_reg.size() >= BLOCK_SISE/8) begin
            repeat(BLOCK_SISE/8-1) begin
                block_reg[7:0] = msg_reg.pop_front();
                block_reg <<= 8;
            end
            block_reg[7:0] = msg_reg.pop_front();
            state = trans(state, block_reg);
            block_reg = 0;
        end
    endfunction

    virtual function tDigestTr getDigest (); 
        int pad_len;
        tWord pad_word;
        sState st_tmp;
        byte pad_msg[$];

        `_LOG($sformatf("Total Message size: %0d bit \n", bit_cnt))
        msg_reg.push_back(8'h80);
        pad_len = (msg_reg.size()< BLOCK_SISE/8 - BLOCK_SISE/64)?
            (BLOCK_SISE/8 - msg_reg.size() - BLOCK_SISE/64):
            (BLOCK_SISE/8 - msg_reg.size() - BLOCK_SISE/64 + BLOCK_SISE/8);
        repeat(pad_len) pad_msg.push_back(0);
        pad_word = bit_cnt.mw;
        repeat(BLOCK_SISE/128) begin
            pad_msg.push_back(pad_word[BLOCK_SISE/16-1:BLOCK_SISE/16-8]);
            pad_word <<= 8;
        end
        pad_word = bit_cnt.lw;
        repeat(BLOCK_SISE/128) begin
            pad_msg.push_back(pad_word[BLOCK_SISE/16-1:BLOCK_SISE/16-8]);
            pad_word <<= 8;
        end
        update(pad_msg);
        st_tmp = state;

        initState();
        `_LOG($sformatf("[%s]Message digest: %0h\n", this_type.name(), st_tmp))
        return tDigestTr'(st_tmp>>(DIGEST_SIZE-DIGEST_LEN));
    endfunction

endclass

class CoreSHA384 extends CoreSHA2S5#(384);
    function new();
        this_type = HASH_SHA384;
        initState();
    endfunction
    protected virtual function void initState ();
        msg_reg = '{};
        bit_cnt = 0;
        block_reg = 0;
        state.h0 = 64'hcbbb9d5dc1059ed8;
        state.h1 = 64'h629a292a367cd507;
        state.h2 = 64'h9159015a3070dd17;
        state.h3 = 64'h152fecd8f70e5939;
        state.h4 = 64'h67332667ffc00b31;
        state.h5 = 64'h8eb44a8768581511;
        state.h6 = 64'hdb0c2e0d64f98fa7;
        state.h7 = 64'h47b5481dbefa4fa4;
    endfunction
endclass

class CoreSHA512 extends CoreSHA2S5#(512);
    function new();
        this_type = HASH_SHA512;
        initState();
    endfunction
    protected virtual function void initState ();
        msg_reg = '{};
        bit_cnt = 0;
        block_reg = 0;
        state.h0 = 64'h6a09e667f3bcc908;
        state.h1 = 64'hbb67ae8584caa73b;
        state.h2 = 64'h3c6ef372fe94f82b;
        state.h3 = 64'ha54ff53a5f1d36f1;
        state.h4 = 64'h510e527fade682d1;
        state.h5 = 64'h9b05688c2b3e6c1f;
        state.h6 = 64'h1f83d9abfb41bd6b;
        state.h7 = 64'h5be0cd19137e2179;
    endfunction
endclass

class CoreSHA512_224 extends CoreSHA2S5#(224);
    function new();
        this_type = HASH_SHA512_224;
        initState();
    endfunction
    protected virtual function void initState ();
        msg_reg = '{};
        bit_cnt = 0;
        block_reg = 0;
        state.h0 = 64'h8c3d37c819544da2;
        state.h1 = 64'h73e1996689dcd4d6;
        state.h2 = 64'h1dfab7ae32ff9c82;
        state.h3 = 64'h679dd514582f9fcf;
        state.h4 = 64'h0f6d2b697bd44da8;
        state.h5 = 64'h77e36f7304c48942;
        state.h6 = 64'h3f9d85a86a1d36c8;
        state.h7 = 64'h1112e6ad91d692a1;
    endfunction
endclass

class CoreSHA512_256 extends CoreSHA2S5#(256);
    function new();
        this_type = HASH_SHA512_256;
        initState();
    endfunction
    protected virtual function void initState ();
        msg_reg = '{};
        bit_cnt = 0;
        block_reg = 0;
        state.h0 = 64'h22312194fc2bf72c;
        state.h1 = 64'h9f555fa3c84c64c2;
        state.h2 = 64'h2393b86b6f53b151;
        state.h3 = 64'h963877195940eabd;
        state.h4 = 64'h96283ee2a88effe3;
        state.h5 = 64'hbe5e1e2553863992;
        state.h6 = 64'h2b0199fc2c85b8aa;
        state.h7 = 64'h0eb72ddc81c52ca2;
    endfunction
endclass

`endif


