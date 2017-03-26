virtual class LogBase;
    static protected bit is_muted;

    static function void setMuted ();        
        is_muted = 1;
    endfunction: setMuted

    static function void setLogging ();
        is_muted = 0;
    endfunction: setLogging

    `define _LOG(s) `LOG(s, is_muted)

endclass

virtual class RijndaelPreliminaries extends LogBase;
    typedef bit [31:0] tWORD;

    static protected function bit[7:0] xtime(
        bit [7:0] x
    );
        xtime = {x[6:0], 1'b0};
        if (x[7] == 1)
            xtime ^= 8'h1b;
    endfunction

    static protected function bit[7:0] GF8Mult (
        bit[7:0] x, y
    );
        if (y == 0)
            return 0;
        else
            return (y[0]?x:0)^GF8Mult(xtime(x), {1'b0, y[7:1]});
    endfunction

    const static protected bit[7:0] sbox[256] = {
        8'h63, 8'h7c, 8'h77, 8'h7b, 8'hf2, 8'h6b, 8'h6f, 8'hc5, 8'h30, 8'h01, 8'h67, 8'h2b, 8'hfe, 8'hd7, 8'hab, 8'h76, 
        8'hca, 8'h82, 8'hc9, 8'h7d, 8'hfa, 8'h59, 8'h47, 8'hf0, 8'had, 8'hd4, 8'ha2, 8'haf, 8'h9c, 8'ha4, 8'h72, 8'hc0, 
        8'hb7, 8'hfd, 8'h93, 8'h26, 8'h36, 8'h3f, 8'hf7, 8'hcc, 8'h34, 8'ha5, 8'he5, 8'hf1, 8'h71, 8'hd8, 8'h31, 8'h15, 
        8'h04, 8'hc7, 8'h23, 8'hc3, 8'h18, 8'h96, 8'h05, 8'h9a, 8'h07, 8'h12, 8'h80, 8'he2, 8'heb, 8'h27, 8'hb2, 8'h75, 
        8'h09, 8'h83, 8'h2c, 8'h1a, 8'h1b, 8'h6e, 8'h5a, 8'ha0, 8'h52, 8'h3b, 8'hd6, 8'hb3, 8'h29, 8'he3, 8'h2f, 8'h84, 
        8'h53, 8'hd1, 8'h00, 8'hed, 8'h20, 8'hfc, 8'hb1, 8'h5b, 8'h6a, 8'hcb, 8'hbe, 8'h39, 8'h4a, 8'h4c, 8'h58, 8'hcf, 
        8'hd0, 8'hef, 8'haa, 8'hfb, 8'h43, 8'h4d, 8'h33, 8'h85, 8'h45, 8'hf9, 8'h02, 8'h7f, 8'h50, 8'h3c, 8'h9f, 8'ha8, 
        8'h51, 8'ha3, 8'h40, 8'h8f, 8'h92, 8'h9d, 8'h38, 8'hf5, 8'hbc, 8'hb6, 8'hda, 8'h21, 8'h10, 8'hff, 8'hf3, 8'hd2, 
        8'hcd, 8'h0c, 8'h13, 8'hec, 8'h5f, 8'h97, 8'h44, 8'h17, 8'hc4, 8'ha7, 8'h7e, 8'h3d, 8'h64, 8'h5d, 8'h19, 8'h73, 
        8'h60, 8'h81, 8'h4f, 8'hdc, 8'h22, 8'h2a, 8'h90, 8'h88, 8'h46, 8'hee, 8'hb8, 8'h14, 8'hde, 8'h5e, 8'h0b, 8'hdb, 
        8'he0, 8'h32, 8'h3a, 8'h0a, 8'h49, 8'h06, 8'h24, 8'h5c, 8'hc2, 8'hd3, 8'hac, 8'h62, 8'h91, 8'h95, 8'he4, 8'h79, 
        8'he7, 8'hc8, 8'h37, 8'h6d, 8'h8d, 8'hd5, 8'h4e, 8'ha9, 8'h6c, 8'h56, 8'hf4, 8'hea, 8'h65, 8'h7a, 8'hae, 8'h08, 
        8'hba, 8'h78, 8'h25, 8'h2e, 8'h1c, 8'ha6, 8'hb4, 8'hc6, 8'he8, 8'hdd, 8'h74, 8'h1f, 8'h4b, 8'hbd, 8'h8b, 8'h8a, 
        8'h70, 8'h3e, 8'hb5, 8'h66, 8'h48, 8'h03, 8'hf6, 8'h0e, 8'h61, 8'h35, 8'h57, 8'hb9, 8'h86, 8'hc1, 8'h1d, 8'h9e, 
        8'he1, 8'hf8, 8'h98, 8'h11, 8'h69, 8'hd9, 8'h8e, 8'h94, 8'h9b, 8'h1e, 8'h87, 8'he9, 8'hce, 8'h55, 8'h28, 8'hdf, 
        8'h8c, 8'ha1, 8'h89, 8'h0d, 8'hbf, 8'he6, 8'h42, 8'h68, 8'h41, 8'h99, 8'h2d, 8'h0f, 8'hb0, 8'h54, 8'hbb, 8'h16
    };

    const static protected bit[7:0] invSbox[256] = {
        8'h52, 8'h09, 8'h6a, 8'hd5, 8'h30, 8'h36, 8'ha5, 8'h38, 8'hbf, 8'h40, 8'ha3, 8'h9e, 8'h81, 8'hf3, 8'hd7, 8'hfb,
        8'h7c, 8'he3, 8'h39, 8'h82, 8'h9b, 8'h2f, 8'hff, 8'h87, 8'h34, 8'h8e, 8'h43, 8'h44, 8'hc4, 8'hde, 8'he9, 8'hcb,
        8'h54, 8'h7b, 8'h94, 8'h32, 8'ha6, 8'hc2, 8'h23, 8'h3d, 8'hee, 8'h4c, 8'h95, 8'h0b, 8'h42, 8'hfa, 8'hc3, 8'h4e,
        8'h08, 8'h2e, 8'ha1, 8'h66, 8'h28, 8'hd9, 8'h24, 8'hb2, 8'h76, 8'h5b, 8'ha2, 8'h49, 8'h6d, 8'h8b, 8'hd1, 8'h25,
        8'h72, 8'hf8, 8'hf6, 8'h64, 8'h86, 8'h68, 8'h98, 8'h16, 8'hd4, 8'ha4, 8'h5c, 8'hcc, 8'h5d, 8'h65, 8'hb6, 8'h92,
        8'h6c, 8'h70, 8'h48, 8'h50, 8'hfd, 8'hed, 8'hb9, 8'hda, 8'h5e, 8'h15, 8'h46, 8'h57, 8'ha7, 8'h8d, 8'h9d, 8'h84,
        8'h90, 8'hd8, 8'hab, 8'h00, 8'h8c, 8'hbc, 8'hd3, 8'h0a, 8'hf7, 8'he4, 8'h58, 8'h05, 8'hb8, 8'hb3, 8'h45, 8'h06,
        8'hd0, 8'h2c, 8'h1e, 8'h8f, 8'hca, 8'h3f, 8'h0f, 8'h02, 8'hc1, 8'haf, 8'hbd, 8'h03, 8'h01, 8'h13, 8'h8a, 8'h6b,
        8'h3a, 8'h91, 8'h11, 8'h41, 8'h4f, 8'h67, 8'hdc, 8'hea, 8'h97, 8'hf2, 8'hcf, 8'hce, 8'hf0, 8'hb4, 8'he6, 8'h73,
        8'h96, 8'hac, 8'h74, 8'h22, 8'he7, 8'had, 8'h35, 8'h85, 8'he2, 8'hf9, 8'h37, 8'he8, 8'h1c, 8'h75, 8'hdf, 8'h6e,
        8'h47, 8'hf1, 8'h1a, 8'h71, 8'h1d, 8'h29, 8'hc5, 8'h89, 8'h6f, 8'hb7, 8'h62, 8'h0e, 8'haa, 8'h18, 8'hbe, 8'h1b,
        8'hfc, 8'h56, 8'h3e, 8'h4b, 8'hc6, 8'hd2, 8'h79, 8'h20, 8'h9a, 8'hdb, 8'hc0, 8'hfe, 8'h78, 8'hcd, 8'h5a, 8'hf4,
        8'h1f, 8'hdd, 8'ha8, 8'h33, 8'h88, 8'h07, 8'hc7, 8'h31, 8'hb1, 8'h12, 8'h10, 8'h59, 8'h27, 8'h80, 8'hec, 8'h5f,
        8'h60, 8'h51, 8'h7f, 8'ha9, 8'h19, 8'hb5, 8'h4a, 8'h0d, 8'h2d, 8'he5, 8'h7a, 8'h9f, 8'h93, 8'hc9, 8'h9c, 8'hef,
        8'ha0, 8'he0, 8'h3b, 8'h4d, 8'hae, 8'h2a, 8'hf5, 8'hb0, 8'hc8, 8'heb, 8'hbb, 8'h3c, 8'h83, 8'h53, 8'h99, 8'h61,
        8'h17, 8'h2b, 8'h04, 8'h7e, 8'hba, 8'h77, 8'hd6, 8'h26, 8'he1, 8'h69, 8'h14, 8'h63, 8'h55, 8'h21, 8'h0c, 8'h7d
    };

    static protected function tWORD subWord (tWORD win);
        return {
            sbox[win[7 -: 8]],
            sbox[win[15 -: 8]],
            sbox[win[23 -: 8]],
            sbox[win[31 -: 8]]
        };
    endfunction: subWord

    static protected function tWORD rotWord (tWORD win);
        return (win >> 24)|(win << 8);
    endfunction: rotWord

    static protected function tWORD rcon (int unsigned i);
        bit[7:0] tmp;
        tmp = 1;
        repeat(i-1) begin
            tmp = xtime(tmp);
        end
        return {tmp, 24'd0};
    endfunction

    static protected function void subBytes (ref bit[7:0] st[]);
        foreach(st[i]) 
            st[i] = sbox[st[i]];
    endfunction

    static protected function void invSubBytes (ref bit[7:0] st[]);
        foreach(st[i]) 
            st[i] = invSbox[st[i]];
    endfunction

    static protected function void shiftRows (ref bit[7:0] st[]);
        /* from     to
        st = {          st = {
            0 4 8 c         0 4 8 c
            1 5 9 d         5 9 d 1
            2 6 a e         a e 2 6
            3 7 b f         f 3 7 b
        };              };     */
        st = {
            st['h0], st['h5], st['ha], st['hf],
            st['h4], st['h9], st['he], st['h3],
            st['h8], st['hd], st['h2], st['h7],
            st['hc], st['h1], st['h6], st['hb]
        };
    endfunction

    static protected function void invShiftRows (ref bit[7:0] st[]);
        /* from         to    
        st = {                  st = {
            0 4 8 c                 0 4 8 c 
            1 5 9 d                 d 1 5 9 
            2 6 a e                 a e 2 6 
            3 7 b f                 7 b f 3 
        };                      }; */
        st = {
            st['h0], st['hd], st['ha], st['h7],
            st['h4], st['h1], st['he], st['hb],
            st['h8], st['h5], st['h2], st['hf],
            st['hc], st['h9], st['h6], st['h3]
        };
    endfunction

    static protected function void mixColumns (ref bit[7:0] st[]);
        for (int c = 0; c < 4; c++) begin
            {st[c*4+0], st[c*4+1], st[c*4+2], st[c*4+3]} = 
                {
                    GF8Mult(2, st[c*4+0])^GF8Mult(3, st[c*4+1])^st[c*4+2]^st[c*4+3],
                    st[c*4+0]^GF8Mult(2, st[c*4+1])^GF8Mult(3, st[c*4+2])^st[c*4+3],
                    st[c*4+0]^st[c*4+1]^GF8Mult(2, st[c*4+2])^GF8Mult(3, st[c*4+3]),
                    GF8Mult(3, st[c*4+0])^st[c*4+1]^st[c*4+2]^GF8Mult(2, st[c*4+3])
                };
        end
    endfunction

    static protected function void invMixColumns (ref bit[7:0] st[]);
    `define __mix(a, b, c, d) \
        GF8Mult(a, st[c*4+0])^GF8Mult(b, st[c*4+1])^GF8Mult(c, st[c*4+2])^GF8Mult(d, st[c*4+3])
        for (int c = 0; c < 4; c++) begin
            {st[c*4+0], st[c*4+1], st[c*4+2], st[c*4+3]} = 
                {
                    `__mix(8'h0e, 8'h0b, 8'h0d, 8'h09),
                    `__mix(8'h09, 8'h0e, 8'h0b, 8'h0d),
                    `__mix(8'h0d, 8'h09, 8'h0e, 8'h0b),
                    `__mix(8'h0b, 8'h0d, 8'h09, 8'h0e)
                };
        end
    endfunction

endclass: RijndaelPreliminaries

//typedef class RijndaelPreliminaries;
class CoreAES#(KEY_SIZE = 128) extends RijndaelPreliminaries;
    typedef bit [KEY_SIZE-1:0] tKEY;
    const static protected byte 
        Nb = 4, 
        Nk = KEY_SIZE/64,
        Nr = Nk+6;

    protected bit[7:0] key_r[];
    protected tWORD w[];
    protected bit is_key_expanded;

    function new(bit[7:0] kin[] = {});
        if (kin.size() inside {0, KEY_SIZE/8}) begin
            this.key_r = kin;
            if (this.key_r.size()!=0)
                w = new[Nb*(Nr+1)];
        end else begin
            $fatal(1, "Wrong key size");
        end
        is_key_expanded = 0;
        is_muted = 0;
    endfunction

    function void setKey (bit[7:0] kin[]);
        if (kin.size() != KEY_SIZE/8) begin
            $fatal(1, "Wrong key size");
        end
        if(kin != this.key_r) begin
            this.key_r = kin;
            w = new[Nb*(Nr+1)];
            is_key_expanded = 0;
        end
    endfunction: setKey

    `define _LOG_S(s, array, w=128) \
    if (!is_muted) begin \
        bit[w-1:0] tmp; \
        tmp = {>>byte{array}}; \
        $write(s, tmp); \
    end

    protected function void keyExpansion ();
        tWORD temp;
        if(key_r.size() == 0) begin
            $fatal(1, "No key set...");
        end
        `_LOG_S("Key = %0h\n", key_r, KEY_SIZE)
        for (int i=0; i<Nk; i++) begin
            w[i] = {key_r[4*i+3], key_r[4*i+2], key_r[4*i+1], key_r[4*i]};
            //w[i] = {key_r[4*i], key_r[4*i+1], key_r[4*i+2], key_r[4*i+3]};
            `_LOG($sformatf("w[%0d] = %08h\t", i, w[i]))
        end
        `_LOG("\n")
        for (int i=Nk; i<Nb*(Nr+1); i++) begin
            temp = w[i-1];
            `_LOG($sformatf("round %02d: temp = %08h ", i, temp))
            if (i%Nk == 0) begin
                temp = subWord(rotWord(temp))^rcon(i/Nk);
                `_LOG($sformatf(", %08h after xor with rcon", temp))
            end else if ((Nk > 6)&&(i % Nk == 4)) begin
                temp = subWord(temp);
                `_LOG($sformatf(", %08h after subWord", temp))
            end
            w[i] = w[i-Nk]^temp;
            `_LOG($sformatf("w[i] = %08h\n", w[i]))
        end
        is_key_expanded = 1;
    endfunction: keyExpansion

    protected function void addRoundKey (int r, ref bit[7:0] st[]);
        for(int c = 0; c < 4; c++)
            {st[c*4+0], st[c*4+1], st[c*4+2], st[c*4+3]} ^= w[r*4+c];
    endfunction

    //function tBLOCK encrypt (const ref tBLOCK din);
    function void encrypt (const ref bit[7:0] din[], ref bit[7:0] dout[]);
        //tBLOCK state;
        bit[7:0] state[];
        //state = {>>{din}};
        assert(din.size == 16)
        else
            $fatal(1, "Get non-128-bit block..");
        state = din;
        if(is_key_expanded == 0) keyExpansion();
        //`_LOG($sformatf("Input = %0h", {>>{din}}))
        //`_LOG($sformatf("Key   = %0h", {>>{this.key_r}}))
        `_LOG_S("Input = %0h\n", din)
        `_LOG_S("Key   = %0h\n", this.key_r, KEY_SIZE)
        addRoundKey(0, state);
        for(int i = 1; i < Nr; i++) begin
            `_LOG($sformatf("Round %02d:", i)) `_LOG_S("%032h", state)
            subBytes(state);
            `_LOG_S("--> subBytes --> %032h", state)
            shiftRows(state);
            `_LOG_S("--> shiftRows --> %032h", state)
            mixColumns(state);
            `_LOG_S("--> mixColumns --> %032h", state)
            addRoundKey(i, state);
            `_LOG_S("--> addRoundKey --> %032h \n", state)
        end
        `_LOG($sformatf("Round %02d:", Nr))
        `_LOG_S(" %32h", state)
        subBytes(state);
        //`_LOG($sformatf("--> subBytes --> %032h", {>>{state}}))
        `_LOG_S("--> subBytes --> %32h", state)
        shiftRows(state);
        //`_LOG($sformatf("--> shiftRows --> %032h", {>>{state}}))
        `_LOG_S("--> shiftRows --> %32h", state)
        addRoundKey(Nr, state);
        //`_LOG($sformatf("--> addRoundKey --> %032h \n", {>>{state}}))
        `_LOG_S("--> addRoundKey --> %32h\n", state)
        dout = state;
        `_LOG_S("Output = %0h \n", dout)
    endfunction: encrypt

    function void decrypt (const ref bit[7:0] din[], ref bit[7:0] dout[]);
        bit[7:0] state[];
        assert(din.size == 16)
        else
            $fatal(1, "Get non-128-bit block..");
        state = din;
        if(is_key_expanded == 0) keyExpansion();
        `_LOG_S("Ciphertxt = %0h \n", din)
        `_LOG_S("Key       = %0h \n", this.key_r)
        addRoundKey(Nr, state);
        for(int i=Nr-1; i>1; i--) begin
            `_LOG($sformatf("round[%2d].iinput", i)) `_LOG_S("%032h\n", state)
            invShiftRows(state);
            `_LOG($sformatf("round[%2d].is_row", i)) `_LOG_S("%032h\n", state)
            invSubBytes(state);
            `_LOG($sformatf("round[%2d].is_box", i)) `_LOG_S("%032h\n", state)
            addRoundKey(i, state);
            `_LOG($sformatf("round[%2d].ik_sch", i)) `_LOG_S("%032h\n", state)
            invMixColumns(state);
            //`_LOG($sformatf("round[%2d].ik_sch", i)) `_LOG_S("%032h", state)
        end
        `_LOG($sformatf("round[%2d].iinput", 1)) `_LOG_S("%032h\n", state)
        invShiftRows(state);
        `_LOG($sformatf("round[%2d].is_row", 1)) `_LOG_S("%032h\n", state)
        invSubBytes(state);
        `_LOG($sformatf("round[%2d].is_box", 1)) `_LOG_S("%032h\n", state)
        addRoundKey(0, state);
        dout = state;
        `_LOG($sformatf("round[%2d].output", 1)) `_LOG_S("%032h\n", state)
    endfunction
endclass


