
%import syslib
%import vera


keyboard {

    bool[8] key_status 

    const ubyte key_w = 0
    const ubyte key_a = 1
    const ubyte key_s = 2
    const ubyte key_d = 3


    const ubyte scancode_q =  $11
    const ubyte scancode_w =  $12
    const ubyte scancode_e =  $13
    const ubyte scancode_r =  $14
    const ubyte scancode_t =  $15
    const ubyte scancode_y =  $16
    const ubyte scancode_u =  $17
    const ubyte scancode_i =  $18
    const ubyte scancode_o =  $19
    const ubyte scancode_p =  $1a

    const ubyte scancode_a =  $1f
    const ubyte scancode_s =  $20
    const ubyte scancode_d =  $21
    const ubyte scancode_f =  $22
    const ubyte scancode_g =  $23
    const ubyte scancode_h =  $24
    const ubyte scancode_j =  $25
    const ubyte scancode_k =  $26
    const ubyte scancode_l =  $27

    const ubyte scancode_z =  $2e
    const ubyte scancode_x =  $2f
    const ubyte scancode_c =  $30
    const ubyte scancode_v =  $31
    const ubyte scancode_b =  $32
    const ubyte scancode_n =  $33
    const ubyte scancode_m =  $34

    const ubyte scancode_space =  $3d


    sub init() {
        %asm {{

            sei
            lda #<keyboard_handler
            sta cx16.KEYHDL
            lda #>keyboard_handler
            sta cx16.KEYHDL + 1
            cli
            rts

        check_key .macro key
            cmp #p8_scancode_\1
            bne check_\1_else
            stx p8_key_status+p8_key_\1
            check_\1_else
        .endmacro

        keyboard_handler:
            ldx #1
            and #$ff
            bpl +
            ldx #0
        +

            and #$7f

            #check_key w
            #check_key a
            #check_key s
            #check_key d
        }}

        return
    }

    sub checkKey(ubyte key) -> bool {
        return key_status[key]
    }

}
