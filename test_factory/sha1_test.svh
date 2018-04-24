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
class sha1_test extends TestPrototype;
    `__register(sha1_test)
    task test ();
        hash_pkg::CoreSHA1 sha1;
        sha1 = new();
        sha1.setLogging();
        void'(sha1.getDigest());
    endtask: test
endclass: sha1_test 
`endif

