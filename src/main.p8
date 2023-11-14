%zeropage kernalsafe

%import textio
%import syslib
%import vera
%import render
%import keyboard
%import level


main {

    sub start() {
        irq.init()
        level.init()
        keyboard.init()
        ; sys.set_irq(&irq.handler, 1)
        render.init()

        initVideo()
        ; render_level.initLayers()
        loop:
        ; if (vera.getScanline() > (480 - 16 * 4)) {
        ;     vera.dc_video &= ~vera.enable_layer0
        ; }
        ; else {
        ;     vera.dc_video |= vera.enable_layer0
        ; }
        goto loop
        ; return
    }

    sub initVideo() {
        vera.ctrl = 0
        return
    }

}

irq {

    sub init() {
        vera.setIrqLine(64);
        install(&vsync, &line)
    }


    ; sub handler() {
    ;     if (vera.isr & vera.ien_vsync) {
    ;     }
    ;     return
    ; }

    sub vsync() {
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

    sub line() {
        return
    }

    asmsub install(uword vsync_handler @R0, uword line_handler @R1) clobbers(A) {
        %asm {{
            ; enable line and vsync interrupts
            lda #%00000001
            sta cx16.VERA_IEN

            ; save system irq to immediate of jmp instruction
            lda cx16.CINV
            sta _old_irq+1
            lda cx16.CINV+1
            sta _old_irq+2

            lda cx16.r0
            sta _jsr_vsync+1
            lda cx16.r0+1
            sta _jsr_vsync+2
            lda cx16.r1
            sta _jsr_line+1
            lda cx16.r1+1
            sta _jsr_line+2

            sei
            lda #<_handler
            sta cx16.CINV
            lda #>_handler
            sta cx16.CINV+1
            cli

            rts

        _handler
            lda cx16.VERA_ISR
            and #$1
            bne _vsync_handler

            lda cx16.VERA_ISR
            and #$2
            bne _line_handler

            rti


        _vsync_handler
            jsr _irq_save
        _jsr_vsync
            jsr $ffff
            jsr _irq_restore
        _old_irq
            jmp $ffff
        

        _line_handler
            jsr _irq_save
        _jsr_line
            jsr $ffff
            jsr _irq_restore
            lda cx16.VERA_ISR
            ora #%00000010
            sta cx16.VERA_ISR
            ply
            plx
            pla
            rti

        _irq_save
            lda  P8ZP_SCRATCH_B1
            sta  IRQ_SCRATCH_ZPB1
            lda  P8ZP_SCRATCH_REG
            sta  IRQ_SCRATCH_ZPREG
            lda  P8ZP_SCRATCH_W1
            sta  IRQ_SCRATCH_ZPWORD1
            lda  P8ZP_SCRATCH_W1+1
            sta  IRQ_SCRATCH_ZPWORD1+1
            lda  P8ZP_SCRATCH_W2
            sta  IRQ_SCRATCH_ZPWORD2
            lda  P8ZP_SCRATCH_W2+1
            sta  IRQ_SCRATCH_ZPWORD2+1
            cld
            rts
        _irq_restore
            lda  IRQ_SCRATCH_ZPB1
            sta  P8ZP_SCRATCH_B1
            lda  IRQ_SCRATCH_ZPREG
            sta  P8ZP_SCRATCH_REG
            lda  IRQ_SCRATCH_ZPWORD1
            sta  P8ZP_SCRATCH_W1
            lda  IRQ_SCRATCH_ZPWORD1+1
            sta  P8ZP_SCRATCH_W1+1
            lda  IRQ_SCRATCH_ZPWORD2
            sta  P8ZP_SCRATCH_W2
            lda  IRQ_SCRATCH_ZPWORD2+1
            sta  P8ZP_SCRATCH_W2+1
            rts

        IRQ_SCRATCH_ZPB1	.byte  0
        IRQ_SCRATCH_ZPREG	.byte  0
        IRQ_SCRATCH_ZPWORD1	.word  0
        IRQ_SCRATCH_ZPWORD2	.word  0

        }}
    }

}