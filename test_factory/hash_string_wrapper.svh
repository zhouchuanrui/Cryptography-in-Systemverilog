//
//File: hash_string_wrapper.svh
//Device: 
//Created:  2018-5-6 22:17:50
//Description: string wrapper
//Revisions: 
//2018-5-6 22:17:59: created
//

`ifndef __HASH_STRING_WRAPPER_SVH
`define __HASH_STRING_WRAPPER_SVH

class hash_string_wrapper#(type T=hash_pkg::CoreMD5) extends TestPrototype;
    T obj;

    function new();
        obj = new();
    endfunction

    virtual function void update (
        string msg
    );
        byte byte_msg[$];
        foreach(msg[i])
            byte_msg.push_back(msg[i]);
        obj.update(byte_msg);
    endfunction

    virtual function void procWhole (
        string msg
    );
        byte byte_msg[$];
        foreach(msg[i])
            byte_msg.push_back(msg[i]);
        void'(obj.procWhole(byte_msg));
    endfunction

    virtual task test ();
    endtask
endclass

`endif

