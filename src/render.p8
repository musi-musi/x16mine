%import vera
%import level

render {

    sub init() {

        render_level.drawRoom(0)

        render_level.initLayers();

        return
    }

}

render_level {
    const ubyte map_width = 128
    const ubyte map_height = 64

    const uword map_base = $1000
    const uword tile_base = $0000

    const uword bytes_per_tile = 8 * 8 / 2

    uword wall_tiles_count = 5
    wall_tiles:
        %asmbinary "wall_tiles.dat"

    sub initLayers() {
        vera.dc_video |= vera.enable_layer1
        vera.configLayer1(vera.map_128, vera.map_64, vera.tile_4bpp)
        vera.setMapBase1(map_base)
        vera.setTileBase1(vera.tile_8, vera.tile_8, tile_base)

        vera.l1_hscroll = 0
        vera.l1_vscroll = 0

        vera.setDcsel(1)
        vera.setVstart(16)
        vera.setVstop(480-1 - 16 * 4)
        vera.setDcsel(0)

        vera.setAddress(tile_base, vera.incr_1)
        repeat bytes_per_tile {
            vera.data0 = 0
        }
        uword i
        for i in 0 to wall_tiles_count * bytes_per_tile * 4 {
            vera.data0 = @(&wall_tiles+i)
        }

        vera.setAddress(map_base+1, vera.incr_2)
        repeat map_width {
            repeat map_height {
                vera.data0 = $10
            }
        }
    }

    sub drawRoom(ubyte room) {
        level.bankRoom(0)
        vera.setAddress(map_base, vera.incr_2)
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

        setAddrRowStart(row, map_width + 0, vera.incr_4)
        x_incr = -1
        y_incr = level.room_width
        x_limit = 0
        y_limit = level.room_height - 1
        drawRoomRowSubtile(p, row, 2)

        setAddrRowStart(row, map_width + 1, vera.incr_4)
        x_incr = 1
        x_limit = level.room_width-1
        drawRoomRowSubtile(p, row, 3)
        ; for x in 0 to level.room_width {
        ;     if p[x] != 0 {
        ;         tile = 0
        ;         if @(p + x - 1) != 0 or x == 0 {
        ;             tile += 1
        ;         }
        ;         if @(p + x - level.room_width) != 0 or row == 0 {
        ;             tile += 2
        ;         }
        ;         tile *= 4
        ;         tile += 1
        ;         vera.data0 = tile
        ;     }
        ;     else {
        ;         vera.data0 = 0
        ;     }
        ; }
        ; setAddrRowStart(row, 1, vera.incr_4)
        ; for x in 0 to level.room_width {
        ;     if p[x] != 0 {
        ;         tile = 0
        ;         if @(p + x + 1) != 0 or x == level.room_width - 1 {
        ;             tile += 1
        ;         }
        ;         if @(p + x - level.room_width) != 0 or row == 0 {
        ;             tile += 2
        ;         }
        ;         tile *= 4
        ;         tile += 2
        ;         vera.data0 = tile
        ;     }
        ;     else {
        ;         vera.data0 = 0
        ;     }
        ; }
        ; setAddrRowStart(row, map_width, vera.incr_4)
        ; for x in 0 to level.room_width {
        ;     if p[x] != 0 {
        ;         tile = 0
        ;         if @(p + x - 1) != 0 or x == 0 {
        ;             tile += 1
        ;         }
        ;         if @(p + x + level.room_width) != 0 or row == level.room_height - 1 {
        ;             tile += 2
        ;         }
        ;         tile *= 4
        ;         tile += 3
        ;         vera.data0 = tile
        ;     }
        ;     else {
        ;         vera.data0 = 0
        ;     }
        ; }
        ; setAddrRowStart(row, map_width + 1, vera.incr_4)
        ; for x in 0 to level.room_width {
        ;     if p[x] != 0 {
        ;         tile = 0
        ;         if @(p + x + 1) != 0 or x == level.room_width - 1 {
        ;             tile += 1
        ;         }
        ;         if @(p + x + level.room_width) != 0 or row == level.room_height - 1{
        ;             tile += 2
        ;         }
        ;         tile *= 4
        ;         tile += 4
        ;         vera.data0 = tile
        ;     }
        ;     else {
        ;         vera.data0 = 0
        ;     }
        ; }
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
        vera.setAddress(map_base + ((row as uword) * map_width * 2 + offset) * 2, incr)
    }

}

render_hud {
    sub initLayers() {
        vera.dc_video &= vera.disable_all
    }
}