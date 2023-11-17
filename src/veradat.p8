%import syslib
%import vera
%import util

veradat {
    const uword load_addr = $a000
    const ubyte load_bank = $02

    &uword start_addr = load_addr + $0
    &uword data_start = load_addr + $2
    &uword data_len = load_addr + $4
    &uword palette_start = load_addr + $6
    &uword palette_len = load_addr + $8
    &uword entry_count = load_addr + $a
    const uword entries_start = load_addr + $c

    sub load() {
        cx16.rambank(load_bank);
        util.loadFile("vera.dat", load_addr)

        cx16.rambank(load_bank);

        vera.setAddressHi($fa00, vera.incr_1);
        uword i = 0
        for i in 0 to palette_len {
            vera.data0 = @(palette_start + i)
        }

        vera.setAddress(start_addr, vera.incr_1)

        uword p = data_start
        repeat data_len {
            vera.data0 = @(p)
            p += 1
            if p == $bfff {
                p = $a000
                @(0) += 1
            }
        }

    }

    sub getEntryAddress(uword entry) -> uword {
        cx16.rambank(load_bank)
        return @(entries_start + entry * 2) as uword + (@(entries_start + entry * 2 + 1) as uword << 8)
    }

}