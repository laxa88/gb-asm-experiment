; Constants and macros

DEF INPUT_BTN_A       EQU %00000001
DEF INPUT_BTN_B       EQU %00000010
DEF INPUT_BTN_SELECT  EQU %00000100
DEF INPUT_BTN_START   EQU %00001000
DEF INPUT_DPAD_RIGHT  EQU %00010000
DEF INPUT_DPAD_LEFT   EQU %00100000
DEF INPUT_DPAD_UP     EQU %01000000
DEF INPUT_DPAD_DOWN   EQU %10000000

macro draw_text ; String, X, Y
  ld hl, \1
  ld a, \2
  ld [rCharX], a
  ld a, \3
  ld [rCharY], a
  call DrawString
endm

; Note: make sure ReadInput is called first
macro check_pressed ; INPUT_CONSTANT, flag, methodNameOnTrue
  ld a, [rInputsPressed]
  and \1
  jp \2, \3
endm

SECTION "Engine variables", WRAM0

rInputs: db
rInputsPrev: db
rInputsPressed: db
rInputsReleased: db

rCharX: db
rCharY: db

SECTION "Common functions", ROM0

; Multiplies 2 numbers
; - B, C = values to multiply
; - A = multiplied result
; - Destroys AF, BC
Multiply:
    xor a
.rep:
    add c
    dec b
    jr nz, .rep
  ret

InitEngineVariables:
  push af
    xor a
    ld [rCharX], a
    ld [rCharY], a
    ld [rInputs], a
    ld [rInputsPrev], a
    ld [rInputsPressed], a
    ld [rInputsReleased], a
  pop af
  ret

; Destroys A
WaitVBlank:
  ld a, [rLY]
  cp 144
  jr c, WaitVBlank
  ret

; Destroys A
TurnOffScreen:
  call WaitVBlank
  xor a
  ld [rLCDC], a
  ret


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

; Draws a string of text:
; - HL = address of the text to be printed
; - DE = YX position
; - rCharX / rCharY = address of XY values
; - Print a chars until we see a newline or EOL char
; - For now, EOL = 255, newline = 10 (LF, aka \n)
DrawString:
  ld a, [rCharY]
  ld d, a
  ld a, [rCharX]
  ld e, a
.loop:
  ld a, [hl]
  cp 255            ; return if EOL char
  ret z
  cp 10             ; move to next line if LF char
  jr nz, .draw
  inc hl
  inc e
  call NewLine
  jr .loop
.draw:
  inc hl
  call DrawChar
  inc e             ; move to next character
  jr .loop

DrawChar:
  push af
    ; This assumes character address starts from $80 (shared
    ; address for both BG and OBJ).
    ; offset to start of ASCII table (32 = " ", 33 = "!", etc.)
    add 96
    call DrawTile
  pop af
  ret

; Draws 2-digit decimals:
; - DE = YX position
; - A = 2-digit decimals written in hex ($00 - $99)
Draw2Decimals:
  push af
  push bc
  push de
    ; temp store A
    ld c, a

    ; Print left number
    and %11110000
    swap a
    call DrawDigit

    ; Print right number
    inc e       ; X + 1
    ld a, c
    and %00001111
    call DrawDigit
  pop de
  pop bc
  pop af
  ret

; Draws a digit:
; - DE = YX position
; - A = digit (0 - 9)
DrawDigit:
  push af
    add 144         ; offset to start of "0" digit
    call DrawTile
  pop af
  ret

; Draws character at position DE (YX-position):
; - A = tile index
; - DE = YX position
DrawTile:
  ; get index offset (XY from tilemap start address $9800)
  ; print char
  push hl
  push de
    push af
      xor a
      rr d                ; -YYYYYYY
      rra                 ;          Y-------
      rr d                ; --YYYYYY
      rra                 ;          YY------
      rr d                ; ---YYYYY
      rra                 ;          YYY-----
      or e                ;          YYYXXXXX
      ld e, a       ; DE =  ---YYYYY YYYXXXXX
      ld hl, $9800
      add hl, de          ; $9800 + DE (offset of char tile)
    pop af

    push af
      call LCDWait
      ld [hl], a          ; assign tile index to tilemap XY position
    pop af
  pop de
  pop hl
  ret

; Note: Don't forget to wait for VBlank before clearing tiles,
; otherwise some tiles will not be updated at read-only intervals.
;
; Use to clear BG layer, e.g. when transitioning between screens
; TODO: It is heavy to clear the entire BG map, consider only clearing
; the tiles within the viewport.
ClearTiles:
  push af
  push bc
  push de
  push hl
    ld a, 32
    ld b, a
    ld c, a
    ld d, a
    ld hl, $9800
    xor a
.loop:
    ld [hli], a
    dec c
    jr nz, .loop
    ld c, d ; reset C
    dec b
    jr nz, .loop
  pop hl
  pop de
  pop bc
  pop af
  ret

; Moves DrawString cursor to next line
; - Increments D (Y-pos)
; - Resets E (X-pos) to original rCharX position
NewLine:
  push af
    inc d
    ld a, [rCharX]
    ld e, a
  pop af
  ret

; Wait until LCD is safe to draw on
LCDWait:
  push af
.loop:
    ld a, [rSTAT]     ; check LCD status
    and %00000010
    jr nz, .loop
  pop af
  ret

; Set sprite in the OAM
; - A = Sprite number (0 to 39)
; - BC = X,Y
; - E = Tile index from VRAM
; - H = Palette, etc
; - Note: On GB, XY needs to be 8,16 to get top-left corner of screen (?)
SetSprite:
  push af
    ; rotate A left, copy bit-7 to Carry and bit-0
    rlca                  ; 4 bytes per sprite
    rlca
    push hl
    push de
      push hl
        ld hl, rRAM_OAM   ; Cache to be copied via DMA
        ld l, a           ; address for selected sprite
        ld a, c           ; Y
        ldi [hl], a
        ld a, b           ; X
        ldi [hl], a
        ld a, e           ; tile
        ldi [hl], a
      pop hl
      ld a, d             ; attributes
      ldi [hl], a
    pop de
    pop hl
  pop af
  ret