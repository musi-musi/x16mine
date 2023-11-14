%import syslib
%import vera
%import keyboard
%import level

player {

    const ubyte axis_x = 0
    const ubyte axis_y = 1

    word[2] position = [(12 * 256) + 128, (5 * 256) + 128]

    const uword speed = 32
    const ubyte radius = 64

    const uword sprite_base = $a000

    const uword sprite_pos_offset = 8

    sprite_data:
        %asmbinary "player_sprite.dat"

    sub init() {
        vera.dc_video |= vera.enable_sprites

        vera.setAddress(sprite_base, vera.incr_1)
        uword p = &sprite_data
        repeat 16*32 {
            vera.data0 = @(p)
            p += 1
        }

        vera.setAddrSprite(0, 0)
        vera.setSpriteAddress(sprite_base, vera.sprite_4bpp)
        vera.setSpriteXY((position[0] >> 4) - sprite_pos_offset)
        vera.setSpriteXY((position[1] >> 4) - sprite_pos_offset)
        vera.setSpriteConfig(0, 3)
        vera.setSpriteSizePalette(vera.sprite_16, vera.sprite_16, 3)

    }

    sub move(ubyte axis, word distance) {

        if (distance > 0) {
            position[axis] += radius
        }
        else {
            position[axis] -= radius
        }

        position[axis] += distance

        setTilePos()

        if checkTile() != 0 {
            goto collision
        }
        else {
            ubyte norm = axis ^ 1
            if (position[norm] & $ff) as ubyte < radius {
                tile_pos[norm] -= 1
                if checkTile() != 0 {
                    goto collision
                }
            }
            else if (position[norm] & $ff) as ubyte >= (255 - radius) {
                tile_pos[norm] += 1
                if checkTile() != 0 {
                    goto collision
                }
            }
        }
        goto end

    collision:
        position[axis] -= distance
        if distance > 0 {
            position[axis] = (position[axis] & $ff00 as word) + $00f0
        }
        else {
            position[axis] = (position[axis] & $ff00 as word) + $0010 
        }


    end:
        if (distance > 0) {
            position[axis] -= radius
        }
        else {
            position[axis] += radius
        }

        vera.setAddrSprite(0, 2 * (axis + 1))
        vera.setSpriteXY((position[axis] >> 4) - sprite_pos_offset)
    }

    ubyte[2] tile_pos

    sub setTilePos() {
        tile_pos[0] = ((position[0] >> 8) & $ff) as ubyte
        tile_pos[1] = ((position[1] >> 8) & $ff) as ubyte
    }

    sub checkTile() -> ubyte {
        return level.getRoomTile(tile_pos[0], tile_pos[1])
    }

    sub vsync() {
        level.bankRoom(0)
        word distance = 0
        if keyboard.checkKey(keyboard.key_a) {
            distance -= speed
        }
        if keyboard.checkKey(keyboard.key_d) {
            distance += speed
        }
        if distance != 0 {
            if (distance > 0) {
                vera.updateSpriteFlip(0, 0, 0)
            }
            else {
                vera.updateSpriteFlip(0, 1, 0)
            }
            move(axis_x, distance)
        }
        distance = 0
        if keyboard.checkKey(keyboard.key_w) {
            distance -= speed
        }
        if keyboard.checkKey(keyboard.key_s) {
            distance += speed
        }
        if distance != 0 {
            move(axis_y, distance)
        }
    }

}