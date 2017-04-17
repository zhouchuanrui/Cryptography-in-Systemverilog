//
//File: CoreTDEA.svh
//Device: 
//Created:  2017-4-16 18:16:56
//Description: TDEA core
//Revisions: 
//2017-4-16 18:17:05: created
//

`ifndef __CORE_TEDA_SVH__
`define __CORE_TEDA_SVH__

class CoreTDEA extends DESTypes;
    protected _tL64 key1, key2, key3;
    protected bit key_dispatched;
    protected CoreDES des1, des2, des3;
    local static const eDESType this_type = TDEA;
    function new();
        key_dispatched = 0;
    endfunction

    function void setKey(_tL64 key1, key2, key3);
        this.key1 = key1;
        this.key2 = key2;
        this.key3 = key3;
        key_dispatched = 0;
    endfunction

    protected function void keyDispatch ();
        if (!key_dispatched) begin
            if (des1 == null) des1 = new();
            if (des2 == null) des2 = new();
            des1.setKey(this.key1);
            des2.setKey(this.key2);
            if (this.key1 == this.key3) begin
                des3 = des1;
                `_LOG("!!Use 2-Key mode\n")
            end else begin
                if (des3 == null) des3 = new();
                des3.setKey(this.key3);
            end
            key_dispatched = 1;
        end
    endfunction: keyDispatch

    function uBlockT encrypt (uBlockT bdata);
        keyDispatch();
        return des3.encrypt(des2.decrypt(des1.encrypt(bdata)));
    endfunction 

    function uBlockT decrypt (uBlockT bdata);
        keyDispatch();
        return des1.decrypt(des2.encrypt(des3.decrypt(bdata)));
    endfunction 

endclass: CoreTDEA 

`endif

