%import syslib
%import vera
%import util

level {

    const uword room_width = 40
    const uword room_height = 25

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

    sub getRoomTile(ubyte x, ubyte y) -> ubyte {
        if x >= room_width
            return $1
        if y >= room_height
            return $1
        return tiles[x + y * room_width]
    }

}