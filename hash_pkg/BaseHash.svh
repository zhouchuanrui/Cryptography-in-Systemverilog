//
//File: BaseHash.svh
//Device: 
//Created:  2018-4-18 22:21:24
//Description: bash hash
//Revisions: 
//2018-4-18 22:21:33: created
//

`ifndef __BASE_HASH_SVH__
`define __BASE_HASH_SVH__
virtual class BaseHash#(BLOCK_SISE = 512, DIGEST_SIZE = 128, DIGEST_LEN = 128) extends LogBase;
    typedef bit[BLOCK_SISE-1:0] tBlock;
    typedef bit[BLOCK_SISE/16-1:0] tWord;
    typedef bit[DIGEST_SIZE-1:0] tDigest;
    typedef bit[DIGEST_LEN-1:0] tDigestTr;
    typedef enum{
        HASH_NONE,
        HASH_MD5,
        HASH_SHA1,
        HASH_SHA2S,
        HASH_SHA224,
        HASH_SHA256,
        HASH_SHA5S,
        HASH_SHA512,
        HASH_SHA384,
        HASH_SHA512_224,
        HASH_SHA512_256
    } eHashT;
    static protected eHashT this_type;

    static function string getName ();
        return this_type.name();
    endfunction: getName

    static protected function tWord RTOR (
        tWord din,
        int n
    );
        assert(n < BLOCK_SISE/16)
        else
            $fatal(1, "Error rotate rounds..");
        return (din>>n)|(din<<(BLOCK_SISE/16-n));
    endfunction

    static protected function tWord RTOL (
        tWord din,
        int n
    );
        assert(n < BLOCK_SISE/16)
        else
            $fatal(1, "Error rotate rounds..");
        return (din<<n)|(din>>(BLOCK_SISE/16-n));
    endfunction

    static protected function bit[31:0] endianSwitch32 (
        bit[31:0] din
    );
        return {din[7:0], din[15:8], din[23:16], din[31:24]};
    endfunction: endianSwitch32

    static protected function tWord fCh (
        tWord x, y, z
    );
        return (x&y)^((~x)&z);
    endfunction: fCh

    static protected function tWord fParity (
        tWord x, y, z
    );
        return x&y&z;
    endfunction

    static protected function tWord fMaj (
        tWord x, y, z
    );
        return (x&y)^(x&z)^(y&z);
    endfunction

    pure virtual function void initState ();
    pure virtual function void update (bit msg[$]);
    pure virtual function tDigestTr getDigest ();

    virtual function tDigestTr procWhole (
        bit msg[$]
    );
        initState();
        update(msg);
        return getDigest();
    endfunction: procWhole

endclass: BaseHash 
`endif

