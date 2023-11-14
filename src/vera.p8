
vera {
    const uword reg_base = $9f20
    &uword addr = reg_base + $00
    &ubyte addr_h = reg_base + $02
    &ubyte data0 = reg_base + $03
    &ubyte data1 = reg_base + $04
    &ubyte ctrl = reg_base + $05
    &ubyte ien = reg_base + $06
    &ubyte isr = reg_base + $07
    &ubyte irq_line_l = reg_base + $08
    &ubyte scanline_l = reg_base + $08
    
    ; dcsel = 0
    &ubyte dc_video = reg_base + $09
    &ubyte dc_hscale = reg_base + $0a
    &ubyte dc_vscale = reg_base + $0b
    &ubyte dc_border = reg_base + $0c

    ; dcsel = 1
    &ubyte dc_hstart = reg_base + $09
    &ubyte dc_hstop = reg_base + $0a
    &ubyte dc_vstart = reg_base + $0b
    &ubyte dc_vstop = reg_base + $0c

    &ubyte l0_config = reg_base + $0d
    &ubyte l0_mapbase = reg_base + $0e
    &ubyte l0_tilebase = reg_base + $0f
    &word l0_hscroll = reg_base + $10
    &word l0_vscroll = reg_base + $12

    &ubyte l1_config = reg_base + $14
    &ubyte l1_mapbase = reg_base + $15
    &ubyte l1_tilebase = reg_base + $16
    &word l1_hscroll = reg_base + $17
    &word l1_vscroll = reg_base + $19

    const ubyte tile_1bpp = 0
    const ubyte bmp_1bpp = 0 + %0100
    const ubyte tile_1bpp_256c = 0 + %1000
    const ubyte bmp_1bpp_256c = 0 + %1100
    const ubyte tile_2bpp = 1
    const ubyte bmp_2bpp = 1 + %0100
    const ubyte tile_4bpp = 2
    const ubyte bmp_4bpp = 2 + %0100
    const ubyte tile_8bpp = 3
    const ubyte bmp_8bpp = 3 + %0100

    const ubyte map_32 = 0
    const ubyte map_64 = 1
    const ubyte map_128 = 2
    const ubyte map_256 = 3

    const ubyte tile_8 = 0
    const ubyte tile_16 = 1

    const ubyte incr_0 = (0 << 4)
    const ubyte incr_1 = (1 << 4)
    const ubyte incr_2 = (2 << 4)
    const ubyte incr_4 = (3 << 4)
    const ubyte incr_8 = (4 << 4)
    const ubyte incr_16 = (5 << 4)
    const ubyte incr_32 = (6 << 4)
    const ubyte incr_64 = (7 << 4)
    const ubyte incr_128 = (8 << 4)
    const ubyte incr_256 = (9 << 4)
    const ubyte incr_512 = (10 << 4)
    const ubyte incr_40 = (11 << 4)
    const ubyte incr_80 = (12 << 4)
    const ubyte incr_160 = (13 << 4)
    const ubyte incr_320 = (14 << 4)
    const ubyte incr_640 = (15 << 4)
    const ubyte decr_0 = (0 << 4) + %1000
    const ubyte decr_1 = (1 << 4) + %1000
    const ubyte decr_2 = (2 << 4) + %1000
    const ubyte decr_4 = (3 << 4) + %1000
    const ubyte decr_8 = (4 << 4) + %1000
    const ubyte decr_16 = (5 << 4) + %1000
    const ubyte decr_32 = (6 << 4) + %1000
    const ubyte decr_64 = (7 << 4) + %1000
    const ubyte decr_128 = (8 << 4) + %1000
    const ubyte decr_256 = (9 << 4) + %1000
    const ubyte decr_512 = (10 << 4) + %1000
    const ubyte decr_40 = (11 << 4) + %1000
    const ubyte decr_80 = (12 << 4) + %1000
    const ubyte decr_160 = (13 << 4) + %1000
    const ubyte decr_320 = (14 << 4) + %1000
    const ubyte decr_640 = (15 << 4) + %1000

    const ubyte enable_layer0 = 16
    const ubyte enable_layer1 = 32
    const ubyte enable_sprites = 64
    const ubyte disable_all = 15

    const ubyte video_vga = 1

    const ubyte ien_vsync = 1
    const ubyte ien_line = 2

    sub setAddress(uword address, ubyte incr) {
        addr = address
        addr_h = incr
    }

    sub setAddressHi(uword address, ubyte incr) {
        addr = address
        addr_h = incr + 1
    }

    sub setDcsel(ubyte dcsel) {
        ctrl = dcsel << 1
    }

    sub setHstart(uword hstart) {
        dc_hstart = (hstart >> 2) as ubyte
    }
    sub setHstop(uword hstop) {
        dc_hstop = (hstop >> 2) as ubyte
    }
    sub setVstart(uword vstart) {
        dc_vstart = (vstart >> 1) as ubyte
    }
    sub setVstop(uword vstop) {
        dc_vstop = (vstop >> 1) as ubyte
    }

    sub configLayer0(ubyte width, ubyte height, ubyte color) {
        l0_config = (width << 4) + (height << 6) + color
        return
    }

    sub setMapBase0(uword address) {
        l0_mapbase = (address >> 9) as ubyte
    }

    sub setTileBase0(ubyte width, ubyte height, uword address) {
        l0_tilebase = width + (height << 1) + (((address >> 9) as ubyte) & %11111100)
    }

    sub configLayer1(ubyte width, ubyte height, ubyte color) {
        l1_config = (width << 4) + (height << 6) + color
        return
    }

    sub setMapBase1(uword address) {
        l1_mapbase = (address >> 9) as ubyte
        return
    }

    sub setTileBase1(ubyte width, ubyte height, uword address) {
        l1_tilebase = width + (height << 1) + (((address >> 9) as ubyte) & %11111100)
        return
    }

    sub setAddrSprite(ubyte sprite, ubyte offset) {
        setAddressHi($fc00 + sprite * 8 + offset, incr_1)
        return
    }

    const ubyte sprite_4bpp = $00
    const ubyte sprite_8bpp = $80

    const ubyte sprite_8 = 0
    const ubyte sprite_16 = 1
    const ubyte sprite_32 = 2
    const ubyte sprite_64 = 3

    const ubyte sprite_disabled = $00

    sub setSpriteAddress(uword address, ubyte mode) {
        data0 = ((address >> 5) & $ff) as ubyte
        data0 = mode + ((address >> 13) & $0f) as ubyte
    }

    sub setSpriteXY(word xy) {
        data0 = (xy & $ff) as ubyte
        data0 = ((xy >> 8) & 3) as ubyte
    }

    sub setSpriteConfig(ubyte mask, ubyte z_depth) {
        data0 = (mask << 4) + ((z_depth & 3) << 2)
    }

    sub setSpriteSizePalette(ubyte width, ubyte height, ubyte palette_offset) {
        data0 = (width << 4) + (height << 6) + (palette_offset & $0f)
    }

    sub getScanline() -> uword {
        uword scanline = scanline_l as uword
        if ien & 64 {
            scanline += 256
        }
        return scanline
    }

    sub setIrqLine(uword line)  {
        scanline_l = (line & 255) as ubyte
        if (line < 256) {
            ien &= $7f
        }
        else {
            ien |= $80
        }
        return 
    }
}