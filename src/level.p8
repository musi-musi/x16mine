%import syslib
%import vera

level {

    const ubyte width_bits = 6
    const ubyte width = 1 << width_bits

    const ubyte tiles_page = $04


    ; ubyte[width * width]
    const uword tiles = $a000


    sub init() {
        cbm.SETLFS(4, 8, 0)
        cbm.SETNAM(9, "level.dat")
        setBank()
        void cbm.LOAD(0, tiles)
        return
    }

    sub setBank() {
        @(0) = tiles_page
        return
    }



    ubyte tile_x = 0
    ubyte tile_y = 0

}