macro z_ldir
  push af
  \@Ldirb:
    ldi a, [hl]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, \@Ldirb
  pop af
endm

; NOTE:
; - When using this macros inside another method, it may cause
; "unknown symbol" error. To fix, use non-local method naming,
; e.g. instead of ".loop:", use "SomeFunctionLoop:"

; Mods A, saves remainder in A (destroys AF):
; - A = the original value
; Usage: mod n
macro mod
  push bc
    ld b, \1
\@loop:
    sub b
    jr nc, \@loop
    add b
  pop bc
endm