//
//File: CoreSHA2S2.svh
//Device: 
//Created:  2018-4-25 20:14:21
//Description: SHA-2 256bit
//Revisions: 
//2018-4-25 20:14:40: created
//

`ifndef __CORE_SHA2_2S_SVH
`define __CORE_SHA2_2S_SVH
pure class CoreSHA2S2#(DL=256) extends BaseHash#(512, 256, DL);
    protected tBlock block_reg;
    protected struct packed{
        tWord h[0:7];
    } state;
    protected struct packed {
        tWord mw, lw;
    } bit_cnt;
    protected byte msg_reg[$];
    static const protected tWord K[0:63] = {
        32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
        32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
        32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
        32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
        32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
        32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
        32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
        32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2
    };

    static protected function tWord ucSigma0 (tWord x);
        return ROTR(x, 2)^ROTR(x, 13)^ROTR(x, 22);
    endfunction

    static protected function tWord ucSigma1 (tWord x);
        return ROTR(x, 6)^ROTR(x, 11)^ROTR(x, 25);
    endfunction

    static protected function tWord lcSigma0 (tWord x);
        return ROTR(x, 7)^ROTR(x, 18)^(x >> 3);
    endfunction

    static protected function tWord lcSigma1 (tWord x);
        return ROTR(x, 17)^ROTR(x, 19)^(x >> 10);
    endfunction

    virtual function sState trans (
        sState stin, tBlock blkin
    );
        tWord a, b, c, d, e, f, g, h, T1, T2, W[0:63];
        {a, b, c, d, e, f, g, h} = stin;
        for(byte i=0; i<16; i++) begin
            W[15-i] = blkin[31:0];
            blkin >>= 32;
            `_LOG($sformatf("W[%02d] = %08h\n", 15-i, W[15-i]))
        end
        for(byte i=16; i<64; i++) begin
            W[i] = lcSigma1(W[i-2]) + W[i-7] +
                   lcSigma0(W[i-15]) + W[i-16];
        end
        for(byte t=0; t<64; t++) begin
            T1 = h + ucSigma1(e) + fCh(e, f, g) + K[t] + W[t];
            T2 = ucSigma0(a) + fMaj(a, b, c);
            {h, g, f, e, d, c, b, a} = 
                {g, f, e, d+T1, c, b, a, T1+T2};
            `_LOG($sformatf("[t=%02d]abcdefgh: %08h %08h %08h %08h %08h %08h %08h %08h\n",
                t, a, b, c, d, e, f, g, h))
        end
        stin.h[0] += a;
        stin.h[1] += b;
        stin.h[2] += c;
        stin.h[3] += d;
        stin.h[4] += e;
        stin.h[5] += f;
        stin.h[6] += g;
        stin.h[7] += h;
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

class CoreSHA256 extends CoreSHA2s#(256);
    function new();
        this_type = HASH_SHA256;
        initState();
    endfunction

    protected virtual function void initState ();
        msg_reg = 0;
        bit_cnt = 0;
        block_reg = 0;
        state.h[0] = 32'h6a09e667;
        state.h[1] = 32'hbb67ae85;
        state.h[2] = 32'h3c6ef372;
        state.h[3] = 32'ha54ff53a;
        state.h[4] = 32'h510e527f;
        state.h[5] = 32'h9b05688c;
        state.h[6] = 32'h1f83d9ab;
        state.h[7] = 32'h5be0cd19;
    endfunction: inits
endclass: CoreSHA256 

class CoreSHA224 extends CoreSHA2s#(224);
    function new();
        this_type = HASH_SHA224;
        initState();
    endfunction

    protected virtual function void initState ();
        msg_reg = 0;
        bit_cnt = 0;
        block_reg = 0;
        state.h[0] = 32'hc1059ed8;
        state.h[1] = 32'h367cd507;
        state.h[2] = 32'h3070dd17;
        state.h[3] = 32'hf70e5939;
        state.h[4] = 32'hffc00b31;
        state.h[5] = 32'h68581511;
        state.h[6] = 32'h64f98fa7;
        state.h[7] = 32'hbefa4fa4;
    endfunction: inits
endclass: CoreSHA224 

`endif

