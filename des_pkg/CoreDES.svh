//
//File: CoreDES.svh
//Device: 
//Created:  2017-4-9 16:04:39
//Description: DES core
//Revisions: 
//2017-4-9 16:04:58: created
//

`ifndef __CORE_DES_SVH__
`define __CORE_DES_SVH__

virtual class DESTypes extends LogBase;
    `define __T_BITS(bit_w) \
        typedef bit[1:bit_w] _tL``bit_w;

    `__T_BITS(64)
    `__T_BITS(56)
    `__T_BITS(48)
    `__T_BITS(32)
    `__T_BITS(28)
    `__T_BITS(6)
    `__T_BITS(4)

    typedef union packed {
        _tL64 dl;
        struct packed{
            _tL32 l;
            _tL32 r;
        } sub;
    } uBlockT;
    
    typedef union packed {
        _tL56 cdl;
        struct packed{_tL28 c, d;} sub;
    } uCD;

endclass

virtual class DESPreliminaries extends DESTypes;

    static protected function _tL64 mTransInitPermutation (_tL64 din);
        return {
            din[58], din[50], din[42], din[34], din[26], din[18], din[10], din[2],
            din[60], din[52], din[44], din[36], din[28], din[20], din[12], din[4],
            din[62], din[54], din[46], din[38], din[30], din[22], din[14], din[6],
            din[64], din[56], din[48], din[40], din[32], din[24], din[16], din[8],
            din[57], din[49], din[41], din[33], din[25], din[17], din[9],  din[1],
            din[59], din[51], din[43], din[35], din[27], din[19], din[11], din[3],
            din[61], din[53], din[45], din[37], din[29], din[21], din[13], din[5],
            din[63], din[55], din[47], din[39], din[31], din[23], din[15], din[7]
        };
    endfunction

    static protected function _tL64 mTransInitPermutationInv (_tL64 din);
        return {
            din[40], din[8], din[48], din[16], din[56], din[24], din[64], din[32],
            din[39], din[7], din[47], din[15], din[55], din[23], din[63], din[31],
            din[38], din[6], din[46], din[14], din[54], din[22], din[62], din[30],
            din[37], din[5], din[45], din[13], din[53], din[21], din[61], din[29],
            din[36], din[4], din[44], din[12], din[52], din[20], din[60], din[28],
            din[35], din[3], din[43], din[11], din[51], din[19], din[59], din[27],
            din[34], din[2], din[42], din[10], din[50], din[18], din[58], din[26],
            din[33], din[1], din[41], din[9],  din[49], din[17], din[57], din[25],
        };
    endfunction

    static protected function _tL48 fTransETable (_tL32 di);
        return {
            di[32], di[1],  di[2],  di[3],  di[4],  di[5],
            di[4],  di[5],  di[6],  di[7],  di[8],  di[9],
            di[8],  di[9],  di[10], di[11], di[12], di[13],
            di[12], di[13], di[14], di[15], di[16], di[17],
            di[16], di[17], di[18], di[19], di[20], di[21],
            di[20], di[21], di[22], di[23], di[24], di[25],
            di[24], di[25], di[26], di[27], di[28], di[29],
            di[28], di[29], di[30], di[31], di[32], di[1] };
    endfunction: fTransETable
    
    typedef struct packed {_tL4 v[0:63];} _ST;
    static protected const _ST STable[1:8] = '{
        '{{
            14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7,
            0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8,
            4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0,
            15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13
        }},
        '{{
            15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10,
            3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5,
            0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15,
            13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9
        }},
        '{{
            10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8,
            13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1,
            13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7,
            1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12
        }},
        '{{
            7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15,
            13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9,
            10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4,
            3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14
        }},
        '{{
            2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9,
            14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6,
            4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14,
            11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3
        }},
        '{{
            12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11,
            10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8,
            9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6,
            4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13
        }},
        '{{
            4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1,
            13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6,
            1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2,
            6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12
        }},
        '{{
            13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7,
            1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2,
            7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8,
            2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11
        }}
    };

    static protected function _tL4 valueSBox (_tL6 din, int unsigned box_id);
        _tL6 idx;
        idx = {din[1], din[6], din[2:5]};
        return STable[box_id].v[idx];
    endfunction: valueSBox

    static protected function _tL32 fTransPTable (_tL32 di);
        return {
            di[16], di[7],  di[20], di[21],
            di[29], di[12], di[28], di[17],
            di[1],  di[15], di[23], di[26],
            di[5],  di[18], di[31], di[10],
            di[2],  di[8],  di[24], di[14],
            di[32], di[27], di[3],  di[9],
            di[19], di[13], di[30], di[6],
            di[22], di[11], di[4],  di[25] };
    endfunction: fTransPTable

    static protected function _tL32 fTrans (_tL32 lr, _tL48 sub_key);
        _tL48 tmp48;
        _tL32 tmp32;
        tmp48 = fTransETable(lr);
        tmp48 ^= sub_key;
        `define _sbox(n) STable[n].v[tmp48[6*n-5:6*n]]

        tmp32 = {
            `_sbox(1), `_sbox(2), `_sbox(3), `_sbox(4),
            `_sbox(5), `_sbox(6), `_sbox(7), `_sbox(8) };
        return fTransPTable(tmp32);
    endfunction: fTrans

    static protected function uCD ksPC_1(_tL64 key);
        return {
            key[57], key[49], key[41], key[33], key[25], key[17], key[9],
            key[1],  key[58], key[50], key[42], key[34], key[26], key[18],
            key[10], key[2],  key[59], key[51], key[43], key[35], key[27],
            key[19], key[11], key[3],  key[60], key[52], key[44], key[36],

            key[63], key[55], key[47], key[39], key[31], key[23], key[15],
            key[7],  key[62], key[54], key[46], key[38], key[30], key[22],
            key[14], key[6],  key[61], key[53], key[45], key[37], key[29],
            key[21], key[13], key[5],  key[28], key[20], key[12], key[4]
        };
    endfunction
    
    static const protected int unsigned shiftTable[1:16] = '{
        1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1
    };

    static protected function _tL48 ksPC_2(uCD din);
        return {
            din.cdl[14], din.cdl[17], din.cdl[11], din.cdl[24], din.cdl[1],  din.cdl[5],
            din.cdl[3],  din.cdl[28], din.cdl[15], din.cdl[6],  din.cdl[21], din.cdl[10],
            din.cdl[23], din.cdl[19], din.cdl[12], din.cdl[4],  din.cdl[26], din.cdl[8],
            din.cdl[16], din.cdl[7],  din.cdl[27], din.cdl[20], din.cdl[13], din.cdl[2],
            din.cdl[41], din.cdl[52], din.cdl[31], din.cdl[37], din.cdl[47], din.cdl[55],
            din.cdl[30], din.cdl[40], din.cdl[51], din.cdl[45], din.cdl[33], din.cdl[48],
            din.cdl[44], din.cdl[49], din.cdl[39], din.cdl[56], din.cdl[34], din.cdl[53],
            din.cdl[46], din.cdl[42], din.cdl[50], din.cdl[36], din.cdl[29], din.cdl[32]
        };
    endfunction

endclass: DESPreliminaries 

class CoreDES extends DESPreliminaries;
    protected bit sub_key_updated;
    protected _tL64 key_r;
    protected _tL48 sub_key[1:16];

    function new(_tL64 key = 0);
        this.key_r = key;
        sub_key_updated = 0;
        is_muted = 1;
    endfunction

    function void setKey(_tL64 key);
        if (this.key_r == key) begin
            `_LOG("Use latched key..")
        end else begin
            sub_key_updated = 0;
            this.key_r = key;
        end
    endfunction

    protected function void subKeyUpdate ();
        if (sub_key_updated == 1) return;
        else begin
            uCD ucd;
            _tL28 c, d;
            ucd = ksPC_1(this.key_r);
            for (int i = 1; i <= 16; i++) begin
                `rotl(c, shiftTable[i])
                `rotl(d, shiftTable[i])
                ucd.sub.c = c;
                ucd.sub.d = d;
                sub_key[i] = ksPC_2(ucd);
            end
        end
        sub_key_updated = 1;
    endfunction: subKeyUpdate

endclass: CoreDES 

`endif

