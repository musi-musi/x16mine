%import syslib
%import vera
%import util

level {

    const ubyte room_width = 40
    const ubyte room_height = 25

    const ubyte tiles_page = $08


    const uword tiles = $a000


    sub init() {
        bankRoom(0)
        util.loadFile("level.dat", tiles);
        return
    }

    sub bankRoom(ubyte room) {
        cx16.rambank(tiles_page + room)
        return
    }

}