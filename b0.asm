; =================================================================
; Jupiter Ace Self-Adjusting Boot & 3-Line Buffer Injector ("b0")
; =================================================================

        ORG 0x3C5a

; =================================================================
; Maskinkod och 3-raders buffertinjektor
; =================================================================
b0:
        jr start                ; Hopp förbi variabler

txt_ptr:    DW payload          ; Pekare till nuvarande tecken i payload

start:
        ; 1. Rensa 3 rader (96-1 bytes) från 9889 med mellanslag (32)
        ld hl, 9889
        ld bc, 95
clear_buf_loop:
        ld (hl), 32
        inc hl
        dec bc
        ld a, b
        or c
        jr nz, clear_buf_loop

        ; 2. Lägg 0-stopp på 9888 (9889 - 1)
        xor a
        ld (9888), a

        ; 3. Uppdatera sysvars för 3-raders buffert
        ld hl, 9888
        ld (15390), hl          ; 0x3C1E (SPARE / start)
        ld (15396), hl          ; 0x3C24 (SCRPOS / markör)
        ld hl, 9953
        ld (15392), hl          ; 0x3C20
        ld (15394), hl          ; 0x3C22

        ; 4. Läs in nästa rad från payload till 9889
        ld hl, (txt_ptr)
        ld de, 9889

copy_loop:
        ld a, (hl)
        or a                    ; EOF (0)?
        jr z, eof_reached

        cp 13                   ; CR?
        jr z, handle_newline
        cp 10                   ; LF?
        jr z, handle_newline

        ld (de), a
        inc hl
        inc de
        jr copy_loop

handle_newline:
        inc hl                  ; Hoppa över CR/LF

        ; Lägg till " b" på slutet av raden
        ld a, ' '
        ld (de), a
        inc de
        ld a, 'b'
        ld (de), a
        inc de

eof_reached:
        ld (txt_ptr), hl
        jp (iy)

; =================================================================
; Payload
; =================================================================
payload:
        INCBIN "program.fs"
        DEFB 0

end_of_code:
