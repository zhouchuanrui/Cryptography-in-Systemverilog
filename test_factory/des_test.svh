//
//File: des_test.svh
//Device: 
//Created:  2017-5-7 20:39:10
//Description: des tests
//Revisions: 
//2017-5-7 20:39:17: created
//

`ifndef __DES_TEST_SVH
`define __DES_TEST_SVH

task des_test_vec ();
    bit[63:0] tmp;
    des_pkg::CoreDES des_h;
    des_h = new();
    des_h.setLogging();
    des_h.setKey(0);
    tmp = des_h.encrypt(0);
    tmp = des_h.decrypt(tmp);

    des_h.setKey(64'h5987423651456987);
    tmp = des_h.encrypt(64'h5469875321456045);
    tmp = des_h.decrypt(tmp);

    des_h.setKey(64'h7ca110454a1a6e57);
    tmp = des_h.encrypt(64'h01a1d6d039776742);
    tmp = des_h.decrypt(tmp);

    des_h.setMuted();

    `define __ENC_KAT(key, ptxt, ctxt) \
    des_h.setKey(key); \
    assert(ctxt == des_h.encrypt(ptxt)) begin \
        $display("ENC(%016h) with %016h = %016h.. PASS", ptxt, key, ctxt); \
    end else begin \
        $display("ENC(%016h) with %016h != %016h.. get %016h", ptxt, key, ctxt, des_h.encrypt(ptxt)); \
    end 

    `__ENC_KAT(64'h0131d9619dc1376e, 64'h5cd54ca83def57da, 64'h7a389d10354bd271)
    `__ENC_KAT(64'h07a1133e4a0b2686, 64'h0248d43806f67172, 64'h868ebb51cab4599a)
    `__ENC_KAT(64'h3849674c2602319e, 64'h51454b582ddf440a, 64'h7178876e01f19b2a)
    `__ENC_KAT(64'h04b915ba43feb5b6, 64'h42fd443059577fa2, 64'haf37fb421f8c4095)

    `define __DEC_KAT(key, ctxt, ptxt) \
    des_h.setKey(key); \
    assert(ptxt == des_h.decrypt(ctxt)) begin \
        $display("DEC(%016h) with %016h = %016h.. PASS", ctxt, key, ptxt); \
    end else begin \
        $display("DEC(%016h) with %016h != %016h.. get %016h", ctxt, key, ptxt, des_h.encrypt(ctxt)); \
    end 


    `__DEC_KAT(64'h49793ebc79b3258f, 64'h6fbf1cafcffd0556, 64'h437540c8698f3cfa)
    `__DEC_KAT(64'h4fb05e1515ab73a7, 64'h2f22e49bab7ca1ac, 64'h072d43a077075292)
    `__DEC_KAT(64'h49e95d6d4ca229bf, 64'h5a6b612cc26cce4a, 64'h02fe55778117f12a)
    `__DEC_KAT(64'h018310dc409b26d6, 64'h5f4c038ed12b2e41, 64'h1d9d5c5018f728c2)
    `__DEC_KAT(64'h1c587f1c13924fef, 64'h63fac0d034d9f793, 64'h305532286d6f295a)

    `define __ASST_ENC(key, ptxt, ctxt) \
    assert(ctxt == des_h.encrypt(ptxt)) begin \
        $display("ENC(%016h) with %016h = %016h.. PASS", ptxt, key, ctxt); \
    end else begin \
        $display("ENC(%016h) with %016h != %016h.. get %016h", ptxt, key, ctxt, des_h.encrypt(ptxt)); \
    end 

    `define __ENCQ_KAT(key, pctxt_q) \
    des_h.setKey(key); \
    for(int i = 0; i < pctxt_q.size(); i+=2) begin \
        `__ASST_ENC(key, pctxt_q[i], pctxt_q[i+1]) \
    end

    `define __ASST_DEC(key, ctxt, ptxt) \
    assert(ptxt == des_h.decrypt(ctxt)) begin \
        $display("DEC(%016h) with %016h = %016h.. PASS", ctxt, key, ptxt); \
    end else begin \
        $display("DEC(%016h) with %016h != %016h.. get %016h", ctxt, key, ptxt, des_h.encrypt(ctxt)); \
    end 

    `define __DECQ_KAT(key, pctxt_q) \
    des_h.setKey(key); \
    for(int i = 0; i < pctxt_q.size(); i+=2) begin \
        `__ASST_DEC(key, pctxt_q[i+1], pctxt_q[i]) \
    end

    begin
        bit[1:64] key, datq[$];
        key = 64'h0101010101010101;
        datq = '{
            64'h8000000000000000,
            64'h95f8a5e5dd31d900,
            64'h4000000000000000,
            64'hdd7f121ca5015619,
            64'h2000000000000000,
            64'h2e8653104f3834ea,
            64'h1000000000000000,
            64'h4bd388ff6cd81d4f,
            64'h0800000000000000,
            64'h20b9e767b2fb1456
        };
        `__ENCQ_KAT(key, datq)
        `__DECQ_KAT(key, datq)
    end

endtask: des_test_vec

class des_test extends TestPrototype;
    `__register(des_test)
    function new();
    endfunction

    task test ();
        des_test_vec();
    endtask: test

endclass: des_test

`endif

