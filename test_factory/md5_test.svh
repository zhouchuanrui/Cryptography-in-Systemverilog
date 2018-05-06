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

class md5_test extends hash_string_wrapper#(hash_pkg::CoreMD5);
    `__register(md5_test)
    task test ();
        obj.setLogging();
        void'(obj.getDigest());
        this.procWhole("a");
        this.procWhole("abc");
        this.update("a");
        this.update("bc");
        void'(obj.getDigest());
        this.procWhole("message digest");
        this.procWhole("abcdefghijklmnopqrstuvwxyz");
        this.procWhole("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789");
        this.procWhole("12345678901234567890123456789012345678901234567890123456789012345678901234567890");
    endtask: test
endclass: md5_test 

`endif

