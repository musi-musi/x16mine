
%import syslib
%import vera


keyboard {

    bool[256] @shared key_status 


    const ubyte key_grave = $01
    const ubyte key_1 = $02
    const ubyte key_2 = $03
    const ubyte key_3 = $04
    const ubyte key_4 = $05
    const ubyte key_5 = $06
    const ubyte key_6 = $07
    const ubyte key_7 = $08
    const ubyte key_8 = $09
    const ubyte key_9 = $0a
    const ubyte key_0 = $0b
    const ubyte key_minus = $0c
    const ubyte key_equal = $0d
    const ubyte key_backspace = $0f
    const ubyte key_tab = $10

    const ubyte key_q =  $11
    const ubyte key_w =  $12
    const ubyte key_e =  $13
    const ubyte key_r =  $14
    const ubyte key_t =  $15
    const ubyte key_y =  $16
    const ubyte key_u =  $17
    const ubyte key_i =  $18
    const ubyte key_o =  $19
    const ubyte key_p =  $1a

    const ubyte key_lbracket =  $1b
    const ubyte key_rbracket =  $1c
    const ubyte key_backslash =  $1d
    const ubyte key_capslock =  $1e

    const ubyte key_a =  $1f
    const ubyte key_s =  $20
    const ubyte key_d =  $21
    const ubyte key_f =  $22
    const ubyte key_g =  $23
    const ubyte key_h =  $24
    const ubyte key_j =  $25
    const ubyte key_k =  $26
    const ubyte key_l =  $27

    const ubyte key_semicolon =  $28
    const ubyte key_quote =  $29
    const ubyte key_enter =  $2b
    const ubyte key_lshift =  $2c

    const ubyte key_z =  $2e
    const ubyte key_x =  $2f
    const ubyte key_c =  $30
    const ubyte key_v =  $31
    const ubyte key_b =  $32
    const ubyte key_n =  $33
    const ubyte key_m =  $34

    const ubyte key_comma =  $35
    const ubyte key_point =  $36
    const ubyte key_slash =  $37
    const ubyte key_rshift =  $39
    const ubyte key_lctrl =  $3a
    const ubyte key_lsuper =  $3b
    const ubyte key_lalt =  $3e
    const ubyte key_space =  $3d
    const ubyte key_ralt =  $3e
    const ubyte key_rsuper =  $3f
    const ubyte key_rctrl =  $40
    const ubyte key_menu =  $41
    const ubyte key_insert =  $4b
    const ubyte key_delete =  $4c
    const ubyte key_left =  $4f
    const ubyte key_home =  $50
    const ubyte key_end =  $51
    const ubyte key_up =  $53
    const ubyte key_down =  $54
    const ubyte key_pgup =  $55
    const ubyte key_pgdown =  $56
    const ubyte key_right =  $59

    const ubyte key_esc =  $6e
    const ubyte key_f1 =  $70
    const ubyte key_f2 =  $71
    const ubyte key_f3 =  $72
    const ubyte key_f4 =  $73
    const ubyte key_f5 =  $74
    const ubyte key_f6 =  $75
    const ubyte key_f7 =  $76
    const ubyte key_f8 =  $77
    const ubyte key_f9 =  $78
    const ubyte key_f10 =  $79
    const ubyte key_f11 =  $7a
    const ubyte key_f12 =  $7b



    sub init() {
        %asm {{

            sei
            lda #<keyboard_handler
            sta cx16.KEYHDL
            lda #>keyboard_handler
            sta cx16.KEYHDL + 1
            cli
            rts

        keyboard_handler:
            ldx #1
            and #$ff
            bpl +
            ldx #0
        +
            and #$7f
            tay
            txa
            sta p8_key_status,y
        }}

        return
    }

    sub checkKey(ubyte key) -> bool {
        return key_status[key]
    }

}
