NextCharX equ &C000
NextCharY equ &C001

; Don't forget to set BGB emu system to GBC for sprite to render correctly
; BuildGBC equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Notes
;
; - File size has to be at least 336 ($150) bytes, otherwise bgb won't run.
; This means a .gb compiled from basic .asm file with only headers will not run.
;
; - use bgb emulator for accuracy (with logo checksum)
; - use sameboy or something else for (quicker) game debugging.

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

                    ; 0068 - 00FF Free space

sstart:
    org &0100
    nop             ; 0100 - 0103 Entry point (start of program)
    jp begin

    ; 0104-0133	Nintendo logo (must match rom logo)
	db &CE,&ED,&66,&66,&CC,&0D,&00,&0B,&03,&73,&00,&83,&00,&0C,&00,&0D
	db &00,&08,&11,&1F,&88,&89,&00,&0E,&DC,&CC,&6E,&E6,&DD,&DD,&D9,&99
	db &BB,&BB,&67,&63,&6E,&0E,&EC,&CC,&DD,&DC,&99,&9F,&BB,&B9,&33,&3E

    ; 0134 - 013E Game title (upper cased)
    ; 013F - 0142 Manufacturer code, or alternatively, more of game title
	db "LWY GAME"
    org &0143

    ; 0143 Gameboy compatibility flag
    ;db &C0 ; GBC only flag
    ;db &80 ; GBC + GB flag
    ;db &00 ; GB flag
    ifdef BuildGBC
        db &80
    else
        db &00
    endif

    db 0,0      ;0144-0145	Two-character Game Manufacturer code / Licensee code
	db 0        ;0146		Super GameBoy flag (&00=normal, &03=SGB)
	db 2        ;0147		Cartridge type (special upgrade hardware)
	db 2        ;0148		Rom size (0=32k, 1=64k,2=128k etc)
	db 3        ;0149		Cart Ram size (0=none,1=2k 2=8k, 3=32k)
	db 1        ;014A		Destination Code (0=JPN 1=EU/US)
	db &33      ;014B		Old Licensee code (must be &33 for SGB)
	db 0        ;014C		Rom Version Number (usually 0)
	db 0        ;014D		Header Checksum - ‘ones complement' checksum of bytes 0134-014C… (not needed for emulators)
	dw 0        ;014E-014F	Global Checksum – 16 bit sum of all rom bytes (except 014E-014F)… unused by gameboy

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start of code

;0150
begin:
    nop                 ; No-op for safety!
    di                  ; disable interrupt
    ld sp, &ffff        ; set the stack pointer to highest mem location + 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Position tilemap

    xor a
    ld hl, &FF42
    ldi (hl), a         ; FF42, SCY - Tile Scroll Y
    ld  (hl), a         ; FF43, SCX - Tile Scroll X

    ld (NextCharX), a   ; Set cursor tile position
    ld (NextCharY), a

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Turn off screen

StopLCD_wait:               ; Turn off screen so we can define our patterns
    ld a, (&FF44)           ; Loop until we are in VBlank
    cp 145                  ; Is display on scan line 145 yet?
    jr nz, StopLCD_wait     ; no? keep waiting
    ld hl, &FF40            ; LCDC - LCD Control (R/W)
    res 7, (hl)             ; Turn off screen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Define bitmap font

    ld de, BitmapFont                   ; Source bitmaps
    ; offset by 128 tiles (16 bytes per tile) so we don't overwrite the GB logo
    ld hl, 128 * 16 + &8000             ; Destination of Vram
    ld bc, BitmapFontEnd-BitmapFont     ; Bytes of font

Copy2Bitloop:
    ld a, (de)      ; Read in a byte and INC HL
    inc de
    ldi (hl), a     ; Fill Bitplane 1
    ldi (hl), a     ; Fill Bitplane 2
    dec bc
    ld a, b
    or c
    jr nz, Copy2Bitloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Define palette

    ifdef BuildGBC
        ld c, 0*8           ;palette no 0 (back)
        call SetGBCPalettes

        ld c, 7*8            ;palette no 7 (used by font)
        call SetGBCPalettes
    else
        ; For GB palette
        ld a, %00011011     ; DDCCBBAA ... A = bg, 0 = black, 3 = white
        ld hl, &FF47
        ldi (hl), a         ; FF47      BGP     BG & Window Palette Data (R/W) = &FC
        ldi (hl), a         ; FF48      0BP0    Sprite Palette 0 Data (R/W) = &FF
        cpl                 ; Set sprite Palette 2 to opposite
        ldi (hl), a         ; FF49      0BP1    Sprite Palette 1 Data (R/W) = &FF
    endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Turn on screen

    ld hl, &FF40    ; LCDC - LCD Control (R/W) EWwBbOoC
    set 7,(hl)      ; Turn on screen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main program

    ld hl, Message          ; Address of string
    call PrintString        ; Show string to screen

    di
    halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print

PrintString:
    ld a, (hl)      ; Print a '255' terminated string
    cp 255
    ret z
    inc hl
    call PrintChar
    jr PrintString

Message: db 'Hello 123!"foo"lorem ipsum dolor sit amet lorem ipsum dolor sit amet', 255

PrintChar:
    push hl
    push bc
        push af
            ; Note: only the first 5 bits matter (5 bits = 32 tiles)
            ; The BGMap can only store 32x32 tiles anyway, so if it's any larger
            ; it would go out of bounds (possibly error here)
            ld a, (NextCharY)
            ld b, a             ; ---YYYYY --------
            ld hl, NextCharX
            ld a, (hl)
            ld c, a             ; -------- ---XXXXX
            inc (hl)
            cp 20-1
            call z, NewLine
            xor a               ; clear a and its carry-flag
            ; rotate Ypos bit to right, storing bit-0 to carry-flag
            ; rotate "a" bit to right, moving the carry-flag to a's bit-7
            ; do this 3 times to move Ypos bits 0,1,2 into a's bits 5,6,7
                                ; b        a
            rr b                ; ----YYYY Y-------
            rra
            rr b                ; -----YYY YY------
            rra
            rr b                ; ------YY YYY-----
            rra
            ; merge c with a to get the 2nd byte (YYYXXXXX)
            or c                ; ------YY YYYXXXXX
            ld c, a
            ld hl, &9800        ; Tilemap base
            ; the combination of BC produces ------YY YYYXXXXX
            ; which is the 10-bit tile position (32 x 32 = 1024)
            add hl, bc          ; Offset tilemap base origin with calculated XY memory location
        pop af
        push af
            ; 128 = offset to next 128 tiles, minus 32 because space charcode
            ; in ASCII is "32", but our alphabet spritesheet's space charcode is "0"
            add 128 - 32    ; no char < 32
            call LCDWait    ; Wait for VDP Sync
            ld (hl), a

            ifdef BuildGBC
                ld bc, &FF4F    ; VBK - CGB Mode Only - VRAM Bank

                ld a, 1         ; Turn on GBC extras
                ld (bc), a

                ld (hl), 7      ; Palette 7

                xor a           ; Turn off GBC extras
                ld (bc), a
			endif
            ; https://www.chibiakumas.com/z80/helloworld.php#LessonH9
        pop af
    pop bc
    pop hl
    ret

NewLine:
    push hl
        ld hl, NextCharY    ; Inc Ypos
        inc (hl)
        ld hl, NextCharX
        ld (hl), 0          ; Reset Xpos
    pop hl
    ret

LCDWait:
    push af
        di
LCDWaitAgain:
        ld a, (&FF41)       ; STAT - LCD Status (R/W)
            ;-L0VHCMM
        and %00000010       ; MM = video mode (0/1 = Vram available)
        jr nz, LCDWaitAgain
    pop af
    ret

SetGBCPalettes:
	ifdef BuildGBC
		ld hl,GBPal
SetGBCPalettesb:
		ldi a,(hl)  	;GGGRRRRR
		ld e,a
		ldi a,(hl)  	;xBBBBBGG
		ld d,a
		inc a 			;cp 255
		ret z
		push hl
			call lcdwait ;Wait for VDP Sync
			ld hl,&ff68
			ld (hl),c	;FF68 - BCPS/BGPI - CGB Mode Only - Background Palette Index
			inc hl
			ld (hl),e	;FF69 - BCPD/BGPD - CGB Mode Only - Background Palette Data
			dec hl
			inc	c		;Increase palette address
			ld (hl),c	;FF68 - BCPS/BGPI - CGB Mode Only - Background Palette Index
			inc hl
			ld (hl),d	;FF69 - BCPD/BGPD - CGB Mode Only - Background Palette Data
			inc c		;Increase palette address
		pop hl
		jr SetGBCPalettesb
	endif

;		 	xBBBBBGGGGGRRRRR
GBPal:	dw %0111110000000000	;col 0
		dw %0111111111100000	;col 1
		dw %0000000000011111	;col 2
		dw %0000001111111111	;col 3
		dw %1111111111111111	;End of list

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Font (1bpp / Black & White)

BitmapFont:
    incbin ".\Font96.FNT"
BitmapFontEnd:


