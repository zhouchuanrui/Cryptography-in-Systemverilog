//
//File: LogBase.svh
//Device: 
//Created:  2017-3-29 23:01:18
//Description: logging base
//Revisions: 
//2017-3-29 23:01:29: created
//

`ifndef __LOG_BASE_SVH__
`define __LOG_BASE_SVH__

virtual class LogBase;
    static protected bit is_muted;

    static function bit isMuted ();
        return is_muted;
    endfunction: isMuted

    static function void setMuted ();        
        is_muted = 1;
    endfunction: setMuted

    static function void setLogging ();
        is_muted = 0;
    endfunction: setLogging

endclass

`endif 

