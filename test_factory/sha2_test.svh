//
//File: sha2_test.svh
//Device: 
//Created:  2018-5-6 23:00:50
//Description: SHA-2 vectors
//Revisions: 
//2018-5-6 23:00:59: created
//

`ifndef __SHA2_TEST_SVH
`define __SHA2_TEST_SVH
class sha2_test_template#(type T=hash_pkg::CoreSHA2S5) extends hash_string_wrapper#(T);
    task test ();
        obj.setLogging();
        void'(obj.getDigest());
        this.procWhole("a");
        this.procWhole("abc");
        this.update("a");
        this.update("bc");
        void'(obj.getDigest());
        begin
            string vec = "abcd", msg="";
            do begin
                msg = {msg, vec};
                foreach(vec[i]) vec[i] = byte'(vec[i])+1;
            end while(vec[0] <= "n");
            this.procWhole(msg);
        end
        begin
            string vec = "abcdefgh", msg="";
            do begin
                msg = {msg, vec};
                foreach(vec[i]) vec[i] = byte'(vec[i])+1;
            end while(vec[0] <= "n");
            this.procWhole(msg);
        end
    endtask
endclass

`define _add_sha2_test(TN, TP) \
class TN extends sha2_test_template#(TP); \
    `__register(TN) \
endclass

`_add_sha2_test(sha224_test, hash_pkg::CoreSHA224)
`_add_sha2_test(sha256_test, hash_pkg::CoreSHA256)
`_add_sha2_test(sha384_test, hash_pkg::CoreSHA384)
`_add_sha2_test(sha512_test, hash_pkg::CoreSHA512)
`_add_sha2_test(sha512_224_test, hash_pkg::CoreSHA512_224)
`_add_sha2_test(sha512_256_test, hash_pkg::CoreSHA512_256)

`undef _add_sha2_test

`endif

