//
//File: hash_pkg.sv
//Device: 
//Created:  2018-4-18 21:53:06
//Description: package
//Revisions: 
//2018-4-18 21:53:13: created
//

package hash_pkg;
    `include "base_macros.svh"
    import base_pkg::LogBase;

    `include "BaseHash.svh"
    `include "CoreMD5.svh"
    `include "CoreSHA1.svh"
endpackage

