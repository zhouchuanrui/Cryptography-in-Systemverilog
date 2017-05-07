//
//File: tdea_test.svh
//Device: 
//Created:  2017-5-7 20:34:48
//Description: tdea test
//Revisions: 
//2017-5-7 20:34:54: created
//

`ifndef __TDEA_TEST_SVH
`define __TDEA_TEST_SVH

task tdea_test ();
    des_pkg::CoreTDEA tdea_h;
    tdea_h = new();
    tdea_h.setLogging();
    tdea_h.setKey(
        64'h151f10383d6d199b,
        64'h4a763bd54a46a445,
        64'h151f10383d6d199b
    );
    void'(tdea_h.decrypt(64'h89321ba75ba545db));
    void'(tdea_h.encrypt(64'hd8da89298878ed7d));

    tdea_h.setKey(
        64'h9ec2372c86379df4,
        64'had7ac4464f73805d,
        64'h20c4f87564527c91
    );
    void'(tdea_h.encrypt(64'hb624d6bd41783ab1));
    void'(tdea_h.decrypt(64'he2e7a74cb9e75418));

    tdea_h.setMuted();

    `define __TDEA_MC_ENC(key_q, ptxt) \
    begin \
        bit[1:64] tmp; \
        des_pkg::CoreTDEA tdea_h; \
        tdea_h = new(); \
        tdea_h.setKey(key_q[0], key_q[1], key_q[2]); \
        $display("KEY1 = %016h", key_q[0]); \
        $display("KEY2 = %016h", key_q[1]); \
        $display("KEY3 = %016h", key_q[2]); \
        $display("PTXT = %016h", ptxt); \
        tmp = ptxt; \
        repeat(5) begin \
            tmp = tdea_h.encrypt(tmp); \
            $display("CTXT = %016h", tmp); \
        end \
        $display(""); \
    end

    begin
        bit[1:64] kq[$];
        kq = '{
            64'h13a7a1267c022c62,
            64'h2f92daf4e34ce36b,
            64'h1a4a10ec9789da58 };
        `__TDEA_MC_ENC(kq, 64'h8d64960bfb34b096)
        kq = '{
            64'hfb79c223c1c73438,
            64'h49ea087ca41a6e10,
            64'h3b4cb394a79e4f07 };
        `__TDEA_MC_ENC(kq, 64'he9de6205bdc4185a)
    end

    `define __TDEA_MC_ASST(key_q, din, dout_q, is_enc = 1) \
    begin \
        bit[1:64] tmp; \
        des_pkg::CoreTDEA tdea_h; \
        tdea_h = new(); \
        tdea_h.setKey(key_q[0], key_q[1], key_q[2]); \
        $display("KEY1    = %016h", key_q[0]); \
        $display("KEY2    = %016h", key_q[1]); \
        $display("KEY3    = %016h", key_q[2]); \
        $display("TXT_IN  = %016h", din); \
        tmp = din; \
        for(int i = 0; i < dout_q.size(); i++) begin \
            if (is_enc == 1) begin \
                tmp = tdea_h.encrypt(tmp); \
            end else begin \
                tmp = tdea_h.decrypt(tmp); end \
            assert(tmp == dout_q[i]) begin \
                $display("TXT_OUT = %016h..PASS", tmp);  end \
            else begin \
                $display("TXT_OUT != %016h.. got %016h", dout_q[i], tmp);  end end  \
        $display(""); end

    begin
        bit[1:64] kq[$], doq[$];
        kq = '{
            64'h927c73ae40b02929,
            64'h4aa4d998e543df3d,
            64'hc8f119dc61d3434a };
        doq = '{
            64'hdf746177393519a3,
            64'h546b1c386d6f2fd6,
            64'h11f299de4f305157,
            64'haaf4ec37b489b8a1,
            64'hcad1837658669b2e
        };
        `__TDEA_MC_ASST(kq, 64'h6804b08c81761c11, doq, 1)
        kq = '{
            64'he00d5d014f13087f,
            64'hf4d3f12a101a83cd,
            64'hb5c1972cecbf54ea };
        doq = '{
            64'h743dcb9445225338,
            64'h6993a5203294b0c5,
            64'hfd0f4dffa113313d,
            64'h822771148992d1f7,
            64'h4434aec39930b58d
        };
        `__TDEA_MC_ASST(kq, 64'h72702eaf0ea32157, doq, 1)
        kq = '{
            64'h38ce5b459efb2a83,
            64'hcecd1aa80e54e331,
            64'h8557d5702520c42f };
        doq = '{
            64'hbe2b98921e78d22a,
            64'hdfc503b4399f7bdd,
            64'h9f2de08dc41c1cb7,
            64'h7687b6a7746577f6,
            64'hb0e82d84d7977ff6
        };
        `__TDEA_MC_ASST(kq, 64'hd9c30744d1e822fc, doq, 1)
        kq = '{
            64'h79b63486e0ce37e0,
            64'h08e65231abae3710,
            64'h1f5eb69e925ef185 };
        doq = '{
            64'h11bfe0c4d2e25091,
            64'h8db7837efa4f9f97,
            64'h6df46ec102534cdb,
            64'hc04cb8490ebbcd18,
            64'h93ab811da5d914a5
        };
        `__TDEA_MC_ASST(kq, 64'h2783aa729432fe96, doq, 0)
        kq = '{
            64'h0b582f98d0c8e0d6,
            64'h45fba86b46ae9725,
            64'h436876e93426bfba };
        doq = '{
            64'h6406054284ca699c,
            64'h65a4bbf3a0bd2c8d,
            64'hbab37728a0adeed7,
            64'h06d567e1d8bace61,
            64'hbf6e085f61eed47a
        };
        `__TDEA_MC_ASST(kq, 64'h73ef1a1f3007d637, doq, 0)
        kq = '{
            64'hfb51c1d5ab2ce0c7,
            64'h648549cd8ad6dc58,
            64'h52dac7dc2f4085e3 };
        doq = '{
            64'h64332cb1e67e9776,
            64'h6111d0c11d75d2e0,
            64'had530f35d7ee6f4a,
            64'h28b717b6b12d6265,
            64'h5d07db301ffc5a21
        };https://zhouchuanrui.github.io/2017/03/28/note_asic/run_test_demo/
        `__TDEA_MC_ASST(kq, 64'hf008ef4c7ae50010, doq, 0)
    end

endtask: tdea_test

`endif

