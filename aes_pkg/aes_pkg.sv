//
//File: aes_pkg.sv
//Device: 
//Created:  2017-3-29 23:00:25
//Description: package 
//Revisions: 
//2017-3-29 23:00:32: created
//

package aes_pkg;

    `include "base_macros.svh"
    import base_pkg::LogBase;
    `include "RijndaelPreliminaries.svh"
    `include "CoreAES.svh"
    typedef CoreAES#(128) AES128;
    typedef CoreAES#(192) AES192;
    typedef CoreAES#(256) AES256;

endpackage


