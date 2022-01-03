; Use gbtd22 (Game Boy Tile Designer 2.2) to make custom spritesheet
; http://www.devrs.com/gb/hmgd/gbtd.html

; Using halt and interrupts to optimise CPU processing:
; https://github.com/paulobruno/LearningGbAsm/tree/master/15_Interrupts

INCLUDE "include/hardware.inc"
INCLUDE "include/util.asm"
INCLUDE "include/engine.asm"

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

; Game macros

macro draw_text ; String, X, Y
  ld hl, \1
  ld a, \2
  ld [rCharX], a
  ld a, \3
  ld [rCharY], a
  call DrawString
endm

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

DEF STATE_SCREEN_TITLE EQU 0
DEF STATE_SCREEN_GAME EQU 1
DEF STATE_SCREEN_GAMEOVER EQU 2

DEF STATE_TITLE_INIT EQU 0
DEF STATE_TITLE_FADE_IN EQU 1
DEF STATE_TITLE_ACTIVE EQU 2
DEF STATE_TITLE_FADE_OUT EQU 3

DEF STATE_GAME_INIT EQU 0
DEF STATE_GAME_FADE_IN EQU 1
DEF STATE_GAME_PLAYER_TURN EQU 2
DEF STATE_GAME_SHOW_ROUND_RESULT EQU 3
DEF STATE_GAME_FADE_OUT EQU 4

DEF STATE_GAMEOVER_INIT EQU 0
DEF STATE_GAMEOVER_FADE_IN EQU 1
DEF STATE_GAMEOVER_ACTIVE EQU 2
DEF STATE_GAMEOVER_FADE_OUT EQU 3

SECTION "OAM RAM data", WRAM0

; These addresses will be dynamically allocated sequentially
; within appropriate section (i.e. WRAM0) when linking

rRAM_OAM: ds 4*40 ; 40 sprites * 4 bytes

; Local variables
rInputs: db
rInputsPrev: db
rInputsPressed: db
rInputsReleased: db
rCanUpdate: db
rAnimCounter: db
rCharX: db
rCharY: db
rScreen: db
rScreenState: db

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

  ld de, MySpriteSheet
  ld hl, $8800
  ld bc, MySpriteSheetEnd - MySpriteSheet
  call CopyData

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
  ld [rCharX], a
  ld [rCharY], a
  ld [rScreen], a
  ld [rScreenState], a

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

GameLoop:
  halt                ; pause game (conserves CPU power) until next interrupt
  ld a, [rCanUpdate]
  cp 1
  jr nz, GameLoop         ; if interrupt was not vblank (resets rCanUpdate), jump back up and halt
  xor a
  ld [rCanUpdate], a

  ; Jump to appropriate loop based on screen state
  ld a, [rScreen]
  cp STATE_SCREEN_GAME
  jp z, UpdateGameScreen
  cp STATE_SCREEN_GAMEOVER
  jp z, UpdateGameOverScreen
  ; Default fallthrough to title screen

UpdateTitleScreen:
  ld a, [rScreenState]
  cp STATE_TITLE_FADE_IN
  jp z, .fadein
  cp STATE_TITLE_ACTIVE
  jp z, .update
  cp STATE_TITLE_FADE_OUT
  jp z, .fadeout
.init:
  draw_text StrMenu1, 3, 12
  draw_text StrMenu2, 3, 13
  draw_text StrMenu3, 3, 14
  ld a, STATE_TITLE_FADE_IN
  ld [rScreenState], a
  jp GameLoop
.fadein:
  jp GameLoop
.update:
  jp GameLoop
.fadeout:
  jp GameLoop

UpdateGameScreen:
.fadein:
  jp GameLoop
.update:
  jp GameLoop
.fadeout:
  jp GameLoop
.init:
  jp GameLoop

UpdateGameOverScreen:
.fadein:
  jp GameLoop
.update:
  jp GameLoop
.fadeout:
  jp GameLoop
.init:
  jp GameLoop

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

SECTION "Data and constants", ROM0

; Binaries
MySpriteSheet:
  incbin "./resource/sprite-sheet.bin"
MySpriteSheetEnd:

; Constants
StrMenu1: db "Play once", 255
StrMenu2: db "Play best of 3", 255
StrMenu3: db "Play best of 5", 255
StrPaper: db "Paper", 255
StrRock: db "Rock", 255
StrScissors: db "Scissors", 255
StrBeats: db "beats", 255
StrLosesTo: db "loses to", 255
StrWin: db "You won!", 255
StrLose: db "You lost...", 255

SECTION "Tilemap", ROM0

TitleScreenMap:
  ; TODO
TitleScreenMapEnd:

