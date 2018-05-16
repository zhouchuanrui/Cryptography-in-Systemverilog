//
//File: CoreHMAC.svh
//Device: 
//Created:  2018-5-12 20:47:53
//Description: HMAC
//Revisions: 
//2018-5-12 20:47:59: created
//

`ifndef __CORE_HMAC_SVH
`define __CORE_HMAC_SVH

class CoreHMAC#(type HASH_TYPE = CoreMD5);
    typedef bit [HASH_TYPE::BLOCK_SISE-1:0] tBlock;
    typedef bit [HASH_TYPE::DIGEST_LEN-1:0] tDigestTr;
    protected HASH_TYPE hash_obj;
    protected tBlock k0, k0_xor_ipad, k0_xor_opad;
    protected byte key[$];
    protected bit k0_updated, k0_xor_ipad_hashed;
    protected bit is_muted;
    static const protected tBlock
        ipad = {(HASH_TYPE::BLOCK_SISE/8){8'h36}},
        opad = {(HASH_TYPE::BLOCK_SISE/8){8'h5c}};

    function new();
        hash_obj = new();
        k0_updated = 0;
        k0_xor_ipad_hashed = 0;
        is_muted = 0;
    endfunction

    function bit isKeyEmpty ();
        return (key.size()==0);
    endfunction

    function string getName ();
        return hash_obj.getName();
    endfunction

    function void setKey (byte key[$]);
        if(this.key != key) begin
            this.key = key;
            k0_updated = 0;
        end
        else begin
            `_LOG($sformatf("[HMAC:%s]Warning: Get identical key, use latched key\n", this.getName()))
        end
    endfunction

    protected function tBlock packBytes (
        byte bq[$], int blen = HASH_TYPE::BLOCK_SISE/8
    );
        assert((blen <= bq.size())&&(blen <= HASH_TYPE::BLOCK_SISE/8))
        else 
            $fatal(1, "Given blen: %0d out of range", bq.size());
        packBytes = 0;
        repeat(blen) begin
            packBytes >>= 8;
            packBytes[blen*8-1 -: 8] = bq.pop_back();
        end
    endfunction

    protected function void unpackBytes (
        tBlock blk, int blen = HASH_TYPE::BLOCK_SISE/8, ref byte bq[$]
    );
        assert (blen <= HASH_TYPE::BLOCK_SISE/8)
        else
            $fatal(1, "Given blen: %0d out of range", bq.size());
        repeat(blen) begin
            bq.push_back(blk[blen*8-1 -: 8]);
            blk <<= 8;
        end
    endfunction

    protected function void genK0 ();
        `_LOG($sformatf("[HMAC@%s]Key size: %0d\n", HASH_TYPE::getName(), key.size()))
        if(key.size() == HASH_TYPE::BLOCK_SISE/8) begin
            k0 = packBytes(key, HASH_TYPE::BLOCK_SISE/8);
        end
        else if(key.size() > HASH_TYPE::BLOCK_SISE/8) begin
            k0 = hash_obj.procWhole(key);
            k0 <<= {HASH_TYPE::BLOCK_SISE - HASH_TYPE::DIGEST_LEN};
        end
        else begin
            k0 = packBytes(key, key.size());
        end
        k0_xor_ipad = k0^ipad;
        k0_xor_opad = k0^opad;
        k0_updated = 1;
    endfunction

    function void update (
        byte msg[$]
    );
        byte tmp[$];
        tmp = '{};
        if(!k0_updated) begin
            genK0();
        end
        if(k0_xor_ipad_hashed == 0) begin
            unpackBytes(k0_xor_ipad, .bq(tmp));
            k0_xor_ipad_hashed = 1;
        end
        tmp = {tmp, msg};
        hash_obj.update(tmp);
    endfunction

    function tDigestTr getDigest ();
        byte tmp[$];
        tDigestTr tmp_dig;
        tmp_dig = hash_obj.getDigest();
        tmp = '{};
        unpackBytes(k0_xor_opad, .bq(tmp));
        unpackBytes(tmp_dig, HASH_TYPE::DIGEST_LEN/8, tmp);
        `_LOG($sformatf("[HMAC@%s]K0: %0h\n",
            HASH_TYPE::getName(), k0))
        `_LOG($sformatf("[HMAC@%s]K0^ipad: %0h\n",
            HASH_TYPE::getName(), k0_xor_ipad))
        `_LOG($sformatf("[HMAC@%s]Hash(K0^ipad||text): %0h\n",
            HASH_TYPE::getName(), tmp_dig))
        `_LOG($sformatf("[HMAC@%s]K0^opad: %0h\n",
            HASH_TYPE::getName(), k0_xor_opad))
        `_LOG($sformatf("[HMAC@%s]len of K0^opad||Hash(K0^ipad||text): %0d\n",
            HASH_TYPE::getName(), tmp.size()))
        k0_xor_ipad_hashed = 0;
        return hash_obj.procWhole(tmp);
    endfunction

    function tDigestTr procWhole (
        byte msg[$]
    );
        HASH_TYPE this_hash_obj;
        tDigestTr tmp_dig;
        byte tmp[$];
        this_hash_obj = new();
        if(!k0_updated) genK0;
        unpackBytes(k0_xor_ipad, .bq(tmp));
        tmp = {tmp, msg};
        tmp_dig = this_hash_obj.procWhole(tmp);
        tmp = '{};
        unpackBytes(k0_xor_ipad, .bq(tmp));
        unpackBytes(tmp_dig, HASH_TYPE::DIGEST_LEN/8, tmp);
        `_LOG($sformatf("[HMAC@%s]K0: %0h\n",
            HASH_TYPE::getName(), k0))
        `_LOG($sformatf("[HMAC@%s]K0^ipad: %0h\n",
            HASH_TYPE::getName(), k0_xor_ipad))
        `_LOG($sformatf("[HMAC@%s]Hash(K0^ipad||text): %0h\n",
            HASH_TYPE::getName(), tmp_dig))
        `_LOG($sformatf("[HMAC@%s]K0^opad: %0h\n",
            HASH_TYPE::getName(), k0_xor_opad))
        `_LOG($sformatf("[HMAC@%s]len of K0^opad||Hash(K0^ipad||text): %0d\n",
            HASH_TYPE::getName(), tmp.size()))
        return this_hash_obj.procWhole(tmp);
    endfunction
endclass

`endif
