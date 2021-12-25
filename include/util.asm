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