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

; Game constants and macros

macro set_game_state ; screen state constant
  ld a, \1
  ld [rScreenState], a
endm

macro set_game_screen ; screen constant
  ld a, \1
  ld [rScreen], a
endm

; Constants

DEF ANIM_FPS EQU 8           ; update 1 animation frame per n vblank cycles

DEF SCREEN_TITLE EQU 0
DEF SCREEN_GAME EQU 1
DEF SCREEN_GAMEOVER EQU 2

DEF TITLE_CURSOR_ORI_X EQU 3
DEF TITLE_CURSOR_ORI_Y EQU 14
DEF STATE_TITLE_INIT EQU 0
DEF STATE_TITLE_FADE_IN EQU 1
DEF STATE_TITLE_ACTIVE EQU 2
DEF STATE_TITLE_FADE_OUT EQU 3

DEF GAME_CURSOR_ORI_X EQU 5
DEF GAME_CURSOR_ORI_Y EQU 15
DEF STATE_GAME_INIT EQU 0
DEF STATE_GAME_FADE_IN EQU 1
DEF STATE_GAME_ACTIVE EQU 2
DEF STATE_GAME_PLAYER_TURN EQU 3
DEF STATE_GAME_SHOW_ROUND_RESULT EQU 4
DEF STATE_GAME_FADE_OUT EQU 5

DEF STATE_GAMEOVER_INIT EQU 0
DEF STATE_GAMEOVER_FADE_IN EQU 1
DEF STATE_GAMEOVER_ACTIVE EQU 2
DEF STATE_GAMEOVER_FADE_OUT EQU 3

DEF DEFAULT_BG_PALETTE EQU %11100100
DEF DEFAULT_OBJ_PALETTE EQU %11100010

SECTION "OAM RAM data", WRAM0

; These addresses will be dynamically allocated sequentially
; within appropriate section (i.e. WRAM0) when linking

rRAM_OAM: ds 4*40 ; 40 sprites * 4 bytes

; Local variables
rCanUpdate: db
rAnimCounter: db
rResetAnimCounter: db
rCursorX: db
rCursorY: db
rCursorIndex: db
rFadeCounter: db
rGameRounds: db
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
  ld [rAUDENA], a

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

  call TurnOffScreen

  ld de, ImgText
  ld hl, $8800
  ld bc, ImgTextEnd - ImgText
  call CopyData

  ld de, ImgTitle
  ld hl, $9000
  ld bc, ImgTitleEnd - ImgTitle
  call CopyData

  call TurnOnScreen

  ; During the first (blank) frame, initialize display registers
  call ResetBGPalette
  ld a, DEFAULT_OBJ_PALETTE
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
  ld [rResetAnimCounter], a
  ld [rCursorIndex], a
  ld [rFadeCounter], a
  ld [rScreen], a         ; SCREEN_TITLE
  ld [rScreenState], a    ; STATE_TITLE_INIT
  call InitEngineVariables

  ld a, TITLE_CURSOR_ORI_X
  ld [rCursorX], a
  ld a, TITLE_CURSOR_ORI_Y
  ld [rCursorY], a

  ; Init sound
  ld a, AUDENA_ON     ; enable sounds
  ld [rAUDENA], a
  ld a, $FF           ; turn on all speakers (stereo)
  ld [rAUDTERM], a
  ld a, %11111111     ; 0111 0111 (max volume for SO2 and SO1)
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

  ; call PlayMusic

  ; Jump to appropriate loop based on screen state
  ld a, [rScreen]
  cp SCREEN_TITLE
  jp z, UpdateImgTitle
  cp SCREEN_GAME
  jp z, UpdateGameScreen
  cp SCREEN_GAMEOVER
  jp z, UpdateGameOverScreen
  ; Default fallthrough to title screen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UpdateImgTitle:
  ld a, [rScreenState]
  cp STATE_TITLE_INIT
  jp z, .init
  cp STATE_TITLE_FADE_IN
  jp z, .fadein
  cp STATE_TITLE_ACTIVE
  jp z, .active
  cp STATE_TITLE_FADE_OUT
  jp z, .fadeout

.init:
  call TurnOffScreen

  ld de, ImgTitleTilemap
  ld hl, $9800
  ld bc, ImgTitleTilemapEnd - ImgTitleTilemap
  call CopyData

  draw_text StrMenu1, 3, 12
  draw_text StrMenu2, 3, 13
  draw_text StrMenu3, 3, 14

  ld a, %00000000
  ld [rBGP], a    ; bg palette
  ld a, 4         ; fade 4 palette cycles
  ld [rFadeCounter], a

  ; TODO play title screen music

  call TurnOnScreen

  set_game_state STATE_TITLE_FADE_IN

  jp GameLoop

.fadein:
  ld a, [rAnimCounter]
  or a
  jp nz, GameLoop
  ld a, [rFadeCounter]
  cp 0
  jr z, .fadeinDone
  push bc
    push af
      ld b, a ; B = rFadeCounter
      ld a, DEFAULT_BG_PALETTE
      ld c, a ; C = DEFAULT_BG_PALETTE
.fadeinPaletteCheck:
      dec b ; decrement rFadeCounter
      jr z, .fadeinPaletteDone
.fadeinPalette:
      sla c
      sla c
      jr .fadeinPaletteCheck
.fadeinPaletteDone:
      ld a, c
      ld [rBGP], a
    pop af
    dec a
    ld [rFadeCounter], a
  pop bc
  ld a, 1
  ld [rResetAnimCounter], a
  jp GameLoop
.fadeinDone:
  call DrawCursor
  set_game_state STATE_TITLE_ACTIVE
  jp GameLoop

.active:
  call ReadInput
  check_pressed INPUT_DPAD_DOWN, nz, MoveCursorDown
  check_pressed INPUT_DPAD_UP, nz, MoveCursorUp
  check_pressed INPUT_BTN_A, nz, .startGame
  jp GameLoop
.startGame:
  call PlaySfxConfirm
  ld a, [rCursorIndex]
.startGameCheckRound5:
  cp 2
  jr nz, .startGameCheckRound3
  ld a, 5
  jr .startGameSetRounds
.startGameCheckRound3:
  cp 1
  jr nz, .startGameCheckRound1
  ld a, 3
  jr .startGameSetRounds
.startGameCheckRound1:
  ld a, 1
.startGameSetRounds:
  ld [rGameRounds], a

  ; Clear cursor sprite
  xor a       ; sprite number
  ld b, a     ; X
  ld c, a     ; Y
  ld e, a     ; cursor tile
  ld h, a     ; sprite palette
  call SetSprite

  ld a, DEFAULT_BG_PALETTE
  ld [rBGP], a    ; bg palette
  xor a           ; fade 0 to 4 palette cycles
  ld [rFadeCounter], a

  set_game_state STATE_TITLE_FADE_OUT

  jp GameLoop

.fadeout:
  ld a, [rAnimCounter]
  or a
  jp nz, GameLoop
  ld a, [rFadeCounter]
  cp 5
  jr z, .fadeoutDone
  push bc
    push af
      ld a, DEFAULT_BG_PALETTE
      ld c, a ; C = DEFAULT_BG_PALETTE
      ld a, [rFadeCounter]
      cp 0
      jr z, .fadeoutPaletteDone
      ld b, a
.fadeoutPaletteCheck:
      dec b ; decrement rFadeCounter
      jr z, .fadeoutPaletteDone
.fadeoutPalette:
      sla c
      sla c
      jr .fadeoutPaletteCheck
.fadeoutPaletteDone:
      ld a, c
      ld [rBGP], a
    pop af
    inc a
    ld [rFadeCounter], a
  pop bc
  ld a, 1
  ld [rResetAnimCounter], a
  jp GameLoop
.fadeoutDone:
  call ResetCursorIndex
  call ClearScreen
  call ResetBGPalette

  set_game_state STATE_GAME_INIT
  set_game_screen SCREEN_GAME

  jp GameLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UpdateGameScreen:
  ld a, [rScreenState]
  cp STATE_GAME_INIT
  jp z, .init
  cp STATE_GAME_FADE_IN
  jp z, .fadein
  cp STATE_GAME_ACTIVE
  jp z, .active
  cp STATE_GAME_FADE_OUT
  jp z, .fadeout

.init:
  call TurnOffScreen

  ld a, GAME_CURSOR_ORI_X
  ld [rCursorX], a
  ld a, GAME_CURSOR_ORI_Y
  ld [rCursorY], a

  ld de, ImgHands
  ld hl, $9000
  ld bc, ImgHandsEnd - ImgHands
  call CopyData

  ; TODO draw the initial hand position
  ; TODO play game music

  draw_text StrPrompt, 2, 11
  draw_text StrRock, 5, 13      ; option 0
  draw_text StrPaper, 5, 14     ; option 1
  draw_text StrScissors, 5, 15  ; option 2

  ld a, %00000000
  ld [rBGP], a    ; bg palette
  ld a, 4         ; fade 4 palette cycles
  ld [rFadeCounter], a

  call TurnOnScreen

  set_game_state STATE_GAME_FADE_IN

  jp GameLoop
.fadein:
  ld a, [rAnimCounter]
  or a
  jp nz, GameLoop
  ld a, [rFadeCounter]
  cp 0
  jr z, .fadeinDone
  push bc
    push af
      ld b, a ; B = rFadeCounter
      ld a, DEFAULT_BG_PALETTE
      ld c, a ; C = DEFAULT_BG_PALETTE
.fadeinPaletteCheck:
      dec b ; decrement rFadeCounter
      jr z, .fadeinPaletteDone
.fadeinPalette:
      sla c
      sla c
      jr .fadeinPaletteCheck
.fadeinPaletteDone:
      ld a, c
      ld [rBGP], a
    pop af
    dec a
    ld [rFadeCounter], a
  pop bc
  ld a, 1
  ld [rResetAnimCounter], a
  jp GameLoop
.fadeinDone:
  call DrawCursor
  set_game_state STATE_GAME_ACTIVE
  jp GameLoop

.active:
  ; TODO
  ; show selected hand image based on rCursorIndex

  call ReadInput
  check_pressed INPUT_DPAD_DOWN, nz, MoveCursorDown
  check_pressed INPUT_DPAD_UP, nz, MoveCursorUp
  ; check_pressed INPUT_BTN_A, nz, .selectMove
  jp GameLoop
; .selectMove:
  ; TODO
  ; - play selected sound
  ; - delay 100ms
  ; - clear clear screen
  ; - delay 100ms
  ; - show message "Rock... Paper... Scissors... Shoot!"
  ; - show opponent's hand
  ; - delay delay 1000ms
  ; - show message "Shucks! / Yeah!"
  ; - delay 3000ms
  ; - update score
  ; - (if game not yet ended) jump back to .active
  ; - (if game ended) delay 500ms
  ;   - clear screen
  ;   - show result message "You win/lose!"
  ;   - play fanfare sound
  ;   - delay 1000ms

  ; Clear cursor sprite
  ; xor a       ; sprite number
  ; ld b, a     ; X
  ; ld c, a     ; Y
  ; ld e, a     ; cursor tile
  ; ld h, a     ; sprite palette
  ; call SetSprite

  ; ld a, DEFAULT_BG_PALETTE
  ; ld [rBGP], a    ; bg palette
  ; xor a           ; fade 0 to 4 palette cycles
  ; ld [rFadeCounter], a

  ; ld a, STATE_TITLE_FADE_OUT
  ; ld [rScreenState], a
  ; jp GameLoop

.fadeout:
  jp GameLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UpdateGameOverScreen:
.init:
  jp GameLoop
.fadein:
  jp GameLoop
.active:
  jp GameLoop
.fadeout:
  jp GameLoop



SECTION "Game functions", ROM0

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

PlaySfxSelect:
  push af
    ld a, $64
    ld [rNR10], a
    ld a, $01
    ld [rNR11], a
    ld a, $f3
    ld [rNR12], a
    ld a, $08
    ld [rNR13], a
    ld a, $87
    ld [rNR14], a
  pop af
  ret

PlaySfxConfirm:
  push af
    ld a, $45
    ld [rNR10], a
    ld a, $80
    ld [rNR11], a
    ld a, $f6
    ld [rNR12], a
    ld a, $ce
    ld [rNR13], a
    ld a, $86
    ld [rNR14], a
  pop af
  ret

MoveCursorDown:
  call PlaySfxSelect
  ld a, [rCursorIndex]
  inc a
  cp 3
  jp nz, .moveCursorDownOk
  xor a ; wrap back to index 0
.moveCursorDownOk:
  ld [rCursorIndex], a
  call DrawCursor
  jp GameLoop

MoveCursorUp:
  call PlaySfxSelect
  ld a, [rCursorIndex]
  dec a
  cp 255 ; -1 is also known as 255
  jp nz, .moveCursorUpOk
  ld a, 2 ; wrap back to index 2
.moveCursorUpOk:
  ld [rCursorIndex], a
  call DrawCursor
  jp GameLoop

ResetBGPalette:
  ld a, DEFAULT_BG_PALETTE
  ld [rBGP], a    ; bg palette
  ret

ResetCursorIndex:
  push af
    xor a
    ld [rCursorIndex], a
  pop af
  ret

; Draw cursor at:
; - rCursorX = initial X pos of cursor at index 0
; - rCursorY = initial Y pos of cursor at index 0
; - rCursorIndex = 0/1/2 position
DrawCursor:
  push af
  push bc
  push de
  push hl
    push bc
      ld a, [rCursorX]
      ld b, a
      ld a, 8
      ld c, a
      call Multiply
    pop bc
    ld b, a       ; X-pos for SetSprite

    ld a, [rCursorIndex]
    cp 0
    jr z, .setYPos
    ld d, a       ; increment A by [rCursorIndex * 8 pixels]
    xor a
.loop:
    add 8
    dec d
    jr nz, .loop
.setYPos:
    ld e, a ; save the Y-offset
    push bc
      ld a, [rCursorY]
      ld b, a
      ld a, 8
      ld c, a
      call Multiply
    pop bc
    add e ; add origin Y-pos with Y-offset
    ld c, a       ; Y-pos for SetSprite

    ld e, $bb     ; cursor tile
    ld h, 0       ; sprite palette
    ld a, 0       ; sprite number
    call SetSprite
  pop hl
  pop de
  pop bc
  pop af
  ret

; Screen flags are custom to the game, so cannot be in engine.asm
TurnOnScreen:
  ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_BG8800
  ld [rLCDC], a
  ret

ClearScreen:
  call TurnOffScreen
  ld a, $80
  ld e, a
  call ClearTiles
  call TurnOnScreen
  ret

VblankInterrupt:
  push af
    ld a, 1
    ld [rCanUpdate], a

    ; Counts down to zero and stays zero until it is reset
    ld a, [rResetAnimCounter]
    or a
    jr z, .updateCounter
.resetCounter:
    xor a
    ld [rResetAnimCounter], a
    ld a, ANIM_FPS
    ld [rAnimCounter], a
.updateCounter:
    ld a, [rAnimCounter]
    or a
    jr z, .done
    dec a
    ld [rAnimCounter], a
.done
  pop af
  jp _HRAM ; DMA function, ends with reti

SECTION "Data and constants", ROM0

; Constants
StrMenu1: db "Play once", 255
StrMenu2: db "Play best of 3", 255
StrMenu3: db "Play best of 5", 255

StrPrompt: db "Your move?", 255
StrPaper: db "Paper", 255
StrRock: db "Rock", 255
StrScissors: db "Scissors", 255

StrBeats: db "beats", 255
StrLosesTo: db "loses to", 255

StrWin: db "You won!", 255
StrLose: db "You lost...", 255

SECTION "Tilemap", ROM0

ImgText:
  incbin "./resource/rps-text.2bpp"
ImgTextEnd:

ImgTitle:
  incbin "./resource/rps-title.2bpp"
ImgTitleEnd:

ImgTitleTilemap:
  incbin "./resource/rps-title.tilemap"
ImgTitleTilemapEnd:

ImgHands:
  incbin "./resource/rps-hands.2bpp"
ImgHandsEnd:

; TODO map positions for:
; left side scissors
; left side paper
; left side rock
; right side scissors
; right side paper
; right side rock
