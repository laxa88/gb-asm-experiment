; Use gbtd22 (Game Boy Tile Designer 2.2) to make custom spritesheet
; http://www.devrs.com/gb/hmgd/gbtd.html

; Using halt and interrupts to optimise CPU processing:
; https://github.com/paulobruno/LearningGbAsm/tree/master/15_Interrupts

INCLUDE "include/hardware.inc"
INCLUDE "include/util.asm"

; My tileset doesn't differentiate between small and large letters,
; so map the small letters as large letters.
CHARMAP "a", "A"
CHARMAP "b", "B"
CHARMAP "c", "C"
CHARMAP "d", "D"
CHARMAP "e", "E"
CHARMAP "f", "F"
CHARMAP "g", "G"
CHARMAP "h", "H"
CHARMAP "i", "I"
CHARMAP "j", "J"
CHARMAP "k", "K"
CHARMAP "l", "L"
CHARMAP "m", "M"
CHARMAP "n", "N"
CHARMAP "o", "O"
CHARMAP "p", "P"
CHARMAP "q", "Q"
CHARMAP "r", "R"
CHARMAP "s", "S"
CHARMAP "t", "T"
CHARMAP "u", "U"
CHARMAP "v", "V"
CHARMAP "w", "W"
CHARMAP "x", "X"
CHARMAP "y", "Y"
CHARMAP "z", "Z"

; Constants

DEF ANIM_FPS EQU $8           ; update 1 animation frame per n vblank cycles
DEF INPUT_BTN_A       EQU %00000001
DEF INPUT_BTN_B       EQU %00000010
DEF INPUT_BTN_SELECT  EQU %00000100
DEF INPUT_BTN_START   EQU %00001000
DEF INPUT_DPAD_RIGHT  EQU %00010000
DEF INPUT_DPAD_LEFT   EQU %00100000
DEF INPUT_DPAD_UP     EQU %01000000
DEF INPUT_DPAD_DOWN   EQU %10000000

SECTION "OAM RAM data", WRAM0

; These addresses will be dynamically allocated sequentially
; within appropriate section (i.e. WRAM0) when linking

rRAM_OAM: ds 4*40 ; 40 sprites * 4 bytes

; Local variables
rInputs: dw
rInputsPrev: dw
rInputsPressed: dw
rInputsReleased: dw
rCrosshairX: dw
rCrosshairY: dw
rCanUpdate: dw
rAnimCounter: dw
rMusicId: dw
rCharX: dw
rCharY: dw
rRandNum: dw

SECTION "RST 0 - 7", ROM0[$00]
  ds $40 - @, 0      ; pad zero from @ (current address) to $40 (vblank interrupt)

SECTION "VBlank interrupt", ROM0[$40]
  call VblankInterrupt

SECTION "LCD-Stat interrupt", ROM0[$48]
  reti

SECTION "Timer interrupt", ROM0[$50]
  reti

SECTION "Serial interrupt", ROM0[$58]
  reti

SECTION "Joypad interrupt", ROM0[$60]
  reti

SECTION "Header", ROM0[$100]
  nop
  jp EntryPoint

SECTION "Game title", ROM0[$134]
  db "My RGDBS game"

SECTION "Game initialization", ROM0[$150]

EntryPoint:
  nop                 ; No-op for safety!
  di                  ; disable interrupt
  ld sp, $ffff        ; set the stack pointer to highest mem location + 1

  ; Shut down audio circuitry
  xor a
  ld [rNR52], a

  ; Copy vblank interrupt handler to HRAM
  ld bc, DMACopyEnd - DMACopy     ; length of code
  ld hl, DMACopy                  ; origin
  ld de, _HRAM                    ; destination (ff80)
  z_ldir

  ; clear OAM cache data
  xor a
  ld [rRAM_OAM], a
  ld hl, rRAM_OAM
  ld de, rRAM_OAM + 1
  ld bc, $a0 - 1      ; 159 loops (160 times)
  z_ldir

  ; Do not turn the LCD off outside of VBlank
WaitVBlank:
  ld a, [rLY]
  cp 144
  jp c, WaitVBlank

  ; Turn the LCD off
  xor a
  ld [rLCDC], a

  ; Copy the tile data
  ld de, Tiles
  ld hl, $9000
  ld bc, TilesEnd - Tiles
  call CopyTiles

  ld de, MySpriteSheet
  ld hl, $8800
  ld bc, MySpriteSheetEnd - MySpriteSheet
  call CopyTiles

  ; Copy the tilemap
  ld de, Tilemap
  ld hl, $9800
  ld bc, TilemapEnd - Tilemap
  call CopyTilemap

  ; Turn the LCD on
  ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_BG8800
  ld [rLCDC], a

  ; During the first (blank) frame, initialize display registers
  ld a, %11100100
  ld [rBGP], a    ; bg palette
  ld [rOBP0], a   ; obj 0 palette
  cpl ; invert a
  ld [rOBP1], a   ; obj 1 palette (usually inverted of obj 0)

  ; Init timer
  ld a, 0                         ; Reset timer by this much every clock
  ld [rTMA], a
  ld a, TACF_16KHZ | TACF_START   ; 00, 11, 10, 01 (slowest to fastest)
  ld [rTAC], a                    ; Timer control, b2 = start timer, b0/1 = clock speed

  ; Enable interrupts
  xor a
  ld [rIF], a
  ld a, IEF_VBLANK | IEF_TIMER
  ld [rIE], a
  ei

  ; Init variables
  xor a
  ld [rAnimCounter], a
  ld [rMusicId], a

  ; Init crosshair image position
  ld a, $58
  ld [rCrosshairX], a
  ld a, $30
  ld [rCrosshairY], a

  ; Print hello world only once
  xor a
  ld [rRandNum], a
  ld [rCharX], a
  ld [rCharY], a
  ld hl, Message
  call DrawString

  ; Init sound
  ld a, AUDENA_ON     ; enable sounds
  ld [rAUDENA], a
  ld a, $FF           ; turn on all speakers (stereo)
  ld [rAUDTERM], a
  ld a, %00000000     ; 0111 0111 (max volume for SO2 and SO1)
  ld [rAUDVOL], a

  ; Init music
  ld hl, quasar
  call hUGE_init

Loop:
  halt                ; pause game (conserves CPU power) until next interrupt
  ld a, [rCanUpdate]
  cp 1
  jr nz, Loop         ; if interrupt was not vblank (resets rCanUpdate), jump back up and halt
  xor a
  ld [rCanUpdate], a

  call UpdateRandomNumber
  call DrawRandNumber
  call PlayMusic
  call ReadInput
  call SwitchMusic
  call ReadRandomNumber
  call PlaySFX
  call MoveCrosshair
  call DrawCrosshair

  jp Loop

SECTION "Global functions", ROM0

VblankInterrupt:
  push af
    ld a, 1
    ld [rCanUpdate], a

    ld a, [rAnimCounter]
    or a
    jr z, .skip
    dec a
    ld [rAnimCounter], a
.skip
  pop af
  jp _HRAM ; DMA function, ends with reti

UpdateRandomNumber:
  ; There is no "random" number in ASM, so we "generate"
  ; a pseudo-random number by incrementing rRandNum every
  ; update. The randomness comes from "when" the player
  ; reads this value.
  push af
    ld a, [rRandNum]
    inc a
    daa   ; converts hex to decimal, e.g. $1a becomes $26
    ld [rRandNum], a
  pop af
  reti

; Draws a string of text:
; - HL = address of the text to be printed
; - rCharX / rCharY = address of XY values
; - Print a chars until we see a newline or EOL char
; - For now, EOL = 255, newline = ???
DrawString:
  ld a, [hl]
  cp 255
  ret z           ; return if found EOL char
  inc hl
  call DrawChar
  jr DrawString

; Draws character at position rCharX / rCharY:
; - A = value of string's char at current [HL] address
DrawChar:
  ; get index offset (XY from tilemap start address $9800)
  ; print char
  push hl
  push bc
    push af
      ld a, [rCharY]
      ld b, a             ; YYYYYYYY --------
      ld a, [rCharX]
      ld c, a             ; -------- XXXXXXXX
      ld hl, rCharX
      inc [hl]
      cp 20-1             ; screen width is 20 tiles
      call z, NewLine     ; move to newline if X-tile is over 20 tiles
      ; move B right and into Carry
      ; move Carry right to A
      xor a
      rr b                ; -YYYYYYY
      rra                 ;          Y-------
      rr b                ; --YYYYYY
      rra                 ;          YY------
      rr b                ; ---YYYYY
      rra                 ;          YYY-----
      or c                ;          YYYXXXXX
      ld c, a       ; BC =  ---YYYYY YYYXXXXX
      ld hl, $9800
      add hl, bc          ; $9800 + BC (offset of char tile)
    pop af

    push af
      add 96              ; offset (refer to VRAM for tile position)
      call LCDWait
      ld [hl], a          ; assign tile index to tilemap XY position
    pop af
  pop bc
  pop hl
  ret

; Draws 2-digit decimals:
; - DE = YX position
; - A = 2-digit decimals ($00 - $99)
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

; Draw digit:
; - DE = XY position
; - A = decimal digit to print (0 to 9)
DrawDigit:
  push hl
  push de
    push af
      ; Get tilemap position ($9800 = tilemap 0)
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
      add hl, de
    pop af

    push af
      add 144           ; Offset to "0" digit image
      call LCDWait
      ld [hl], a        ; assign tile index to tilemap XY position
    pop af
  pop de
  pop hl
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

NewLine:
  push hl
    ld hl, rCharY ; Move to next tile row
    inc [hl]
    ld hl, rCharX ; Reset tile column
    ld [hl], 0
  pop hl
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

ReadRandomNumber:
  push af
    ld a, [rInputsPressed]
    and INPUT_BTN_START
    jp z, .end

    ld a, [rRandNum]
    ld d, 17              ; Y tile pos
    ld e, 3               ; X tile pos
    call Draw2Decimals
.end
  pop af
  ret

SwitchMusic:
  push af
    ld a, [rInputsPressed]
    and INPUT_BTN_B
    jp z, .end

    ; Check BGM toggle
    ld a, [rMusicId]
    cp 1
    jr z, .toggleQuasar
    cp 0
    jr z, .togglePkmn
    jp .end
.togglePkmn:
    ld hl, pokemon_center
    call hUGE_init
    ld a, 1
    ld [rMusicId], a
    jp .end
.toggleQuasar:
    ld hl, quasar
    call hUGE_init
    ld a, 0
    ld [rMusicId], a
.end:
  pop af
  ret

PlaySFX:
  push af
    ld a, [rInputsPressed]
    and INPUT_BTN_A
    jp z, .skip

    ; play sound
    ld a, $15
    ld [rNR10], a
    ld a, $96
    ld [rNR11], a
    ld a, $73
    ld [rNR12], a
    ld a, $BB
    ld [rNR13], a
    ld a, $85
    ld [rNR14], a
.skip:
  pop af
  ret

MoveCrosshair:
  push bc
    ; Load XY pos
    push af
      ld a, [rCrosshairX]
      ld b, a
      ld a, [rCrosshairY]
      ld c, a
    pop af

    ; Update XY pos
    push af
.checkRight
      ld a, [rInputs]
      and INPUT_DPAD_RIGHT
      jr z, .checkLeft
      inc b
.checkLeft
      ld a, [rInputs]
      and INPUT_DPAD_LEFT
      jr z, .checkUp
      dec b
.checkUp
      ld a, [rInputs]
      and INPUT_DPAD_UP
      jr z, .checkDown
      dec c
.checkDown
      ld a, [rInputs]
      and INPUT_DPAD_DOWN
      jr z, .done
      inc c
.done
    pop af
    ; Save XY pos
    push af
      ld a, b
      ld [rCrosshairX], a
      ld a, c
      ld [rCrosshairY], a
    pop af
  pop bc
  ret

DrawCrosshair:
  push af
  push bc
    ld a, [rCrosshairX]
    ld b, a
    ld a, [rCrosshairY]
    ld c, a
    push bc
      ld e, $fc       ; tile index
      ld h, 0         ; tile details (palette, etc.)
      ld a, 0         ; OBJ 0
      call SetSprite  ; top left
    pop bc
    push bc
      ld a, b
      add 8
      ld b, a
      ld e, $fe
      ld a, 1         ; OBJ 1
      call SetSprite  ; top right
    pop bc
    push bc
      ld a, c
      add 8
      ld c, a
      ld e, $fd
      ld a, 2         ; OBJ 2
      call SetSprite  ; bottom left
    pop bc
    push bc
      ld a, b
      add 8
      ld b, a
      ld a, c
      add 8
      ld c, a
      ld e, $ff
      ld a, 3         ; OBJ 2
      call SetSprite  ; bottom left
    pop bc
  pop bc
  pop af
  ret

DrawRandNumber:
  ld a, [rRandNum]      ; 0 ~ 99
  ld d, 17              ; Y tile pos
  ld e, 0               ; X tile pos
  call Draw2Decimals
  ret

PlayMusic:
  push af
  push hl
  push bc
  push de
    call hUGE_dosound
  pop de
  pop bc
  pop hl
  pop af
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

CopyTiles:
  ld a, [de]
  ld [hli], a
  inc de
  dec bc
  ld a, b
  or a, c
  jp nz, CopyTiles
  ret

CopyTilemap:
  ld a, [de]
  ld [hli], a
  inc de
  dec bc
  ld a, b
  or a, c
  jp nz, CopyTilemap
  ret

; Set sprite
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

SECTION "Binary data", ROM0

Tiles:
  db $00,$ff, $00,$ff, $00,$ff, $00,$ff, $00,$ff, $00,$ff, $00,$ff, $00,$ff
  db $00,$ff, $00,$80, $00,$80, $00,$80, $00,$80, $00,$80, $00,$80, $00,$80
  db $00,$ff, $00,$7e, $00,$7e, $00,$7e, $00,$7e, $00,$7e, $00,$7e, $00,$7e
  db $00,$ff, $00,$01, $00,$01, $00,$01, $00,$01, $00,$01, $00,$01, $00,$01
  db $00,$ff, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00
  db $00,$ff, $00,$7f, $00,$7f, $00,$7f, $00,$7f, $00,$7f, $00,$7f, $00,$7f
  db $00,$ff, $03,$fc, $00,$f8, $00,$f0, $00,$e0, $20,$c0, $00,$c0, $40,$80
  db $00,$ff, $c0,$3f, $00,$1f, $00,$0f, $00,$07, $04,$03, $00,$03, $02,$01
  db $00,$80, $00,$80, $7f,$80, $00,$80, $00,$80, $7f,$80, $7f,$80, $00,$80
  db $00,$7e, $2a,$7e, $d5,$7e, $2a,$7e, $54,$7e, $ff,$00, $ff,$00, $00,$00
  db $00,$01, $00,$01, $ff,$01, $00,$01, $01,$01, $fe,$01, $ff,$01, $00,$01
  db $00,$80, $80,$80, $7f,$80, $80,$80, $00,$80, $ff,$80, $7f,$80, $80,$80
  db $00,$7f, $2a,$7f, $d5,$7f, $2a,$7f, $55,$7f, $ff,$00, $ff,$00, $00,$00
  db $00,$ff, $aa,$ff, $55,$ff, $aa,$ff, $55,$ff, $fa,$07, $fd,$07, $02,$07
  db $00,$7f, $2a,$7f, $d5,$7f, $2a,$7f, $55,$7f, $aa,$7f, $d5,$7f, $2a,$7f
  db $00,$ff, $80,$ff, $00,$ff, $80,$ff, $00,$ff, $80,$ff, $00,$ff, $80,$ff
  db $40,$80, $00,$80, $7f,$80, $00,$80, $00,$80, $7f,$80, $7f,$80, $00,$80
  db $00,$3c, $02,$7e, $85,$7e, $0a,$7e, $14,$7e, $ab,$7e, $95,$7e, $2a,$7e
  db $02,$01, $00,$01, $ff,$01, $00,$01, $01,$01, $fe,$01, $ff,$01, $00,$01
  db $00,$ff, $80,$ff, $50,$ff, $a8,$ff, $50,$ff, $a8,$ff, $54,$ff, $a8,$ff
  db $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80
  db $ff,$00, $ff,$00, $ff,$00, $ab,$7e, $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e
  db $ff,$01, $fe,$01, $ff,$01, $fe,$01, $ff,$01, $fe,$01, $ff,$01, $fe,$01
  db $7f,$80, $ff,$80, $7f,$80, $ff,$80, $7f,$80, $ff,$80, $7f,$80, $ff,$80
  db $ff,$00, $ff,$00, $ff,$00, $aa,$7f, $d5,$7f, $aa,$7f, $d5,$7f, $aa,$7f
  db $f8,$07, $f8,$07, $f8,$07, $80,$ff, $00,$ff, $aa,$ff, $55,$ff, $aa,$ff
  db $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $ff,$80, $7f,$80, $ff,$80
  db $d5,$7f, $aa,$7f, $d5,$7f, $aa,$7f, $d5,$7f, $aa,$7f, $d5,$7f, $aa,$7f
  db $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e, $d5,$7e, $eb,$3c
  db $54,$ff, $aa,$ff, $54,$ff, $aa,$ff, $54,$ff, $aa,$ff, $54,$ff, $aa,$ff
  db $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $00,$ff
  db $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e, $d5,$7e, $2a,$ff
  db $ff,$01, $fe,$01, $ff,$01, $fe,$01, $ff,$01, $fe,$01, $ff,$01, $80,$ff
  db $7f,$80, $ff,$80, $7f,$80, $ff,$80, $7f,$80, $ff,$80, $7f,$80, $aa,$ff
  db $ff,$00, $ff,$00, $ff,$00, $ff,$00, $ff,$00, $ff,$00, $ff,$00, $2a,$ff
  db $ff,$01, $fe,$01, $ff,$01, $fe,$01, $fe,$01, $fe,$01, $fe,$01, $80,$ff
  db $7f,$80, $ff,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $00,$ff
  db $fe,$01, $fe,$01, $fe,$01, $fe,$01, $fe,$01, $fe,$01, $fe,$01, $80,$ff
  db $3f,$c0, $3f,$c0, $3f,$c0, $1f,$e0, $1f,$e0, $0f,$f0, $03,$fc, $00,$ff
  db $fd,$03, $fc,$03, $fd,$03, $f8,$07, $f9,$07, $f0,$0f, $c1,$3f, $82,$ff
  db $55,$ff, $2a,$7e, $54,$7e, $2a,$7e, $54,$7e, $2a,$7e, $54,$7e, $00,$7e
  db $01,$ff, $00,$01, $01,$01, $00,$01, $01,$01, $00,$01, $01,$01, $00,$01
  db $54,$ff, $ae,$f8, $50,$f0, $a0,$e0, $60,$c0, $80,$c0, $40,$80, $40,$80
  db $55,$ff, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00
  db $55,$ff, $6a,$1f, $05,$0f, $02,$07, $05,$07, $02,$03, $03,$01, $02,$01
  db $54,$ff, $80,$80, $00,$80, $80,$80, $00,$80, $80,$80, $00,$80, $00,$80
  db $55,$ff, $2a,$1f, $0d,$07, $06,$03, $01,$03, $02,$01, $01,$01, $00,$01
  db $55,$ff, $2a,$7f, $55,$7f, $2a,$7f, $55,$7f, $2a,$7f, $55,$7f, $00,$7f
  db $55,$ff, $aa,$ff, $55,$ff, $aa,$ff, $55,$ff, $aa,$ff, $55,$ff, $00,$ff
  db $15,$ff, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00
  db $55,$ff, $6a,$1f, $0d,$07, $06,$03, $01,$03, $02,$01, $03,$01, $00,$01
  db $54,$ff, $a8,$ff, $54,$ff, $a8,$ff, $50,$ff, $a0,$ff, $40,$ff, $00,$ff
  db $00,$7e, $2a,$7e, $d5,$7e, $2a,$7e, $54,$7e, $ab,$76, $dd,$66, $22,$66
  db $00,$7c, $2a,$7e, $d5,$7e, $2a,$7e, $54,$7c, $ff,$00, $ff,$00, $00,$00
  db $00,$01, $00,$01, $ff,$01, $02,$01, $07,$01, $fe,$03, $fd,$07, $0a,$0f
  db $00,$7c, $2a,$7e, $d5,$7e, $2a,$7e, $54,$7e, $ab,$7e, $d5,$7e, $2a,$7e
  db $00,$ff, $a0,$ff, $50,$ff, $a8,$ff, $54,$ff, $a8,$ff, $54,$ff, $aa,$ff
  db $dd,$62, $bf,$42, $fd,$42, $bf,$40, $ff,$00, $ff,$00, $f7,$08, $ef,$18
  db $ff,$00, $ff,$00, $ff,$00, $ab,$7c, $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e
  db $f9,$07, $fc,$03, $fd,$03, $fe,$01, $ff,$01, $fe,$01, $ff,$01, $fe,$01
  db $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7c
  db $f7,$18, $eb,$1c, $d7,$3c, $eb,$3c, $d5,$3e, $ab,$7e, $d5,$7e, $2a,$ff
  db $ff,$01, $fe,$01, $ff,$01, $fe,$01, $ff,$01, $fe,$01, $ff,$01, $a2,$ff
  db $7f,$c0, $bf,$c0, $7f,$c0, $bf,$e0, $5f,$e0, $af,$f0, $57,$fc, $aa,$ff
  db $ff,$01, $fc,$03, $fd,$03, $fc,$03, $f9,$07, $f0,$0f, $c1,$3f, $82,$ff
  db $55,$ff, $2a,$ff, $55,$ff, $2a,$ff, $55,$ff, $2a,$ff, $55,$ff, $00,$ff
  db $45,$ff, $a2,$ff, $41,$ff, $82,$ff, $41,$ff, $80,$ff, $01,$ff, $00,$ff
  db $54,$ff, $aa,$ff, $54,$ff, $aa,$ff, $54,$ff, $aa,$ff, $54,$ff, $00,$ff
  db $15,$ff, $2a,$ff, $15,$ff, $0a,$ff, $15,$ff, $0a,$ff, $01,$ff, $00,$ff
  db $01,$ff, $80,$ff, $01,$ff, $80,$ff, $01,$ff, $80,$ff, $01,$ff, $00,$ff
TilesEnd:

SECTION "Tilemap", ROM0

Tilemap:
  db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $01, $02, $03, $01, $04, $03, $01, $05, $00, $01, $05, $00, $06, $04, $07, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $08, $09, $0a, $0b, $0c, $0d, $0b, $0e, $0f, $08, $0e, $0f, $10, $11, $12, $13, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $14, $15, $16, $17, $18, $19, $1a, $1b, $0f, $14, $1b, $0f, $14, $1c, $16, $1d, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $1e, $1f, $20, $21, $22, $23, $24, $22, $25, $1e, $22, $25, $26, $22, $27, $1d, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $01, $28, $29, $2a, $2b, $2c, $2d, $2b, $2e, $2d, $2f, $30, $2d, $31, $32, $33, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $08, $34, $0a, $0b, $11, $0a, $0b, $35, $36, $0b, $0e, $0f, $08, $37, $0a, $38, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $14, $39, $16, $17, $1c, $16, $17, $3a, $3b, $17, $1b, $0f, $14, $3c, $16, $1d, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $1e, $3d, $3e, $3f, $22, $27, $21, $1f, $20, $21, $22, $25, $1e, $22, $40, $1d, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $00, $41, $42, $43, $44, $30, $33, $41, $45, $43, $41, $30, $43, $41, $30, $33, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
  db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
TilemapEnd:

MySpriteSheet:
  incbin "./resource/sprite-sheet.bin"
MySpriteSheetEnd:

Message: db "Hello world 123!", 255
