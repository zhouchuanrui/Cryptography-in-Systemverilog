//
//File: demo_test.svh
//Device: 
//Created:  2017-5-7 20:32:54
//Description: TestFactory test
//Revisions: 
//2017-5-7 20:33:08: created
//


`define __add_test(TN) \
class TN extends TestPrototype; \
    `__register(TN) \
    function new(); \
        $display("New in %s", `"TN`"); \
    endfunction \
    task test (); \
        $display("Test in %s", `"TN`"); \
    endtask \
endclass

`__add_test(foo)
`__add_test(bar)
`__add_test(baz)

task demo_test ();
    foo fh;
    TestFactory::register(fh, "fh");
    fh = new();
    TestFactory::register(fh, "fh");

    TestFactory::run_test("foo");
    TestFactory::run_test("bar");
    TestFactory::run_test("luis");
    TestFactory::run_test("baz");
    TestFactory::run_test("fh");
endtask: demo_test

