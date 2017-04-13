
module top ();

    task aes_test ();
        bit[7:0] dout[], din[], key[];
        aes_pkg::AES128 aes_128;
        aes_pkg::AES192 aes_192;
        aes_pkg::AES256 aes_256;
        aes_128 = new();
        aes_192 = new();
        aes_256 = new();
        aes_128.setLogging();
        aes_192.setLogging();
        aes_256.setLogging();

        //key = '{8'h2b, 8'h7e, 8'h15, 8'h16, 8'h28, 8'hae, 8'hd2, 8'ha6, 8'hab, 8'hf7, 8'h15, 8'h88, 8'h09, 8'hcf, 8'h4f, 8'h3c};
        //din = '{8'h32, 8'h43, 8'hf6, 8'ha8, 8'h88, 8'h5a, 8'h30, 8'h8d, 8'h31, 8'h31, 8'h98, 8'ha2, 8'he0, 8'h37, 8'h07, 8'h34};
        //aes_128.setKey(key);
        //aes_128.encrypt(din, dout);
        //key = '{ 8'h8e, 8'h73, 8'hb0, 8'hf7, 8'hda, 8'h0e, 8'h64, 8'h52, 8'hc8, 8'h10, 8'hf3, 8'h2b, 8'h80, 8'h90, 8'h79, 8'he5, 8'h62, 8'hf8, 8'hea, 8'hd2, 8'h52, 8'h2c, 8'h6b, 8'h7b };
        //din = '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        //aes_192.setKey(key);
        //aes_192.encrypt(din, dout);

        //key = '{ 8'h60, 8'h3d, 8'heb, 8'h10, 8'h15, 8'hca, 8'h71, 8'hbe, 8'h2b, 8'h73, 8'hae, 8'hf0, 8'h85, 8'h7d, 8'h77, 8'h81, 8'h1f, 8'h35, 8'h2c, 8'h07, 8'h3b, 8'h61, 8'h08, 8'hd7, 8'h2d, 8'h98, 8'h10, 8'ha3, 8'h09, 8'h14, 8'hdf, 8'hf4 };
        //aes_256.setKey(key);
        //aes_256.encrypt(din, dout);

        din = {>>byte{128'h00112233445566778899aabbccddeeff}};
        key = {>>byte{128'h000102030405060708090a0b0c0d0e0f}};
        aes_128.setKey(key);
        aes_128.encrypt(din, dout);
        din = {>>byte{128'h69c4e0d86a7b0430d8cdb78070b4c55a}};
        aes_128.decrypt(din, dout);

        din = {>>byte{128'h00112233445566778899aabbccddeeff}};
        key = {>>byte{192'h000102030405060708090a0b0c0d0e0f1011121314151617}};
        aes_192.setKey(key);
        aes_192.encrypt(din, dout);
        din = {>>byte{128'hdda97ca4864cdfe06eaf70a0ec0d7191}};
        aes_192.decrypt(din, dout);

        din = {>>byte{128'h00112233445566778899aabbccddeeff}};
        key = {>>byte{256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f}};
        aes_256.setKey(key);
        aes_256.encrypt(din, dout);
        din = {>>byte{128'h8ea2b7ca516745bfeafc49904b496089}};
        aes_256.decrypt(din, dout);

    endtask

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

    endtask: des_test

    initial
    begin
        //aes_test();
        des_test();
        #1;
        //$finish(0);
    end
endmodule: top

