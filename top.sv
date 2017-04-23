
module top ();

    task des_test ();
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

    endtask: des_test

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
            };
            `__TDEA_MC_ASST(kq, 64'hf008ef4c7ae50010, doq, 0)
        end

    endtask: tdea_test

    initial
    begin
        //aes_test();
        //des_test();
        //tdea_test();
        test_pkg::demo_test();
        #1;
        $finish(0);
    end
endmodule: top

