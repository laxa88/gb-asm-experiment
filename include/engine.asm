SECTION "Common functions", ROM0

; At beginning of program, this is copied to $ff80 (available address for DMA)
; Every time vblank occurs at $0040, the code will jump to $ff80, and calls this.
; It will load the hi-byte (e.g. $c0) of _RAM ($c000) into rDMA ($ff46) to trigger
; the DMA to copy data starting from $c000.
; It will then wait $28 (160) cycles for the DMA to complete.
; NOTE: Since music is reserved starting from $c000, we'll reserve $c100 for our
; OAM data instead.
DMACopy:
  push af
    ld a, rRAM_OAM/256          ; get top byte of sprite buffer starting address, i.e. $c0
    ld [rDMA], a                ; trigger DMA transfer to copy data from on $c000
    ld a, $28                   ; delay for 40 loops (1 loop = 4 ms, DMA completes in 160 ms)
DMACopyWait:
    dec a
    jr nz, DMACopyWait          ; wait until DMA is complete
  pop af
  reti
DMACopyEnd:

; Copy data from DE to HL:
; - DE = spritesheet address start
; - BC = length of spritesheet data (i.e. End - Start address)
; - HL = target start VRAM address (e.g. $8800)
CopyData:
  ld a, [de]
  ld [hli], a
  inc de
  dec bc
  ld a, b
  or a, c
  jp nz, CopyData
  ret

; Reads inputs and puts them in register A, where:
; - hi-nibble is dpad (7654 = Down, Up, Left, Right)
; - lo-nibble is buttons (3210 = Start, Select, B, A)
; - 1 = pressed, 0 = not pressed
; e.g. 00010010 = RIGHT and B are pressed
ReadInput:
  push af
  push bc
    ; Save previous inputs
    ld a, [rInputs]
    ld c, a               ; Save this for pressed/released logic below
    ld [rInputsPrev], a

    ; Read new inputs
    xor a
    ld [rP1], a       ; Reset all input states before checking every loop
    ; Reference: https://gbdev.io/pandocs/Joypad_Input.html
    ld a, P1F_GET_DPAD
    ld [rP1], a
    ld a, [rP1]       ; read values (Remember: 0 = selected!)
    or %11110000      ; pad hi-nibble first
    swap a            ; move values to bits-7654 (dpad nibble)
    ld b, a           ; save to B
    ld a, P1F_GET_BTN
    ld [rP1], a
    ld a, [rP1]       ; read values (Remember: 0 = selected!)
    ld a, [rP1]       ; read another time to stabilise input
    or %11110000      ; ignore upper nibble
    and b             ; merge with dpad nibble
    cpl               ; invert A such that 1 = selected
    ld [rInputs], a   ; save latest inputs

    ; Save pressed/released states
    xor c
    ld b, a                 ; XOR old and new inputs to get all changed bits, save to B
    ld a, [rInputs]
    and b
    ld [rInputsPressed], a  ; AND only new inputs as "pressed"
    ld a, [rInputsPrev]
    and b
    ld [rInputsReleased], a ; AND only old inputs as "released"
  pop bc
  pop af
  ret