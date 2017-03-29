
`ifndef __LOG_BASE_SVH__
`define __LOG_BASE_SVH__

virtual class LogBase;
    static protected bit is_muted;

    static function void setMuted ();        
        is_muted = 1;
    endfunction: setMuted

    static function void setLogging ();
        is_muted = 0;
    endfunction: setLogging

    `define _LOG(s) `LOG(s, is_muted)

endclass

`endif 

