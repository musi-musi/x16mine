%import syslib
%import string

veradat {

    uword load_addr = 0
    ubyte load_bank = 0
    uword segments_len = 0
    uword segments = 0

    sub loadFileTo(str name, uword addr) {
        load_bank = @(0)
        load_addr = addr
        cbm.SETLFS(4, 8, 0)
        cbm.SETNAM(string.length(name), name)
        void cbm.LOAD(0, addr)
        @(0) = load_bank
        segments_len = derefWord(load_addr + 8)
        segments = load_addr + 10
    }

    sub loadFileToBank(str name) {
        loadFileTo(name, $a000)
    }

    sub getSegmentStart(uword table, uword segment) -> uword {
        return derefWord(table + segment * 6)
    }
    sub getSegmentStartH(uword table, uword segment) -> ubyte {
        return table[segment * 6 + 2]
    }
    sub getSegmentLen(uword table, uword segment) -> uword {
        return derefWord(table + segment * 6 + 3)
    }
    sub getSegmentLenH(uword table, uword segment) -> ubyte {
        return table[segment * 6 + 5]
    }

    sub copySegmentTable(uword dest) -> uword {
        @(0) = load_bank
        uword segment_count = derefWord(load_addr + 8)
        uword i = 0
        for i in 0 to segment_count * 6 {
            dest[i] = load_addr[10 + i]
        }
        return segment_count * 6
    }

    sub uploadVram() {
        @(0) = load_bank
        uword vram_start = derefWord(load_addr + 5);
        ubyte vram_start_h = load_addr[7];
        uploadVramTo(vram_start, vram_start_h)
    }

    sub uploadVramTo(uword addr, ubyte addr_h) {
        @(0) = load_bank
        uword data_start = derefWord(load_addr + 0)
        uword data_len = derefWord(load_addr + 2)
        ubyte data_len_h = load_addr[4]

        cx16.VERA_ADDR_L = (addr & $ff) as ubyte
        cx16.VERA_ADDR_M = ((addr >> 8) & $ff) as ubyte
        cx16.VERA_ADDR_H = $10 + (addr_h & 1)

        uword p = data_start
        repeat data_len_h {
            repeat 256 {
                repeat 256 {
                    cx16.VERA_DATA0 = @(p)
                    p += 1
                    if (p == $c000) {
                        p = $a000
                        @(0) += 1
                    }
                }
            }
        }
        repeat data_len {
            cx16.VERA_DATA0 = @(p)
            p += 1
            if (p == $c000) {
                p = $a000
                @(0) += 1
            }
        }
        @(0) = load_bank
    }

    sub derefWord(uword ptr) -> uword {
        return (ptr[0] as uword) + (ptr[1] as uword << 8)
    }

}