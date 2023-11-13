%import vera
%import level

render {

    sub init() {
        render_level.initLayers();

        render_level.drawRoom(0)

        return
    }

}

render_level {
    const ubyte map_width = 64
    const ubyte map_height = 64

    const uword map_base = $1000
    const uword tile_base = $0000

    uword wall_tiles_count = 4
    wall_tiles:
        %asmbinary "wall_tiles.dat"

    sub initLayers() {
        vera.dc_video |= vera.enable_layer0
        vera.configLayer0(vera.map_64, vera.map_64, vera.tile_1bpp)
        vera.setMapBase0(map_base)
        vera.setTileBase0(vera.tile_16, vera.tile_16, tile_base)

        vera.l0_hscroll = 0
        vera.l0_vscroll = 0

        vera.setDcsel(1)
        vera.setVstart(16)
        vera.setVstop(480-1 - 16 * 4)
        vera.setDcsel(0)

        vera.setAddress(tile_base, vera.incr_1)
        repeat 32 {
            vera.data0 = 0
        }
        uword i
        for i in 0 to wall_tiles_count*32 {
            vera.data0 = @(&wall_tiles+i)
        }

        vera.setAddress(map_base+1, vera.incr_2)
        repeat map_width {
            repeat map_height {
                vera.data0 = (0 << 4) + 15
            }
        }
    }

    sub drawRoom(ubyte room) {
        level.bankRoom(0)
        vera.setAddress(map_base, vera.incr_2)
        uword p = level.tiles
        repeat level.room_height {
            repeat level.room_width {
                vera.data0 = @(p)
                p += 1
            }
            vera.addr += ((map_width - level.room_width) * 2)
        }
    }

}

render_hud {
    sub initLayers() {
        vera.dc_video &= vera.disable_all
    }
}