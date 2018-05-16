//
//File: hmac_test.svh
//Device: 
//Created:  2018-5-16 18:27:58
//Description: HMAC vectors
//Revisions: 
//2018-5-16 18:28:08: created
//

`ifndef __HMAC_TEST_SVH
`define __HMAC_TEST_SVH
class hmac_test_template#(type T=hash_pkg::HMAC_MD5) extends hash_string_wrapper#(T);
    task test ();
        byte tmp, key[$];
        const int unsigned klen_q[4] = {
            T::HASH_TYPE::BLOCK_SISE/8,
            T::HASH_TYPE::DIGEST_LEN/8,
            100*T::HASH_TYPE::BLOCK_SISE/512,
            49
        };
        const string msg_q[4] = {
            "Sample message for keylen=blocklen",
            "Sample message for keylen<blocklen",
            "Sample message for keylen=blocklen",
            "Sample message for keylen<blocklen, with truncated tag"
        };
        foreach(klen_q[i]) begin
            key = '{};
            tmp = 0;
            repeat(klen_q[i]) begin
                key.push_back(tmp);
                tmp++;
            end
            obj.setKey(key);
            this.procWhole(msg_q[i]);
        end
    endtask
endclass

`define _add_hmac_test(TN, TP) \
class TN extends hmac_test_template#(TP); \
    `__register(TN) \
endclass

`_add_hmac_test(hmac_sha1_test,       hash_pkg::HMAC_SHA1)
`_add_hmac_test(hmac_sha224_test,     hash_pkg::HMAC_SHA224)
`_add_hmac_test(hmac_sha256_test,     hash_pkg::HMAC_SHA256)
`_add_hmac_test(hmac_sha384_test,     hash_pkg::HMAC_SHA384)
`_add_hmac_test(hmac_sha512_test,     hash_pkg::HMAC_SHA512)
`_add_hmac_test(hmac_sha512_224_test, hash_pkg::HMAC_SHA512_224)
`_add_hmac_test(hmac_sha512_256_test, hash_pkg::HMAC_SHA512_256)

`undef _add_hmac_test

`endif

