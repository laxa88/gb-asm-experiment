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
    ; ld de, 128 * 16 + &8000
    ; ld hl, SpriteData
    ; ld bc, SpriteDataEnd-SpriteData
    ; call DefineTiles

    ld de, 128 * 16 + &8000 ; offset 128 tiles after &8000 (bg/object shared VRAM)
    ld c, 5 ; repeatedly copy SpriteData n times
    call CreateSmiley

    ld de, 256 * 16 + &8000 ; offset 256 tiles after &8000 (object VRAM)
    ld c, 3 ; repeatedly copy SpriteData n times
    call CreateSmiley

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Game code

    ld bc, &0101 ; set XY position
    call GetVDPScreenPos ; draw tile at XY pos
    call LCDWait
    ld a, 128 ; set tile 128 (smiley)
    ldi (hl), a ; draw tile at screen tile position (x=00 y=00)
    ld a, 25 ; set tile 25 (nintendo R symbol)
    ldi (hl), a ; set tile to 128

    di
    halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functions go below. To make sure we don't accidentally
; call these functions, make sure to add a halt above.

; c = loop count
CreateSmiley:
    push bc
        ld hl, SpriteData
        ld bc, SpriteDataEnd-SpriteData
        call DefineTiles
    pop bc
    dec c
    jr nz, CreateSmiley
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

LCDWait:
    push af
        di
LCDWaitAgain:
        ld a, (&FF41)
        and %00000010 ; wait until VRAM is available
        jr nz, LCDWaitAgain
    pop af
    ret

; TODO understand this
; Move to a memory address with BC... B=Xpos, C=Ypos
GetVDPScreenPos:
    xor a       ; reset a
    ld h,c      ; Ypos * 32
    rr h        ; Each line is 32 tiles
    rra         ;and each tile is 1 byte
    rr h
    rra
    rr h
    rra
    or b        ;Add XPOS
    ld l,a
    ld a,h
    add &98     ;The tilemap starts at &9800
    ld h,a
    ret

; _halt:
;     ; Do nothing, forever
;     halt
;     nop
;     jr _halt

; Smiley image in 8x8 tile
SpriteData:
; Bitplane  00000000  11111111
        DB %00111100,%00000000     ;  0
        DB %01111110,%00000000     ;  1
        DB %11111111,%00100100     ;  2
        DB %11111111,%00000000     ;  3
        DB %11111111,%00000000     ;  4
        DB %11011011,%00100100     ;  5
        DB %01100110,%00011000     ;  6
        DB %00111100,%00000000     ;  7
SpriteDataEnd: