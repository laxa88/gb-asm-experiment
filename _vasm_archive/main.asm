    ; Note: INDENTATION IS IMPORTANT for macros
    ; Fake LDIR: copy BC bytes from origin HL to destination DE
    ; e.g. if HL = 1000, DE = 2000, BC = 3
    ; then 1000 copies to 2000, 1001 copies to 2001, 1003 copies to 2003.
    macro z_ldir
    push af
    \@Ldirb:
        ldi a, (hl)
        ld (de), a
        inc de
        dec bc
        ld a, b
        or c
        jr nz, \@Ldirb
    pop af
    endm



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Input demo

    org &0000       ; RST 0-7

    org &0040       ; Interrupt: Vblank
        jp VblankInterruptHandler
        ; reti
    org &0048       ; Interrupt: LCD-Stat
        reti
    org &0050       ; Interrupt: Timer
        jp TimerInterrupt
    org &0058       ; Interrupt: Serial
        reti
    org &0060       ; Interrupt: Joypad
        reti

; Jump to game code

    org &0100
    jp begin

; Header info

    org &0134
	db "LWY GAME"
    org &0150



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start of code (setup)
; 0150

begin:
    nop                 ; No-op for safety!
    di                  ; disable interrupt
    ld sp, &ffff        ; set the stack pointer to highest mem location + 1

; Copy vblank interrupt handler to &ff80

    ; xor a
    ; ld (DMACopy), a
    ld bc, DMACopyEnd - DMACopy     ; length of code
    ld hl, DMACopy                  ; origin
    ld de, VBlankInterruptHandler   ; destination (ff80)
    z_ldir

; Init screen X/Y scroll

    xor a
    ld hl, &FF42
    ldi (hl), a         ; FF42, SCY - Tile Scroll Y
    ld (hl), a          ; FF43, SCX - Tile Scroll X

; Turn off screen

StopLCD_wait:               ; Turn off screen so we can define our patterns
    ld a, (&FF44)           ; Loop until we are in VBlank
    cp 145                  ; Is display on scan line 145 yet?
    jr nz, StopLCD_wait     ; no? keep waiting
    ld hl, &FF40            ; LCDC - LCD Control (R/W)
    res 7, (hl)             ; Turn off screen

; Define bitmap in VRAM

    ; Tile data begins from &8000 (by default, the original nintendo logo)
    ; We offset the starting tile to &8800 for clearer separation between spritesheets
    ld de, 128 * 16 + &8000
    ld hl, SpriteData
    ld bc, SpriteDataEnd - SpriteData
    call DefineTiles

; (Optional) Clear OAM cache data (this is used for copying into DMA)

    xor a
    ld (GBSpriteCache), a
    ld hl, GBSpriteCache
    ld de, GBSpriteCache + 1
    ld bc, &a0 - 1              ; 159 loops (160 times)
    z_ldir

; Define palette

    ld a, %00011011     ; DDCCBBAA .... A=Background 3=Black, =White
    ld hl, &FF47
    ldi (hl), a         ; FF47, bg & window palette
    ldi (hl), a         ; FF48, object palette 0
    cpl                 ; invert a
    ldi (hl), a         ; FF49, object palette 1

; Turn on screen and set other flags

    ld hl, &FF40        ; LCDC - LCD Control (R/W) EWwBbOoC
    set 7, (hl)         ; Turn on screen
    set 1, (hl)         ; Turn on Sprites



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Game init code

    ; draw 6x6 tile image
    ld bc, &0101            ; X,Y position
    ld hl, &0606            ; W/H (tile count)
    ld e, &80               ; starting tile number
    call FillAreaWithTiles  ; fill grid area with consecutive tiles

; Note:
; - $c000 - $cfff = WRAM bank 0
; - $d000 - $dfff = WRAM bank 1 (switchable)
; Each sprite is 4 bytes
; We can store up to 40 sprites
; Thus, 40 * 4 = 160 sequential bytes are available
;
; We can only mark 1 byte of data (hence any value between $c0 to $cf)
; as the "starting point" of writing WRAM to VRAM during DMA, and the
; 2nd byte defaults to $00.
;
; Here, we set arbitrary WRAMBank0 starting position at $c100
; WRAM0Sprite equ &c100

    ; top-left sprite
    ld bc, &5830    ; xy
    ld e, &19       ; tile index
    ld h, 0         ; tile details (palette, etc.)
    ld a, 0         ; sprite tile
    call SetHardwareSprite      ; top-left sprite
    ld a, 8
    add b
    ld b, a
    ; inc e
    ld a, 1
    call SetHardwareSprite      ; top-right sprite
    ld a, 8
    add c
    ld c, a
    ; inc e
    ; inc e
    ld a, 2
    call SetHardwareSprite      ; bottom-left sprite
    ld a, -8
    add b
    ld b, a
    ; dec e
    ld a, 3
    call SetHardwareSprite      ; bottom-right sprite

    ld a, %00000101   ; turn on interrupts
    ld (&ffff), a
    ei

    ; init xy pos of sprite 1
    ld a, &58
    ld (Sprite1X), a
    ld a, &30
    ld (Sprite1Y), a

    ; init timer
    ld a, 0
    ld (&ff06), a       ; Reset timer by this much every clock
    ld a, %00000111     ; 00, 11, 10, 01 (slowest to fastest)
    ld (&ff07), a       ; Timer control, b2 = start timer, b0/1 = clock speed



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main game loop

; Sound ref: https://www.chibiakumas.com/z80/platform3.php#LessonP21

; Channel 1 - Tone and sweep
SOUND_CH1_TON equ &ff10
SOUND_CH1_LEN equ &ff11
SOUND_CH1_ENV equ &ff12
SOUND_CH1_FRL equ &ff13
SOUND_CH1_FRH equ &ff14

; Channel 2 - Tone
SOUND_CH2_LEN equ &ff16
SOUND_CH2_ENV equ &ff17
SOUND_CH2_FRL equ &ff18
SOUND_CH2_FRH equ &ff19

; Channel 3 - Wave
SOUND_CH3_TOG equ &ff1a
SOUND_CH3_LEN equ &ff1b
SOUND_CH3_LVL equ &ff1c
SOUND_CH3_FRL equ &ff1d
SOUND_CH3_FRH equ &ff1e

; Channel 4 - Noise
SOUND_CH4_LEN equ &ff20
SOUND_CH4_ENV equ &ff21
SOUND_CH4_POL equ &ff22
SOUND_CH4_CON equ &ff23

; Sound control
SOUND_VOLUME equ &ff24          ; -LLL-RRR (7 = loudest)
SOUND_MIXER equ &ff25           ; LLLLRRRR (sound channel 4321 L, 4321 R)
SOUND_TOGGLE equ &ff26

; Wave (channel 3) data
SOUND_WAV_START equ &ff30       ; ff30 ~ ff3f (32 4-bit wave patterns)
SOUND_WAV_END equ &ff3f

; Sound logic

    ld a, %01110111
    ld (SOUND_VOLUME), a
    ld a, %11111111
    ld (SOUND_MIXER), a

    ; Channel 2 - Tone
    ld a, %00111111
    ld (SOUND_CH2_LEN), a
    ld a, %11111100
    ld (SOUND_CH2_ENV), a
    ld a, %11111111
    ld (SOUND_CH2_FRL), a
    ld a, %10000011
    ld (SOUND_CH2_FRH), a

    ; Channel 1 - Tone and Sweep
    ld a, %01111111
    ld (SOUND_CH1_TON), a
    ld a, %00111111
    ld (SOUND_CH1_LEN), a
    ld a, %11111100
    ld (SOUND_CH1_ENV), a
    ld a, %11111111
    ld (SOUND_CH1_FRL), a
    ld a, %10000011
    ld (SOUND_CH1_FRH), a

    ; Channel 3 - Wave
    xor a
    ld b, %11111111
    ld hl, SOUND_WAV_START
    ldi (hl), a     ; 1
    ldi (hl), a     ; 2
    ldi (hl), a     ; 3
    ldi (hl), a     ; 4
    ldi (hl), a     ; 5
    ldi (hl), a     ; 6
    ldi (hl), a     ; 7
    ld (hl), b     ; 8 (some sound)
    inc hl
    ldi (hl), a     ; 1
    ldi (hl), a     ; 2
    ldi (hl), a     ; 3
    ldi (hl), a     ; 4
    ldi (hl), a     ; 5
    ldi (hl), a     ; 6
    ldi (hl), a     ; 7
    ld (hl), b     ; 8 (some sound)

    ld a, %00100000
    ld (SOUND_CH3_LVL), a
    ld a, 0
    ld (SOUND_CH3_LEN), a
    ld a, %10000000
    ld (SOUND_CH3_TOG), a
    ld a, %11111111
    ld (SOUND_CH3_FRL), a
    ld a, %11000011
    ld (SOUND_CH3_FRH), a

    ; Channel 4 - Noise
    ld a, %00001111
    ld (SOUND_CH4_LEN), a
    ld a, %11111000
    ld (SOUND_CH4_ENV), a
    ld a, %01110111
    ld (SOUND_CH4_POL), a
    ld a, %10000000
    ld (SOUND_CH4_CON), a

.loop:

    ; Reset all input states before checking every loop
    xor a
    ld (InputState), a

    ld a, %11101111         ; directionals keys
    ld (InputState), a
    ld a, (InputState)      ; read values
    or %11110000            ; ignore upper nibbles

    call UpdateSpritePosition
    jr .loop



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functions go below. To make sure we don't accidentally
; call these functions, make sure to add a di/halt above.

GBSpriteCache equ &C000                 ; Address of sprite buffer
VBlankInterruptHandler equ &FF80        ; available address for DMA
Sprite1X equ &c999
Sprite1Y equ &c998
InputState equ &ff00                    ; 0 = R, 1 = L, 2 = U, 3 = D

UpdateSpritePosition:
    push af
    push bc
        ld a, (Sprite1Y)
        ld c, a
        ld a, (Sprite1X)
        ld b, a
        ; ld bc, &5830    ; xy
        ld e, &19       ; tile index
        ld h, 0         ; tile details (palette, etc.)
        ld a, 0         ; sprite tile
        call SetHardwareSprite
    pop bc
        ; ld a, b
        ; ld (Sprite1X), a  ; save X pos
    pop af
    ret

; updates sprite movement
TimerInterrupt:
    push bc
        ; Load XY pos
        push af
            ld a, (Sprite1X)
            ld b, a
            ld a, (Sprite1Y)
            ld c, a
        pop af

        ; Update XY pos
        push af
.checkRight
            ld a, (InputState)
            and %00000001
            cp %00000001
            jr z, .checkLeft
            inc b
.checkLeft
            ld a, (InputState)
            and %00000010
            cp %00000010
            jr z, .checkUp
            dec b
.checkUp
            ld a, (InputState)
            and %00000100
            cp %00000100
            jr z, .checkDown
            dec c
.checkDown
            ld a, (InputState)
            and %00001000
            cp %00001000
            jr z, .done
            inc c
.done
        pop af

        ; Save XY pos
        push af
            ld a, b
            ld (Sprite1X), a
            ld a, c
            ld (Sprite1Y), a
        pop af
    pop bc
    reti

; At beginning of program, this is copied to $ff80 (available address for DMA)
; Every time vblank occurs at $0040, the code will jump to $ff80, and calls this.
; It will load the hi-byte ($d0) of GBSpriteCache ($d000) into $ff46 to trigger the DMA.
; It will then wait $28 (160) cycles for the DMA to complete.
; (DMA automatically copies data from $d000 to)
DMACopy:
    push af
        ld a, GBSpriteCache/256     ; get top byte of sprite buffer starting address
        ld (&ff46), a               ; trigger DMA transfer
        ld a, &28                   ; delay for 40 loops (1 loop = 4 ms, DMA completes in 160 ms)
DMACopyWait:
        dec a
        jr nz, DMACopyWait          ; wait until DMA is complete
    pop af
    reti
DMACopyEnd:


; Set sprite
; - A = Sprite number (0 to 39)
; - BC = X,Y
; - E = Tile index from VRAM
; - H = Palette, etc
; - Note: On GB, XY needs to be 8,16 to get top-left corner of screen (?)
SetHardwareSprite:
    push af
        ; rlca = rotate A left, copy bit-7 to Carry and bit-0
        ; Remember: bit-shifting will multiply or divide by 2.
        ; Hence, shifting left twice will multiply the sprite index by 2 * 2 (4 bytes per sprite)
        ; E.g. If index is 3, then we will offset A at (3 * 2 * 2) = 12 bytes
        rlca
        rlca
        push hl
        push de
            push hl
                ld hl, GBSpriteCache    ; Cache to be copied via DMA
                ld l, a                 ; address for selected sprite
                ld a, c                 ; Y
                ldi (hl), a
                ld a, b                 ; X
                ldi (hl), a
                ld a, e                 ; tile
                ldi (hl), a
            pop hl
            ld a, d                     ; attributes
            ldi (hl), a
        pop de
        pop hl
    pop af
    ret




zIXH equ &C002  ; memory location for X + width
zIXL equ &C003  ; memory location for Y + height

; BC = X,Y
; HL = W,H
; E = current tile number
FillAreaWithTiles:
    ld a, h
    add b
    ld (zIXH), a    ; store H+B (width + x)
    ld a, l
    add c
    ld (zIXL), a    ; store L+C (height + y)
FillAreaWithTiles_Yagain:
    push bc
        call GetVDPScreenPos
FillAreaWithTiles_Xagain:
        ld a, e
        call LCDWait
        ldi (hl), a     ; load tile number into VRAM's XY position
        inc e           ; increment tile number
        inc b           ; increment X
        ld a, (zIXH)
        cp b            ; compare X with (X + width)
        jr nz, FillAreaWithTiles_Xagain
    pop bc
    inc c               ; increment Y
    ld a, (zIXL)
    cp c                ; compare Y with (Y + height)
    jr nz, FillAreaWithTiles_Yagain
    ret

DefineTiles:
    call LCDWait
    ldi a, (hl)
    ld (de), a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, DefineTiles
    ret

; Wait until VRAM is available
LCDWait:
    push af
        di
LCDWaitAgain:
        ld a, (&FF41)
        and %00000010 ; if bit 2 is 0, VRAM is available
        jr nz, LCDWaitAgain
    pop af
    ret

; Move to a memory address with BC (X,Y), stores it in HL
; - BGmap is 32 * 32 tiles.
; - BGmap viewable area (i.e. gameboy visible area) is 20 * 18 tiles.
; - Each tile is 1 byte.
GetVDPScreenPos:
    xor a
    ld h, c     ; load Ypos to h
    rr h        ; YYYYYYYY --------
    rra         ;
    rr h
    rra
    rr h
    rra
    or b        ;Add XPOS
    ld l, a
    ld a, h
    add &98     ;The tilemap starts at &9800
    ld h,a
    ret

SpriteData:
	incbin ".\RawGB.RAW"
SpriteDataEnd:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $FF80 - $FFFE = HRAM
; All memory space except HRAM is not accessible during DMA.
; Therefore, we use the HRAM for VBlank interrupts to update sprite data.

