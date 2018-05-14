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
    `include "CoreSHA2S2.svh"
    `include "CoreSHA2S5.svh"
    `include "CoreHMAC.svh"
    typedef CoreHMAC#(CoreMD5) HMAC_MD5;
    typedef CoreHMAC#(CoreSHA1) HMAC_SHA1;
    typedef CoreHMAC#(CoreSHA224) HMAC_SHA224;
    typedef CoreHMAC#(CoreSHA256) HMAC_SHA256;
    typedef CoreHMAC#(CoreSHA384) HMAC_SHA384;
    typedef CoreHMAC#(CoreSHA512) HMAC_SHA512;
    typedef CoreHMAC#(CoreSHA512_224) HMAC_SHA512_224;
    typedef CoreHMAC#(CoreSHA512_256) HMAC_SHA512_256;
endpackage

