
module top ();

    initial
    begin
        //aes_test();
        //des_test();
        //tdea_test();
        //test_pkg::demo_test();
        `ifdef __BASE_PKG
            $display("Get Base Package..");
        `endif

        test_pkg::factory_run_test();
        #1;
        $finish(0);
    end
endmodule: top

