;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Header
; Reference: https://assemblydigest.tumblr.com/post/77198211186/tutorial-making-an-empty-game-boy-rom-in-rgbds

    org &0000       ; RST 0-7

    org &0040       ; Interrupt: Vblank
        reti
    org &0048       ; Interrupt: LCD-Stat
        reti
    org &0050       ; Interrupt: Timer
        reti
    org &0058       ; Interrupt: Serial
        reti
    org &0060       ; Interrupt: Joypad
        reti

sstart:
    org &0100
    jp begin

    ; 0104-0133	Nintendo logo (must match rom logo)
    ; Let the rgbfix.exe patch the logo data here automatically
    org &0134

    ; 0134 - 013E Game title (upper cased)
    ; 013F - 0142 Manufacturer code, or alternatively, more of game title
	db "LWY GAME"

    ; Let rgbfix pad everything up til here
    org &0150

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start of code
; 0150

begin:
    nop                 ; No-op for safety!
    di                  ; disable interrupt
    ld sp, &ffff        ; set the stack pointer to highest mem location + 1

    xor a
    ld hl, &FF42
    ldi (hl), a
    ld (hl), a

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Turn off screen

StopLCD_wait:               ; Turn off screen so we can define our patterns
    ld a, (&FF44)           ; Loop until we are in VBlank
    cp 145                  ; Is display on scan line 145 yet?
    jr nz, StopLCD_wait     ; no? keep waiting
    ld hl, &FF40            ; LCDC - LCD Control (R/W)
    res 7, (hl)             ; Turn off screen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main program / Initial setup

; Define bitmap

    ; Tile data begins from &8000 (by default, the original nintendo logo)
    ; We offset the starting tile to &8800 for clearer separation between spritesheets
    ld de, 128 * 16 + &8000
    ld hl, SpriteData
    ld bc, SpriteDataEnd - SpriteData
    call DefineTiles

; Define palette

    ld a, %00011011 ; DDCCBBAA .... A=Background 3=Black, =White
    ld hl, &FF47
    ldi (hl), a ; FF47, bg & window palette
    ldi (hl), a ; FF48, object palette 0
    cpl ; invert a
    ldi (hl), a ; FF49, object palette 1

; Turn on screen

    ld hl, &FF40    ; LCDC - LCD Control (R/W) EWwBbOoC
    set 7, (hl)      ; Turn on screen

; Game code
; https://www.chibiakumas.com/z80/simplesamples.php#LessonS9

zIXH equ &C002  ; memory location for X + width
zIXL equ &C003  ; memory location for Y + height

    ld bc, &0101            ; X,Y position
    ld hl, &0606            ; W/H (tile count)
    ld e, 128               ; starting tile number
    call FillAreaWithTiles  ; fill grid area with consecutive tiles

    di
    halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functions go below. To make sure we don't accidentally
; call these functions, make sure to add a halt above.

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
    rr h        ; ----YYYY
    rra         ;          Y-------
    rr h        ; -----YYY
    rra         ;          YY------
    rr h        ; ------YY
    rra         ;          YYY-----
    ; add x-pos
    or b        ;          YYYXXXXX
    ld l, a     ; ------YY YYYXXXXX (HL)
    ld a, h     ;
    ; The tilemap starts at &9800
    add &98     ; 100110YY YYYXXXXX (10011000 + H)
    ld h, a
    ret

SpriteData:
	incbin ".\RawGB.RAW"
SpriteDataEnd: