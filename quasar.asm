include "include/hUGE.inc"

SECTION "Song Data", ROMX

quasar::
db 7
dw order_cnt
dw order1, order2, order3, order4
dw duty_instruments, wave_instruments, noise_instruments
dw routines
dw waves

order_cnt: db 2
order1: dw P0
order2: dw P1
order3: dw P2
order4: dw P3

P0:
 dn ___,0,$8FF
 dn G#5,10,$C48
 dn G#5,10,$C48
 dn D#6,10,$C48
 dn G#5,10,$C48
 dn F#6,10,$C48
 dn G#6,10,$C48
 dn G#5,10,$C48
 dn G#6,10,$C48
 dn D#6,10,$C48
 dn G#5,10,$C48
 dn A#6,10,$C48
 dn D#6,10,$C48
 dn B_6,10,$C48
 dn A#6,10,$C48
 dn E_6,10,$C48
 dn B_6,10,$C48
 dn G#5,10,$C48
 dn E_6,10,$C48
 dn E_6,10,$C48
 dn G#5,10,$C48
 dn E_6,10,$C48
 dn D#6,10,$C48
 dn B_5,10,$C48
 dn E_6,10,$C48
 dn C#6,10,$C48
 dn B_5,10,$C48
 dn D#6,10,$C48
 dn C#6,10,$C48
 dn F#6,10,$C48
 dn G#6,10,$C48
 dn G#5,10,$C48
 dn G#6,10,$C48
 dn G#5,10,$C48
 dn G#5,10,$C48
 dn D#6,10,$C48
 dn G#5,10,$C48
 dn F#6,10,$C48
 dn G#6,10,$C48
 dn G#5,10,$C48
 dn G#6,10,$C48
 dn D#6,10,$C48
 dn G#5,10,$C48
 dn A#6,10,$C48
 dn D#6,10,$C48
 dn B_6,10,$C48
 dn A#6,10,$C48
 dn C#7,10,$C48
 dn B_6,10,$C48
 dn G#5,10,$C48
 dn C#7,10,$C48
 dn G#6,10,$C48
 dn G#5,10,$C48
 dn A#6,10,$C48
 dn D#6,10,$C48
 dn F#6,10,$C48
 dn D#6,10,$C48
 dn C#6,10,$C48
 dn F#6,10,$C48
 dn D#6,10,$C48
 dn C#6,10,$C48
 dn F#6,10,$C48
 dn A#6,10,$C48
 dn B_6,10,$C48

P1:
 dn G#5,10,$F07
 dn G#5,10,$C48
 dn D#6,10,$000
 dn G#5,10,$C48
 dn F#6,10,$000
 dn G#6,10,$000
 dn G#5,10,$000
 dn G#6,10,$C48
 dn D#6,10,$000
 dn G#5,10,$C48
 dn A#6,10,$000
 dn D#6,10,$C48
 dn B_6,10,$000
 dn A#6,10,$C48
 dn E_6,10,$000
 dn B_6,10,$C48
 dn G#5,10,$000
 dn E_6,10,$C48
 dn E_6,10,$000
 dn G#5,10,$C48
 dn E_6,10,$000
 dn D#6,10,$000
 dn B_5,10,$000
 dn E_6,10,$C48
 dn C#6,10,$000
 dn B_5,10,$C48
 dn D#6,10,$000
 dn C#6,10,$C48
 dn F#6,10,$000
 dn G#6,10,$000
 dn G#5,10,$000
 dn G#6,10,$C48
 dn G#5,10,$000
 dn G#5,10,$C48
 dn D#6,10,$000
 dn G#5,10,$C48
 dn F#6,10,$000
 dn G#6,10,$000
 dn G#5,10,$000
 dn G#6,10,$C48
 dn D#6,10,$000
 dn G#5,10,$C48
 dn A#6,10,$000
 dn D#6,10,$C48
 dn B_6,10,$000
 dn A#6,10,$C48
 dn C#7,10,$000
 dn B_6,10,$C48
 dn G#5,10,$000
 dn C#7,10,$C48
 dn G#6,10,$000
 dn G#5,10,$C48
 dn A#6,10,$000
 dn D#6,10,$000
 dn F#6,10,$000
 dn D#6,10,$C48
 dn C#6,10,$000
 dn F#6,10,$C48
 dn D#6,10,$000
 dn C#6,10,$C48
 dn F#6,10,$000
 dn A#6,10,$000
 dn B_6,10,$000
 dn A#6,10,$C48

P2:
 dn G#3,7,$4A1
 dn ___,0,$4A2
 dn ___,0,$400
 dn ___,0,$400
 dn ___,0,$400
 dn ___,0,$400
 dn G#4,7,$330
 dn ___,0,$330
 dn G#3,7,$4A1
 dn ___,0,$4A2
 dn ___,0,$400
 dn G#3,7,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D#4,7,$000
 dn ___,0,$000
 dn E_4,7,$4A1
 dn ___,0,$4A2
 dn ___,0,$400
 dn ___,0,$400
 dn E_4,7,$400
 dn ___,0,$400
 dn C#4,7,$4A1
 dn ___,0,$4A2
 dn ___,0,$400
 dn ___,0,$400
 dn C#4,7,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn F#4,7,$000
 dn ___,0,$000
 dn G#3,7,$4A1
 dn ___,0,$4A2
 dn ___,0,$400
 dn ___,0,$400
 dn ___,0,$400
 dn ___,0,$400
 dn G#4,7,$330
 dn ___,0,$330
 dn G#3,7,$4A1
 dn ___,0,$4A2
 dn ___,0,$400
 dn G#3,7,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D#4,7,$000
 dn ___,0,$000
 dn E_4,7,$4A1
 dn ___,0,$4A2
 dn ___,0,$400
 dn ___,0,$400
 dn E_4,7,$400
 dn ___,0,$400
 dn F#4,7,$330
 dn ___,0,$330
 dn ___,0,$4A1
 dn ___,0,$4A2
 dn F#4,7,$400
 dn ___,0,$400
 dn ___,0,$400
 dn ___,0,$400
 dn D#4,7,$320
 dn ___,0,$320

P3:
 dn A#7,3,$000
 dn ___,0,$000
 dn D#8,5,$000
 dn A_7,2,$000
 dn D_8,4,$000
 dn ___,0,$000
 dn A#7,3,$000
 dn ___,0,$000
 dn A#7,3,$000
 dn ___,0,$000
 dn D#8,5,$000
 dn A_7,2,$000
 dn D_8,4,$000
 dn ___,0,$000
 dn D#8,5,$000
 dn D_8,4,$000
 dn A#7,3,$000
 dn ___,0,$000
 dn D#8,5,$000
 dn A_7,2,$000
 dn D_8,4,$000
 dn ___,0,$000
 dn D#8,5,$000
 dn A_7,2,$000
 dn A#7,3,$000
 dn A#7,3,$000
 dn D#8,5,$000
 dn A#7,3,$000
 dn D_8,4,$000
 dn ___,0,$000
 dn D#8,5,$000
 dn D_8,4,$000
 dn A#7,3,$000
 dn ___,0,$000
 dn D#8,5,$000
 dn A_7,2,$000
 dn D_8,4,$000
 dn ___,0,$000
 dn A#7,3,$000
 dn ___,0,$000
 dn A#7,3,$000
 dn ___,0,$000
 dn D#8,5,$000
 dn A_7,2,$000
 dn D_8,4,$000
 dn ___,0,$000
 dn D#8,5,$000
 dn D_8,4,$000
 dn A#7,3,$000
 dn ___,0,$000
 dn D#8,5,$000
 dn A_7,2,$000
 dn D_8,4,$000
 dn ___,0,$000
 dn D#8,5,$000
 dn A_7,2,$000
 dn A#7,3,$000
 dn A#7,3,$000
 dn D#8,5,$000
 dn A#7,3,$000
 dn D_8,4,$000
 dn D_8,4,$000
 dn D#8,5,$000
 dn D_8,4,$000

duty_instruments:
itSquareinst1: db 8,128,240,128
itSquareinst2: db 8,128,240,128
itSquareinst3: db 8,128,240,128
itSquareinst4: db 8,128,240,128
itSquareinst5: db 8,128,240,128
itSquareinst6: db 8,128,240,128
itSquareinst7: db 8,128,240,128
itSquareinst8: db 8,128,240,128
itSquareinst9: db 8,128,240,128
itSquareinst10: db 8,128,242,128
itSquareinst11: db 8,192,240,128
itSquareinst12: db 8,128,240,128
itSquareinst13: db 8,128,240,128
itSquareinst14: db 8,128,240,128
itSquareinst15: db 8,128,240,128


wave_instruments:
itWaveinst1: db 0,32,0,128
itWaveinst2: db 0,32,1,128
itWaveinst3: db 0,32,2,128
itWaveinst4: db 0,32,3,128
itWaveinst5: db 0,32,4,128
itWaveinst6: db 0,32,5,128
itWaveinst7: db 0,32,0,128
itWaveinst8: db 0,32,7,128
itWaveinst9: db 0,32,8,128
itWaveinst10: db 0,32,9,128
itWaveinst11: db 0,32,10,128
itWaveinst12: db 0,32,11,128
itWaveinst13: db 0,32,12,128
itWaveinst14: db 0,32,13,128
itWaveinst15: db 0,32,14,128


noise_instruments:
itNoiseinst1: db 240,0,0,0,0,0,0,0
itNoiseinst2: db 240,102,0,0,0,0,0,0
itNoiseinst3: db 240,104,0,0,0,0,0,0
itNoiseinst4: db 240,68,0,0,0,0,0,0
itNoiseinst5: db 241,46,0,0,0,0,0,0
itNoiseinst6: db 240,0,0,0,0,0,0,0
itNoiseinst7: db 240,0,0,0,0,0,0,0
itNoiseinst8: db 240,0,0,0,0,0,0,0
itNoiseinst9: db 240,0,0,0,0,0,0,0
itNoiseinst10: db 240,0,0,0,0,0,0,0
itNoiseinst11: db 240,0,0,0,0,0,0,0
itNoiseinst12: db 240,0,0,0,0,0,0,0
itNoiseinst13: db 240,0,0,0,0,0,0,0
itNoiseinst14: db 240,0,0,0,0,0,0,0
itNoiseinst15: db 240,0,0,0,0,0,0,0


routines:
__hUGE_Routine_0:

__end_hUGE_Routine_0:
ret

__hUGE_Routine_1:

__end_hUGE_Routine_1:
ret

__hUGE_Routine_2:

__end_hUGE_Routine_2:
ret

__hUGE_Routine_3:

__end_hUGE_Routine_3:
ret

__hUGE_Routine_4:

__end_hUGE_Routine_4:
ret

__hUGE_Routine_5:

__end_hUGE_Routine_5:
ret

__hUGE_Routine_6:

__end_hUGE_Routine_6:
ret

__hUGE_Routine_7:

__end_hUGE_Routine_7:
ret

__hUGE_Routine_8:

__end_hUGE_Routine_8:
ret

__hUGE_Routine_9:

__end_hUGE_Routine_9:
ret

__hUGE_Routine_10:

__end_hUGE_Routine_10:
ret

__hUGE_Routine_11:

__end_hUGE_Routine_11:
ret

__hUGE_Routine_12:

__end_hUGE_Routine_12:
ret

__hUGE_Routine_13:

__end_hUGE_Routine_13:
ret

__hUGE_Routine_14:

__end_hUGE_Routine_14:
ret

__hUGE_Routine_15:

__end_hUGE_Routine_15:
ret

waves:
wave0: db 119,117,0,0,0,0,0,0,255,254,238,238,236,34,23,118
wave1: db 92,235,45,222,123,198,123,161,169,130,142,183,22,115,43,182
wave2: db 130,4,146,147,149,237,166,89,109,161,14,169,162,53,27,73
wave3: db 72,6,158,225,147,146,233,131,102,115,146,81,169,66,178,229
wave4: db 192,25,202,30,237,119,224,150,176,6,78,21,71,26,77,109
wave5: db 58,136,195,119,209,216,29,68,10,193,154,196,50,88,128,44
wave6: db 2,168,74,180,230,59,133,141,137,61,234,102,206,161,75,198
wave7: db 173,56,77,234,138,151,126,57,86,153,112,116,169,68,89,182
wave8: db 33,65,133,136,128,158,148,99,210,81,110,211,200,166,17,213
wave9: db 126,194,221,2,121,33,188,204,104,38,1,234,86,106,12,94
wave10: db 195,11,94,171,37,119,5,34,2,182,61,94,217,168,11,39
wave11: db 8,163,238,73,168,200,186,228,133,51,50,62,139,103,227,163
wave12: db 0,103,77,174,89,40,12,27,167,106,137,218,231,54,157,50
wave13: db 59,212,213,152,76,121,13,68,107,210,174,106,115,190,58,211
wave14: db 62,119,10,50,106,89,99,66,140,203,26,116,18,170,86,140
wave15: db 50,39,21,174,11,187,29,49,184,168,14,52,67,161,0,141

