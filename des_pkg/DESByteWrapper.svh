//
//File: DESByteWrapper.svh
//Device: 
//Created:  2017-4-17 23:33:09
//Description: a byte interface wrapper
//Revisions: 
//2017-4-17 23:33:37: created
//

`ifndef __DES_BYTE_WRAPPER_SVH
`define __DES_BYTE_WRAPPER_SVH
class DESByteWrapper #(type T = CoreDES) extends DESTypes;
    local T obj;
    function new();
        obj = new();
    endfunction

    /*
    function void setKey (bit [7:0] key_q[]);
        if(T::this_type == DES) begin
            assert(key_q.size() == 8)
            else begin
                $fatal(1, "[%s]Wrong key size!!", T::this_type.name());
            end
            obj.setKey({>>{key_q}});
        end
        else if (T::this_type == TDEA) begin
            assert(key_q.size() inside {16, 24})
            else begin
                $fatal(1, "[%s]Wrong key size!!", T::this_type.name());
            end
            if (key_q.size() == 16) begin
                obj.setKey({>>{key_q[0:7]}}, {>>{key_q[8:15]}}, {>>{key_q[0:7]}});
            end else begin
                obj.setKey({>>{key_q[0:7]}}, {>>{key_q[8:15]}}, {>>{key_q[16:23]}});
            end
        end
    endfunction: setKey
    * */

    function void encrypt (bit[7:0] din[], ref bit[7:0] dout[]);
        bit[1:64] tmp;
        assert(din.size() == 8)
        else $fatal(1, "Get non-192-bit block..");
        tmp = {>>{din}};
        tmp = obj.encrypt(tmp);
        dout = {>>byte{tmp}};
    endfunction

    function void decrypt (bit[7:0] din[], ref bit[7:0] dout[]);
        bit[1:64] tmp;
        assert(din.size() == 8)
        else $fatal(1, "Get non-192-bit block..");
        tmp = {>>{din}};
        tmp = obj.decrypt(tmp);
        dout = {>>byte{tmp}};
    endfunction

endclass: DESByteWrapper 
`endif

