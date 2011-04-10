
.equ DSP_R $f2
.equ DSP_D $f3

.equ IO0 $f4
.equ IO1 $f5
.equ IO2 $f6
.equ IO3 $f7

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

.equ VOL_L3 $30
.equ VOL_R3 $31
.equ P_L3 $32
.equ P_H3 $33
.equ SRCN3 $34
.equ ADSR3_1 $35
.equ ADSR3_2 $36
.equ GAIN3 $37
.equ ENVX3 $38
.equ OUTX3 $39

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

.equ COEF0, $0f
.equ COEF1, $1f
.equ COEF2, $2f
.equ COEF3, $3f
.equ COEF4, $4f
.equ COEF5, $5f
.equ COEF6, $6f
.equ COEF7, $7f

.equ TIMER_CTRL $F1
.equ TIMER0 $FA
.equ TIMER1 $FB
.equ TIMER2 $FC
.equ TIMER_READ0 $FD
.equ TIMER_READ1 $FE
.equ TIMER_READ2 $FF

.macro wdsp
   mov a, #\1
   mov y, #\2
   movw DSP_R, ya
.endm

.macro wdsp_reg
   mov a, #\1
   movw DSP_R, ya
.endm

; Wait for a certain amount of MS. 1ms granularity. Max allowed: 255ms.
.macro WaitMS
   push a
   push y
   push x

   mov y, #\1
   mov a, #$00

   mov TIMER2, #$40
   mov TIMER_CTRL, #$04
-
   mov a, TIMER_READ2
   beq -
   dec y
   bne -

   pop x
   pop y
   pop a
.endm

.macro Stall
   push a
   mov a, #\1
--
   dec a
   bne --

   pop a
.endm

.memorymap
   defaultslot 0
   slot 0 start $8000 size $4000
.endme
.rombanksize $4000
.rombanks 1

.bank 0 slot 0
.orga $8000

Start:
   wdsp FLG, $00
   wdsp KON, 0
   wdsp DIR, >sample_directory

; Play a chord! :D
   wdsp VOL_L0, $7f
   wdsp VOL_R0, $7f
   wdsp P_L0, $00
   wdsp P_H0, $02
   wdsp SRCN0, 0
   wdsp ADSR0_1, %11011110
   wdsp ADSR0_2, %01111110
   wdsp GAIN0, $7f

   wdsp VOL_L1, $7f
   wdsp VOL_R1, $7f
   wdsp P_L1, $80
   wdsp P_H1, $02
   wdsp SRCN1, 0
   wdsp ADSR1_1, %11011110
   wdsp ADSR1_2, %01111110
   wdsp GAIN1, $7f

   wdsp VOL_L2, $7f
   wdsp VOL_R2, $7f
   wdsp P_L2, $00
   wdsp P_H2, $03
   wdsp SRCN2, 0
   wdsp ADSR2_1, %11011110
   wdsp ADSR2_2, %01111100
   wdsp GAIN2, $7f

   wdsp VOL_L3, $7f
   wdsp VOL_R3, $7f
   wdsp P_L3, $00
   wdsp P_H3, $04
   wdsp SRCN3, 3
   wdsp ADSR3_1, 0
   wdsp ADSR3_2, 0
   wdsp GAIN3, $7f

   wdsp ESA, 1
   wdsp EDL, 15
   wdsp NON, 0
   wdsp EON, 7
   wdsp EFB, 16

   wdsp COEF0, $7f

   wdsp MVOL_L, $7f
   wdsp MVOL_R, $7f
   wdsp EVOL_L, $40
   wdsp EVOL_R, $40

   mov x, #$00
   mov IO0, x

_forever:

-
   cmp x, IO0 ; Wait till it's echoed back.
   bne -
   inc x

   mov IO0, x ; Set up new popcorn
   mov a, IO1
   mov IO1, a ; Echo it back to CPU.

   mov y, IO2 ; Get keys
   wdsp_reg KON ; Play sound effect.

   jmp !_forever

.orga $8300
sample_directory:
   .dw tennis, tennis + 9 ; Tennis sound
   .dw square_wave, square_wave ; Square wave
   .dw triangle_wave, triangle_wave ; Triangle wave
   .dw test_sample, test_sample ; Some test sample ...

.orga $8400
square_wave:
   .db $c3, $ff, $ff, $ff, $ff, $00, $00, $00, $00

tennis:
   .dw $c2, $89, $ab, $cd, $ef, $01, $23, $45, $67
   .dw $c3, $00, $00, $00, $00, $00, $00, $00, $00

triangle_wave:
   .dw $c2, $89, $ab, $cd, $ef, $01, $23, $45, $67
   .dw $c3, $76, $54, $32, $10, $fe, $dc, $ba, $98

test_sample:
   .incbin "test.brr"


