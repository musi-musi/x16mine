%import syslib
%import vera
%import keyboard

player {

    const ubyte axis_x = 0
    const ubyte axis_y = 1

    word[2] position = [(12 * 256) + 128, (5 * 256) + 128]

    const uword speed = 16

    const uword sprite_base = $a000

    sub init() {
        vera.dc_video |= vera.enable_sprites

        vera.setAddress(sprite_base, vera.incr_1)
        repeat 8*16 {
            vera.data0 = $ff
        }

        vera.setAddrSprite(0, 0)
        vera.setSpriteAddress(sprite_base, vera.sprite_4bpp)
        vera.setSpriteXY((position[0] >> 4) - 8)
        vera.setSpriteXY((position[1] >> 4) - 8)
        vera.setSpriteConfig(0, 3)
        vera.setSpriteSizePalette(vera.sprite_16, vera.sprite_16, 0)

    }

    sub move(ubyte axis, word distance) {
        position[axis] += distance
        vera.setAddrSprite(0, 2 * (axis + 1))
        vera.setSpriteXY((position[axis] >> 4) - 8)
    }

    sub input() {
        word distance = 0
        if keyboard.checkKey(keyboard.key_a) {
            distance -= speed
        }
        if keyboard.checkKey(keyboard.key_d) {
            distance += speed
        }
        if distance != 0 {
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