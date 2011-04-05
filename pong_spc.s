; Play a sine wave with SPC700. :D

.equ DSP_R $f2
.equ DSP_D $f3

.equ VOL_L0 $00
.equ VOL_R0 $01
.equ P_L0 $02
.equ P_H0 $03
.equ SRCN0 $04
.equ ADSR0_1 $05
.equ ADSR0_2 $06
.equ GAIN0 $07
.equ ENVX0 $08
.equ OUTX0 $09

.equ VOL_L1 $10
.equ VOL_R1 $11
.equ P_L1 $12
.equ P_H1 $13
.equ SRCN1 $14
.equ ADSR1_1 $15
.equ ADSR1_2 $16
.equ GAIN1 $17
.equ ENVX1 $18
.equ OUTX1 $19

.equ VOL_L2 $20
.equ VOL_R2 $21
.equ P_L2 $22
.equ P_H2 $23
.equ SRCN2 $24
.equ ADSR2_1 $25
.equ ADSR2_2 $26
.equ GAIN2 $27
.equ ENVX2 $28
.equ OUTX2 $29

.equ MVOL_L $0c
.equ MVOL_R $1c
.equ EVOL_L $2c
.equ EVOL_R $3c
.equ KON $4c
.equ KOF $5c
.equ FLG $6c
.equ ENDX $7c

.equ EFB $0d
.equ PMON $2d
.equ NON $3d
.equ EON $4d
.equ DIR $5d
.equ ESA $6d
.equ EDL $7d

.equ KOFF0, $0f
.equ KOFF1, $1f
.equ KOFF2, $2f
.equ KOFF3, $3f
.equ KOFF4, $4f
.equ KOFF5, $5f
.equ KOFF6, $6f
.equ KOFF7, $7f

.macro wdsp
   mov a, #\1
   mov y, #\2
   movw DSP_R, ya
.endm

.memorymap
   defaultslot 0
   slot 0 start $f000 size $0800
.endme
.rombanksize $0800
.rombanks 1

.bank 0 slot 0
.orga $f000

Start:
   wdsp FLG, $20
   wdsp KON, 0
   wdsp DIR, >sample_directory

; Play a chord! :D
   wdsp VOL_L0, $7f
   wdsp VOL_R0, $7f
   wdsp P_L0, $00
   wdsp P_H0, $01
   wdsp SRCN0, 0
   wdsp ADSR0_1, $%11000011
   wdsp ADSR0_2, $%00101111
   wdsp GAIN0, $7f

   wdsp VOL_L1, $7f
   wdsp VOL_R1, $7f
   wdsp P_L1, $40
   wdsp P_H1, $01
   wdsp SRCN1, 0
   wdsp ADSR1_1, $%11000011
   wdsp ADSR1_2, $%00101111
   wdsp GAIN1, $7f

   wdsp VOL_L2, $7f
   wdsp VOL_R2, $7f
   wdsp P_L2, $80
   wdsp P_H2, $01
   wdsp SRCN2, 0
   wdsp ADSR2_1, $%11000011
   wdsp ADSR2_2, $%00101111
   wdsp GAIN2, $7f

   wdsp NON, 0
   wdsp EON, 0
   wdsp MVOL_L, $7f
   wdsp MVOL_R, $7f
   wdsp EVOL_L, 0
   wdsp EVOL_R, 0

   wdsp KON, 7

_forever:
   bra _forever

.orga $f100
sample_directory:
   .dw square_wave, square_wave


.orga $f200
square_wave:
   .db $b3, $ff, $ff, $ff, $ff, $00, $00, $00, $00