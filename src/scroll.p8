%import vera
%import level

scroll {

    const ubyte map_width = 64
    const ubyte map_height = 64

    const uword map_base = $1000
    const uword tile_base = $0000


    sub init() {
        vera.configLayer0(vera.map_64, vera.map_64, vera.tile_1bpp)
        vera.setMapBase0(map_base)
        vera.setTileBase0(vera.tile_16, vera.tile_16, tile_base)

        vera.setAddress(tile_base, vera.incr_1)
        repeat 32 {
            vera.data0 = 255
        }

        vera.setAddress(map_base, vera.incr_2)
        repeat map_width {
            repeat map_height {
                vera.data0 = 0
            }
        }


        vera.setAddress(map_base+1, vera.incr_2)
        level.setBank()
        uword i = 0
        for i in 0 to (map_width * map_height) {
            vera.data0 = @(level.tiles + i)
        }


        return
    }

}