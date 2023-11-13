%zeropage kernalsafe

%import textio
%import syslib
%import vera
%import render
%import keyboard
%import level


main {

    sub start() {
        level.init()
        keyboard.init()
        sys.set_irq(&irq.handler, 1)
        render.init()

        initVideo()
        render_level.initLayers()
        loop:
        goto loop
        ; return
    }

    sub initVideo() {
        vera.ctrl = 0
        vera.ien = vera.ien_vsync
        return
    }

}

irq {


    sub handler() {
        if (vera.isr & vera.ien_vsync) {
            ; if (keyboard.checkKey(keyboard.key_w)) {
            ;     vera.l0_vscroll -= 1
            ; }
            ; if (keyboard.checkKey(keyboard.key_s)) {
            ;     vera.l0_vscroll += 1
            ; }
            ; if (keyboard.checkKey(keyboard.key_a)) {
            ;     vera.l0_hscroll -= 1
            ; }
            ; if (keyboard.checkKey(keyboard.key_d)) {
            ;     vera.l0_hscroll += 1
            ; }
        }
        return
    }

}