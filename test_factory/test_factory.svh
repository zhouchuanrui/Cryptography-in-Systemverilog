//
//File: test_factory.svh
//Device: 
//Created:  2017-4-18 23:06:21
//Description: test factory
//Revisions: 
//2017-4-18 23:06:32: created
//

`ifndef __TEST_FACTORY_SVH__
`define __TEST_FACTORY_SVH__

virtual class TestBase;
    pure virtual task test ();
endclass: TestBase

class test_factory extends LogBase;
    static local TestBase tests[string];

    static function void register (TestBase obj, string test_name);
        assert(obj != null) 
        else begin
            $display("Can't register null object in factory!!");
            return;
        end
        if (tests.exists(test_name)) begin
            $display("Override obj registered with '%s'!!", test_name);
        end
        tests[test_name] = obj;
    endfunction: register

    static task run_test (string test_name);
        if (!tests.exists(test_name)) begin
            $display("Can't find %s in factory!!", test_name);
            return;
        end
        tests[test_name].test();
    endfunction: run_test

endclass

`define __register(T) \
static local T reg_obj = get(); \
static local function T get(); \
    if (reg_obj == null) begin \
        reg_obj = new();  \
        test_factory::register(reg_obj, `"T`"); \
    end \
    return reg_obj; \
endfunction

class aes_test;
    `__register(aes_test)

    function new();
    endfunction
endclass: aes_test

`endif

