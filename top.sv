
module top ();
    initial
    begin
        bit[7:0] dout[], din[];
        aes_pkg::AES128 aes_128;
        aes_128 = new();
        din = '{8'h32, 8'h43, 8'hf6, 8'ha8, 8'h88, 8'h5a, 8'h30, 8'h8d, 8'h31, 8'h31, 8'h98, 8'ha2, 8'he0, 8'h37, 8'h07, 8'h34};
        aes_128.setKey( {8'h2b, 8'h7e, 8'h15, 8'h16, 8'h28, 8'hae, 8'hd2, 8'ha6, 8'hab, 8'hf7, 8'h15, 8'h88, 8'h09, 8'hcf, 8'h4f, 8'h3c});
        aes_128.encrypt(
        din, 
        dout);
        #1;
        //$finish(0);
    end
endmodule: top

