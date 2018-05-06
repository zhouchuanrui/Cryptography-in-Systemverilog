//
//File: sha1_test.svh
//Device: 
//Created:  2018-4-23 22:39:03
//Description: SHA-1 vectors
//Revisions: 
//2018-4-23 22:39:21: created
//

`ifndef __SHA1_TEST_SVH
`define __SHA1_TEST_SVH
class sha1_test extends hash_string_wrapper#(hash_pkg::CoreSHA1);
    `__register(sha1_test)
    task test ();
        obj.setLogging();
        void'(obj.getDigest());
        this.procWhole("a");
        this.procWhole("abc");
        this.update("a");
        this.update("bc");
        void'(obj.getDigest());
    endtask: test
endclass: sha1_test 
`endif

