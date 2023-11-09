%zeropage kernalsafe

%import textio
%import syslib
%import vera
%import scroll
%import keyboard
%import level


main {

    sub start() {
        level.init()
        keyboard.init()
        sys.set_irq(&irq.handler, 1)
        scroll.init()

        initVideo()
        loop:
        goto loop
        ; return
    }

    sub initVideo() {
        vera.ctrl = 0
        vera.dc_video = 1 + (1<<4)
        return
    }

}

irq {
    sub handler() {
        if (keyboard.checkKey(keyboard.key_w)) {
            vera.l0_vscroll -= 1
        }
        if (keyboard.checkKey(keyboard.key_s)) {
            vera.l0_vscroll += 1
        }
        if (keyboard.checkKey(keyboard.key_a)) {
            vera.l0_hscroll -= 1
        }
        if (keyboard.checkKey(keyboard.key_d)) {
            vera.l0_hscroll += 1
        }
        return
    }

}