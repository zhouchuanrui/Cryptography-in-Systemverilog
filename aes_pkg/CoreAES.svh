
`ifndef __CORE_AES_SVH__
`define __CORE_AES_SVH__

//typedef class RijndaelPreliminaries;
class CoreAES#(KEY_SIZE = 128) extends RijndaelPreliminaries;
    typedef bit [KEY_SIZE-1:0] tKEY;
    const static protected byte 
        Nb = 4, 
        Nk = KEY_SIZE/32,
        Nr = Nk+6;

    protected bit[7:0] key_r[];
    protected tWORD w[];
    protected bit is_key_expanded;

    //function new(const ref bit[7:0] kin[] = {});
    function new();
        is_key_expanded = 0;
        is_muted = 1;
    endfunction

    function void setKey (const ref bit[7:0] kin[]);
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
    `ifndef NO_LOG \
    if (!is_muted) begin \
        bit[w-1:0] tmp; \
        tmp = {>>byte{array}}; \
        $write(s, tmp); \
    end \
    `endif

    protected function void keyExpansion ();
        tWORD temp;
        if(key_r.size() == 0) begin
            $fatal(1, "No key set...");
        end
        `_LOG_S("Key = %0h\n", key_r, KEY_SIZE)
        for (int i=0; i<Nk; i++) begin
            //w[i] = {key_r[4*i+3], key_r[4*i+2], key_r[4*i+1], key_r[4*i]};
            w[i] = {key_r[4*i], key_r[4*i+1], key_r[4*i+2], key_r[4*i+3]};
            `_LOG($sformatf("w[%0d] = %08h    ", i, w[i]))
        end
        `_LOG("\n")
        for (int i=Nk; i<Nb*(Nr+1); i++) begin
            temp = w[i-1];
            `_LOG($sformatf("round %02d: temp = %08h ", i, temp))
            if (i%Nk == 0) begin
                temp = rotWord(temp);
                `_LOG($sformatf("--> %08h ", temp))
                temp = subWord(temp);
                `_LOG($sformatf("--> %08h ", temp))
                temp = temp^rcon(i/Nk);
                `_LOG($sformatf("^ %08h --> %08h ", rcon(i/Nk), temp))
            end else if ((Nk > 6)&&(i % Nk == 4)) begin
                temp = subWord(temp);
                `_LOG($sformatf(", %08h after subWord", temp))
            end
            w[i] = w[i-Nk]^temp;
            `_LOG($sformatf("w[i] = %08h\n", w[i]))
        end
        `_LOG("\n")
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
        `_LOG_S("Output = %0h \n\n", dout)
    endfunction: encrypt

    function void decrypt (const ref bit[7:0] din[], ref bit[7:0] dout[]);
        bit[7:0] state[];
        assert(din.size == 16)
        else
            $fatal(1, "Get non-128-bit block..");
        state = din;
        if(is_key_expanded == 0) keyExpansion();
        `_LOG_S("Ciphertxt = %0h \n", din)
        `_LOG_S("Key       = %0h \n", this.key_r, KEY_SIZE)
        addRoundKey(Nr, state);
        for(int i=Nr-1; i>0; i--) begin
            `_LOG($sformatf("round[%2d].iinput ", i)) `_LOG_S("%032h\n", state)
            invShiftRows(state);
            `_LOG($sformatf("round[%2d].is_row ", i)) `_LOG_S("%032h\n", state)
            invSubBytes(state);
            `_LOG($sformatf("round[%2d].is_box ", i)) `_LOG_S("%032h\n", state)
            addRoundKey(i, state);
            `_LOG($sformatf("round[%2d].ik_sch ", i)) `_LOG_S("%032h\n", state)
            invMixColumns(state);
            //`_LOG($sformatf("round[%2d].ik_sch", i)) `_LOG_S("%032h", state)
        end
        `_LOG($sformatf("round[%2d].iinput ", 1)) `_LOG_S("%032h\n", state)
        invShiftRows(state);
        `_LOG($sformatf("round[%2d].is_row ", 1)) `_LOG_S("%032h\n", state)
        invSubBytes(state);
        `_LOG($sformatf("round[%2d].is_box ", 1)) `_LOG_S("%032h\n", state)
        addRoundKey(0, state);
        dout = state;
        `_LOG($sformatf("round[%2d].output ", 1)) `_LOG_S("%032h\n\n", state)
    endfunction
endclass

`endif

