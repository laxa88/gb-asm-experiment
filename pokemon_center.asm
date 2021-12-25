include "include/hUGE.inc"

SECTION "Song Data", ROMX

pokemon_center::
db 7
dw order_cnt
dw order1, order2, order3, order4
dw duty_instruments, wave_instruments, noise_instruments
dw routines
dw waves

order_cnt: db 8
order1: dw P0,P4,P8,P12
order2: dw P1,P5,P9,P13
order3: dw P2,P6,P10,P14
order4: dw P3,P3,P3,P3

P0:
 dn F#5,1,$C07
 dn ___,0,$000
 dn F_5,1,$C07
 dn ___,0,$000
 dn F#5,1,$C07
 dn ___,0,$000
 dn D_6,1,$C07
 dn ___,0,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn C#6,1,$C07
 dn ___,0,$000
 dn B_5,1,$C07
 dn ___,0,$000
 dn A_5,1,$C07
 dn ___,0,$000
 dn B_5,1,$C07
 dn ___,0,$000
 dn A_5,1,$C07
 dn ___,0,$000
 dn G_5,1,$C07
 dn ___,0,$000
 dn F#5,1,$C07
 dn ___,0,$000
 dn E_5,1,$C07
 dn ___,0,$000
 dn F#5,1,$C07
 dn ___,0,$000
 dn G_5,1,$C07
 dn ___,0,$000
 dn A_5,1,$C07
 dn ___,0,$000
 dn A_5,1,$C07
 dn ___,0,$000
 dn E_5,1,$C07
 dn ___,0,$000
 dn A_5,1,$C07
 dn ___,0,$000
 dn C#6,1,$C07
 dn ___,0,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn B_5,1,$C07
 dn ___,0,$000
 dn A_5,1,$C07
 dn ___,0,$000
 dn G_5,1,$C07
 dn ___,0,$000
 dn F#5,1,$C07
 dn ___,0,$000
 dn A_5,1,$C07
 dn ___,0,$000
 dn B_5,1,$C07
 dn ___,0,$000
 dn C#6,1,$C07
 dn ___,0,$000
 dn D_6,1,$C07
 dn ___,0,$000
 dn C#6,1,$C07
 dn ___,0,$000
 dn B_5,1,$C07
 dn ___,0,$000
 dn A_5,1,$C07
 dn ___,0,$000

P1:
 dn D_6,2,$C0F
 dn ___,0,$000
 dn A_5,2,$C0F
 dn ___,0,$000
 dn D_6,2,$C0F
 dn ___,0,$000
 dn A_6,2,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0B
 dn ___,0,$C08
 dn G_6,2,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0B
 dn ___,0,$C08
 dn F#6,2,$C0F
 dn ___,0,$000
 dn E_6,2,$C0F
 dn ___,0,$000
 dn C#6,2,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0B
 dn ___,0,$C08
 dn ___,0,$C05
 dn ___,0,$C02
 dn A_5,2,$C0B
 dn ___,0,$000
 dn ___,0,$C0A
 dn ___,0,$C08
 dn E_5,2,$C0B
 dn ___,0,$000
 dn ___,0,$C0A
 dn ___,0,$C08
 dn C#6,2,$C0F
 dn ___,0,$000
 dn A_5,2,$C0F
 dn ___,0,$000
 dn C#6,2,$C0F
 dn ___,0,$000
 dn F#6,2,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0B
 dn ___,0,$C08
 dn E_6,2,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0B
 dn ___,0,$C08
 dn C#6,2,$C0F
 dn ___,0,$000
 dn D_6,2,$C0F
 dn ___,0,$000
 dn F#6,2,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0B
 dn ___,0,$C08
 dn ___,0,$C05
 dn ___,0,$C02
 dn A_5,2,$C0B
 dn ___,0,$000
 dn ___,0,$C0A
 dn ___,0,$C08
 dn E_5,2,$C0B
 dn ___,0,$000
 dn ___,0,$C0A
 dn ___,0,$C08

P2:
 dn D_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn F#4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn F#4,2,$000
 dn ___,0,$E00
 dn G_4,2,$000
 dn ___,0,$E00
 dn F#4,2,$000
 dn ___,0,$E00
 dn E_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn E_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn G_4,2,$000
 dn ___,0,$E00
 dn A_4,2,$000
 dn ___,0,$E00
 dn F#4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn G_4,2,$000
 dn ___,0,$E00
 dn A_4,2,$000
 dn ___,0,$E00

P3:
 dn C_8,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000
 dn C_8,3,$000
 dn ___,0,$000

P4:
 dn F#5,1,$C07
 dn ___,0,$000
 dn F_5,1,$C07
 dn ___,0,$000
 dn F#5,1,$C07
 dn ___,0,$000
 dn D_6,1,$C07
 dn ___,0,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn C#6,1,$C07
 dn ___,0,$000
 dn B_5,1,$C07
 dn ___,0,$000
 dn A_5,1,$C07
 dn ___,0,$000
 dn B_5,1,$C07
 dn ___,0,$000
 dn A_5,1,$C07
 dn ___,0,$000
 dn G_5,1,$C07
 dn ___,0,$000
 dn F#5,1,$C07
 dn ___,0,$000
 dn E_5,1,$C07
 dn ___,0,$000
 dn F#5,1,$C07
 dn ___,0,$000
 dn G_5,1,$C07
 dn ___,0,$000
 dn A_5,1,$C07
 dn ___,0,$000
 dn A_5,1,$C07
 dn ___,0,$000
 dn E_5,1,$C07
 dn ___,0,$000
 dn A_5,1,$C07
 dn ___,0,$000
 dn C#6,1,$C07
 dn ___,0,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn B_5,1,$C07
 dn ___,0,$000
 dn A_5,1,$C07
 dn ___,0,$000
 dn G_5,1,$C07
 dn ___,0,$000
 dn F#5,1,$C0D
 dn ___,0,$000
 dn E_5,1,$C0D
 dn ___,0,$000
 dn D_5,1,$C0D
 dn ___,0,$000
 dn E_5,1,$C0D
 dn ___,0,$000
 dn F#5,1,$C0D
 dn ___,0,$000
 dn G_5,1,$C0D
 dn ___,0,$000
 dn A_5,1,$C0D
 dn ___,0,$000
 dn B_5,1,$C0D
 dn ___,0,$000

P5:
 dn D_6,2,$C0F
 dn ___,0,$000
 dn A_5,2,$C0F
 dn ___,0,$000
 dn D_6,2,$C0F
 dn ___,0,$000
 dn A_6,2,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0B
 dn ___,0,$C08
 dn G_6,2,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0B
 dn ___,0,$C08
 dn F#6,2,$C0F
 dn ___,0,$000
 dn E_6,2,$C0F
 dn ___,0,$000
 dn C#6,2,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0B
 dn ___,0,$C08
 dn ___,0,$C05
 dn ___,0,$C02
 dn A_5,2,$C0B
 dn ___,0,$000
 dn ___,0,$C0A
 dn ___,0,$C08
 dn E_5,2,$C0B
 dn ___,0,$000
 dn ___,0,$C0A
 dn ___,0,$C08
 dn C#6,2,$C0F
 dn ___,0,$000
 dn A_5,2,$C0F
 dn ___,0,$000
 dn C#6,2,$C0F
 dn ___,0,$000
 dn F#6,2,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0B
 dn ___,0,$C08
 dn E_6,2,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0B
 dn ___,0,$C08
 dn C#6,2,$C0F
 dn ___,0,$000
 dn D_6,2,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0B
 dn ___,0,$C08
 dn ___,0,$C05
 dn ___,0,$C02
 dn ___,0,$000
 dn ___,0,$000
 dn D_5,2,$C0B
 dn ___,0,$000
 dn ___,0,$C0A
 dn ___,0,$C08
 dn E_5,2,$C0B
 dn ___,0,$000
 dn ___,0,$C0A
 dn ___,0,$C08

P6:
 dn D_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn F#4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn F#4,2,$000
 dn ___,0,$E00
 dn G_4,2,$000
 dn ___,0,$E00
 dn F#4,2,$000
 dn ___,0,$E00
 dn E_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn E_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn G_4,2,$000
 dn ___,0,$E00
 dn A_4,2,$000
 dn ___,0,$E00
 dn D_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn F#4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn F#4,2,$000
 dn ___,0,$E00
 dn D_4,2,$000
 dn ___,0,$E00
 dn G_4,2,$000
 dn ___,0,$E00

P8:
 dn F#5,1,$C0E
 dn ___,0,$000
 dn E_5,1,$C0E
 dn ___,0,$000
 dn D_5,1,$C0E
 dn ___,0,$C0B
 dn ___,0,$C09
 dn ___,0,$C07
 dn E_5,1,$C0E
 dn ___,0,$000
 dn F#5,1,$C0E
 dn ___,0,$000
 dn G_5,1,$C0E
 dn ___,0,$000
 dn A_5,1,$C0E
 dn ___,0,$000
 dn B_5,1,$C0E
 dn ___,0,$000
 dn A_5,1,$C0E
 dn ___,0,$000
 dn G_5,1,$C0E
 dn ___,0,$C0B
 dn ___,0,$C09
 dn ___,0,$C07
 dn E_5,1,$C0E
 dn ___,0,$000
 dn F#5,1,$C0E
 dn ___,0,$000
 dn G_5,1,$C0E
 dn ___,0,$000
 dn A_5,1,$C0E
 dn ___,0,$000
 dn G_5,1,$C0E
 dn ___,0,$000
 dn F#5,1,$C0E
 dn ___,0,$000
 dn E_5,1,$C0E
 dn ___,0,$C0B
 dn ___,0,$C09
 dn ___,0,$C07
 dn C#5,1,$C0E
 dn ___,0,$000
 dn D_5,1,$C0E
 dn ___,0,$000
 dn E_5,1,$C0E
 dn ___,0,$000
 dn G_5,1,$C0E
 dn ___,0,$000
 dn F#5,1,$C0E
 dn ___,0,$000
 dn G_5,1,$C0E
 dn ___,0,$000
 dn A_5,1,$C0E
 dn ___,0,$000
 dn B_5,1,$C0E
 dn ___,0,$000
 dn A_5,1,$C0E
 dn ___,0,$C0B
 dn ___,0,$C09
 dn ___,0,$C07
 dn ___,0,$C05
 dn ___,0,$C04
 dn ___,0,$C03
 dn ___,0,$C02

P9:
 dn F#6,3,$C0F
 dn ___,0,$000
 dn ___,0,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0C
 dn ___,0,$C0B
 dn ___,0,$C0A
 dn ___,0,$C08
 dn A_6,3,$C0F
 dn ___,0,$000
 dn ___,0,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0C
 dn ___,0,$C0B
 dn ___,0,$C0A
 dn ___,0,$C08
 dn G_6,3,$C0F
 dn ___,0,$000
 dn A_6,3,$C0F
 dn ___,0,$000
 dn G_6,3,$C0F
 dn ___,0,$000
 dn F#6,3,$C0F
 dn ___,0,$000
 dn E_6,3,$C0F
 dn ___,0,$000
 dn ___,0,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0C
 dn ___,0,$C0B
 dn ___,0,$C0A
 dn ___,0,$C08
 dn C#6,3,$C0F
 dn ___,0,$000
 dn ___,0,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0C
 dn ___,0,$C0B
 dn ___,0,$C0A
 dn ___,0,$C08
 dn E_6,3,$C0F
 dn ___,0,$000
 dn ___,0,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0C
 dn ___,0,$C0B
 dn ___,0,$C0A
 dn ___,0,$C08
 dn F#6,3,$C0F
 dn ___,0,$000
 dn G_6,3,$C0F
 dn ___,0,$000
 dn F#6,3,$C0F
 dn ___,0,$000
 dn E_6,3,$C0F
 dn ___,0,$000
 dn D_6,3,$C0F
 dn ___,0,$000
 dn ___,0,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0C
 dn ___,0,$C0B
 dn ___,0,$C0A
 dn ___,0,$C08

P10:
 dn F#4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn G_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn B_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn B_4,2,$000
 dn ___,0,$E00
 dn G_4,2,$000
 dn ___,0,$E00
 dn B_4,2,$000
 dn ___,0,$E00
 dn E_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn G_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn G_4,2,$000
 dn ___,0,$E00
 dn F#4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn G#4,2,$000
 dn ___,0,$E00
 dn A_4,2,$000
 dn ___,0,$E00

P12:
 dn D_6,1,$C0E
 dn ___,0,$000
 dn C#6,1,$C0E
 dn ___,0,$000
 dn B_5,1,$C0E
 dn ___,0,$C0B
 dn ___,0,$C09
 dn ___,0,$C07
 dn A_5,1,$C0E
 dn ___,0,$000
 dn B_5,1,$C0E
 dn ___,0,$000
 dn C#6,1,$C0E
 dn ___,0,$000
 dn D_6,1,$C0E
 dn ___,0,$000
 dn E_6,1,$C0E
 dn ___,0,$000
 dn D_6,1,$C0E
 dn ___,0,$000
 dn C#6,1,$C0E
 dn ___,0,$C0B
 dn ___,0,$C09
 dn ___,0,$C07
 dn B_5,1,$C0E
 dn ___,0,$000
 dn C#6,1,$C0E
 dn ___,0,$000
 dn D_6,1,$C0E
 dn ___,0,$000
 dn E_6,1,$C0E
 dn ___,0,$000
 dn C#6,1,$C0E
 dn ___,0,$000
 dn B_5,1,$C0E
 dn ___,0,$000
 dn A_5,1,$C0E
 dn ___,0,$C0B
 dn ___,0,$C09
 dn ___,0,$C07
 dn G_5,1,$C0E
 dn ___,0,$000
 dn A_5,1,$C0E
 dn ___,0,$000
 dn B_5,1,$C0E
 dn ___,0,$000
 dn G_5,1,$C0E
 dn ___,0,$000
 dn A_5,1,$C0E
 dn ___,0,$000
 dn G_5,1,$C0E
 dn ___,0,$000
 dn F#5,1,$C0E
 dn ___,0,$000
 dn E_5,1,$C0E
 dn ___,0,$000
 dn D_5,1,$C0E
 dn ___,0,$000
 dn E_5,1,$C0E
 dn ___,0,$000
 dn F#5,1,$C0E
 dn ___,0,$000
 dn G_5,1,$C0E
 dn ___,0,$000

P13:
 dn F#6,3,$C0F
 dn ___,0,$000
 dn ___,0,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0C
 dn ___,0,$C0B
 dn ___,0,$C0A
 dn ___,0,$C08
 dn A_6,3,$C0F
 dn ___,0,$000
 dn ___,0,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0C
 dn ___,0,$C0B
 dn ___,0,$C0A
 dn ___,0,$C08
 dn G_6,3,$C0F
 dn ___,0,$000
 dn F#6,3,$C0F
 dn ___,0,$000
 dn G_6,3,$C0F
 dn ___,0,$000
 dn A_6,3,$C0F
 dn ___,0,$000
 dn B_6,3,$C0F
 dn ___,0,$000
 dn ___,0,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0C
 dn ___,0,$C0B
 dn ___,0,$C0A
 dn ___,0,$C08
 dn A_6,3,$C0F
 dn ___,0,$000
 dn ___,0,$C0F
 dn ___,0,$C0E
 dn G_6,3,$C0F
 dn ___,0,$000
 dn F#6,3,$C0F
 dn ___,0,$000
 dn G_6,3,$C0F
 dn ___,0,$000
 dn ___,0,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0C
 dn ___,0,$C0B
 dn ___,0,$C0A
 dn ___,0,$C08
 dn F#6,3,$C0F
 dn ___,0,$000
 dn G_6,3,$C0F
 dn ___,0,$000
 dn F#6,3,$C0F
 dn ___,0,$000
 dn E_6,3,$C0F
 dn ___,0,$000
 dn D_6,3,$C0F
 dn ___,0,$000
 dn ___,0,$C0F
 dn ___,0,$C0E
 dn ___,0,$C0C
 dn ___,0,$C0B
 dn ___,0,$C0A
 dn ___,0,$C08

P14:
 dn F#4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn G_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn B_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn B_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn B_4,2,$000
 dn ___,0,$E00
 dn E_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn G_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn G_4,2,$000
 dn ___,0,$E00
 dn F#4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$000
 dn ___,0,$E00
 dn G_4,2,$000
 dn ___,0,$E00
 dn E_4,2,$000
 dn ___,0,$E00

duty_instruments:
itSquareinst1: db 8,128,240,128
itSquareinst2: db 8,128,243,128
itSquareinst3: db 8,128,245,128
itSquareinst4: db 8,192,240,128
itSquareinst5: db 8,0,241,128
itSquareinst6: db 8,64,241,128
itSquareinst7: db 8,128,241,128
itSquareinst8: db 8,192,241,128
itSquareinst9: db 8,128,240,128
itSquareinst10: db 8,128,240,128
itSquareinst11: db 8,128,240,128
itSquareinst12: db 8,128,240,128
itSquareinst13: db 8,128,240,128
itSquareinst14: db 8,128,240,128
itSquareinst15: db 8,128,240,128


wave_instruments:
itWaveinst1: db 0,32,0,128
itWaveinst2: db 0,32,4,128
itWaveinst3: db 0,32,2,128
itWaveinst4: db 0,32,3,128
itWaveinst5: db 0,32,4,128
itWaveinst6: db 0,32,5,128
itWaveinst7: db 0,32,6,128
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
itNoiseinst2: db 242,0,0,0,0,0,0,0
itNoiseinst3: db 241,116,0,0,0,0,0,0
itNoiseinst4: db 240,0,0,0,0,0,0,0
itNoiseinst5: db 240,0,0,0,0,0,0,0
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
wave0: db 0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255
wave1: db 0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255
wave2: db 0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255
wave3: db 0,0,0,0,0,0,0,0,0,0,0,0,255,255,255,255
wave4: db 0,1,18,35,52,69,86,103,120,137,154,171,188,205,222,239
wave5: db 254,220,186,152,118,84,50,16,18,52,86,120,154,188,222,255
wave6: db 122,205,219,117,33,19,104,189,220,151,65,1,71,156,221,184
wave7: db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
wave8: db 254,252,250,248,246,244,242,240,242,244,246,248,250,252,254,255
wave9: db 254,221,204,187,170,153,136,119,138,189,241,36,87,138,189,238
wave10: db 132,17,97,237,87,71,90,173,206,163,23,121,221,32,3,71
wave11: db 137,34,69,200,227,39,38,190,89,122,193,134,147,23,6,62
wave12: db 144,44,49,234,154,194,182,144,187,64,94,179,84,1,126,36
wave13: db 99,93,145,237,237,38,208,224,2,70,27,51,215,149,134,12
wave14: db 12,21,211,219,161,53,80,123,56,11,221,33,164,214,26,27
wave15: db 27,219,211,136,104,194,36,132,196,160,209,20,34,189,33,94

