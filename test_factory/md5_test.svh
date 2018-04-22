//
//File: md5_test.svh
//Device: 
//Created:  2018-4-22 14:53:44
//Description: MD5 vectors
//Revisions: 
//2018-4-22 14:53:52: created
//

`ifndef __MD5_TEST_SVH
`define __MD5_TEST_SVH

class md5_test extends TestPrototype;
    `__register(md5_test)
    function new();
    endfunction

    task test ();
        hash_pkg::CoreMD5 md5;
        md5 = new();
        md5.setLogging();
        void'(md5.getDigest());
        void'(md5.procWhole({"a"}));
    endtask: test
endclass: md5_test 

`endif

