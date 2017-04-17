//
//File: CoreDES.svh
//Device: 
//Created:  2017-4-9 16:04:39
//Description: DES core
//Revisions: 
//2017-4-9 16:04:58: created
//

`ifndef __CORE_DES_SVH__
`define __CORE_DES_SVH__

class CoreDES extends DESPreliminaries;
    protected bit sub_key_updated;
    protected _tL64 key_r;
    protected _tL48 sub_key[1:16];
    local static const eDESType this_type = DES;

    function new(_tL64 key = 0);
        this.key_r = key;
        sub_key_updated = 0;
        //is_muted = 1;
    endfunction

    function void setKey(_tL64 key);
        if (this.key_r == key) begin
            `_LOG("Use latched key..\n")
        end else begin
            sub_key_updated = 0;
            this.key_r = key;
        end
    endfunction

    protected function void subKeyUpdate ();
        if (sub_key_updated == 1) return;
        else begin
            uCD ucd;
            //_tL28 c, d;
            ucd = ksPC_1(this.key_r);
            for (int i = 1; i <= 16; i++) begin
                ucd.sub.c = `rotl(ucd.sub.c, shiftTable[i]);
                ucd.sub.d = `rotl(ucd.sub.d, shiftTable[i]);
                //ucd.sub.c = c;
                //ucd.sub.d = d;
                sub_key[i] = ksPC_2(ucd);
            end
        end
        sub_key_updated = 1;
    endfunction: subKeyUpdate

    function uBlockT encrypt (uBlockT bdata);
        subKeyUpdate();
        `_LOG($sformatf("KEY = %016h\n", this.key_r))
        `_LOG($sformatf("PLAINTEXT = %016h\n", bdata))
        encrypt = mTransInitPermutation(bdata);
        `_LOG($sformatf("..after IP %016h\n", encrypt))
        for(int i = 1; i <= 16; i++) begin
            `_LOG($sformatf("..Round %0d\n", i))
            encrypt = {encrypt.sub.r, 
                encrypt.sub.l^fTrans(encrypt.sub.r, sub_key[i])};
        end
        encrypt = {encrypt.sub.r, encrypt.sub.l};
        encrypt = mTransInitPermutationInv(encrypt);
        `_LOG($sformatf("CIPHERTEXT = %016h\n\n", encrypt))
    endfunction

    function uBlockT decrypt (uBlockT bdata);
        subKeyUpdate();
        `_LOG($sformatf("KEY = %016h\n", this.key_r))
        `_LOG($sformatf("CIPHERTEXT = %016h\n", bdata))
        decrypt = mTransInitPermutation(bdata);
        `_LOG($sformatf("..after IP %016h\n", decrypt))
        decrypt = {decrypt.sub.r, decrypt.sub.l};
        for(int i = 16; i >= 1; i--) begin
            `_LOG($sformatf("..Round %0d\n", i))
            decrypt = {
                decrypt.sub.r^fTrans(decrypt.sub.l, sub_key[i]),
                decrypt.sub.l};
        end
        decrypt = mTransInitPermutationInv(decrypt);
        `_LOG($sformatf("PLAINTEXT = %016h\n\n", decrypt))
    endfunction: decrypt
endclass: CoreDES 

`endif

