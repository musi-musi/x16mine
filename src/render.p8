%import vera
%import level

render {

    sub init() {
        vera.setDcsel(1)
        vera.setVstart(16)
        vera.setVstop(480-1 - 16 * 4)
        vera.setDcsel(0)

        render_level.initLayers()
        render_level.drawRoom(0)

        render_level.enableLayers()

        return
    }

}

render_level {
    const ubyte wall_map_width = 128
    const ubyte wall_map_height = 64

    const ubyte floor_map_width = 64
    const ubyte floor_map_height = 32

    const uword wall_map_base = $1000
    const uword wall_tile_base = $0000
    const uword floor_map_base = $6000
    const uword floor_tile_base = $5000

    const uword bytes_per_tile_8 = 8 * 8 / 2
    const uword bytes_per_tile_16 = 16 * 16 / 2

    uword wall_tiles_count = 10
    wall_tiles:
        %asmbinary "wall_tiles.dat"
    uword floor_tiles_count = 1
    floor_tiles:
        %asmbinary "floor_tiles.dat"

    sub enableLayers() {
        ; vera.dc_video &= vera.disable_all
        vera.dc_video |= vera.enable_layer0
        vera.dc_video |= vera.enable_layer1
        vera.configLayer1(vera.map_128, vera.map_64, vera.tile_4bpp)
        vera.setMapBase1(wall_map_base)
        vera.setTileBase1(vera.tile_8, vera.tile_8, wall_tile_base)

        vera.configLayer0(vera.map_64, vera.map_32, vera.tile_4bpp)
        vera.setMapBase0(floor_map_base)
        vera.setTileBase0(vera.tile_16, vera.tile_16, floor_tile_base)

        vera.l1_hscroll = 0
        vera.l1_vscroll = 0
        vera.l0_hscroll = 0
        vera.l0_vscroll = 0

        return
    }

    sub initLayers() {
        uword i

        vera.setAddress(wall_tile_base, vera.incr_1)
        repeat bytes_per_tile_8 {
            vera.data0 = 0
        }
        for i in 0 to wall_tiles_count * bytes_per_tile_8 * 4 {
            vera.data0 = @(&wall_tiles+i)
        }

        vera.setAddress(wall_map_base+1, vera.incr_2)
        repeat wall_map_width {
            repeat wall_map_height {
                vera.data0 = $10
            }
        }

        vera.setAddress(floor_tile_base, vera.incr_1)
        repeat bytes_per_tile_16 {
            vera.data0 = $44
        }

        for i in 0 to floor_tiles_count * bytes_per_tile_16 {
            vera.data0 = @(&floor_tiles+i)
        }

        vera.setAddress(floor_map_base, vera.incr_1)
        repeat floor_map_width {
            repeat floor_map_height {
                vera.data0 = 1
                vera.data0 = $20
            }
        }

        return
    }

    sub drawRoom(ubyte room) {
        level.bankRoom(0)
        vera.setAddress(wall_map_base, vera.incr_2)
        ubyte row
        for row in 0 to level.room_height {
            drawRoomRow(row)
        }
    }

    sub drawRoomRow(ubyte row) {
        uword p = level.tiles + (row as uword) * level.room_width
        ubyte tile
        ubyte x
        setAddrRowStart(row, 0, vera.incr_4)
        x_incr = -1
        y_incr = -level.room_width
        x_limit = 0
        y_limit = 0
        drawRoomRowSubtile(p, row, 0)

        setAddrRowStart(row, 1, vera.incr_4)
        x_incr = 1
        x_limit = level.room_width-1
        drawRoomRowSubtile(p, row, 1)

        setAddrRowStart(row, wall_map_width + 0, vera.incr_4)
        x_incr = -1
        y_incr = level.room_width
        x_limit = 0
        y_limit = level.room_height - 1
        drawRoomRowSubtile(p, row, 2)

        setAddrRowStart(row, wall_map_width + 1, vera.incr_4)
        x_incr = 1
        x_limit = level.room_width-1
        drawRoomRowSubtile(p, row, 3)
    }

    word x_incr
    word y_incr
    uword x_limit
    uword y_limit

    sub drawRoomRowSubtile(uword p, ubyte row, ubyte subtile) {
        ubyte x
        ubyte tile
        for x in 0 to level.room_width {
            if p[x] != 0 {
                tile = 0
                if @((p + x + x_incr) as uword) != 0 or x == x_limit {
                    tile += 1
                }
                if @((p + x + y_incr) as uword) != 0 or row == y_limit {
                    tile += 2
                }
                if tile == 3 {
                    if x != x_limit
                    if row != y_limit
                    if @((p + x + x_incr + y_incr) as uword) == 0 {
                        tile = 4
                    }
                }
                tile += 5
                tile *= 4
                tile += subtile
                tile += 1
                vera.data0 = tile
            }
            else {
                vera.data0 = 0
            }
        }
    }

    sub setAddrRowStart(ubyte row, uword offset, ubyte incr) {
        vera.setAddress(wall_map_base + ((row as uword) * wall_map_width * 2 + offset) * 2, incr)
    }

}

render_hud {
    sub initLayers() {
        vera.dc_video &= vera.disable_all
    }
}