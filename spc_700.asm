.macro WaitAPUIO0
-
   cmp APUIO0
   bne -
.endm

.macro WaitAPUIO1
-
   cmp APUIO1
   bne -
.endm

; Makes SPC jump to location.
; Usage: SPCJump ADDR
.macro SPCJump
   pha
   phx
   php
   sei

; This will only work when IPL-rom is active.
   lda #$aa
   WaitAPUIO0 ; Makes sure SPC is alive.
   lda #$bb
   WaitAPUIO1

   ldx #ADDR
   stx APUIO2

   stz APUIO1 ; Jump

   lda #$cc   ; Perform action.
   sta APUIO0
   WaitAPUIO0

   plp
   plx
   pla
.endm

; Usage: TransferBlockSPC SRC_BANK SRC_ADDR APU_ADDR SIZE
.macro TransferBlockSPC
   pha
   phx
   phy
   php
   sei ; Disable IRQ. Time sensitive stuff this ...

; Change bank.
   phb
   lda #\1
   pha
   plb

; Save long address.

   ldx #\3
   stx APUIO2
   lda #$01
   sta APUIO1
   lda #$cc
   sta APUIO0
   WaitAPUIO0

   lda #$00
   ldx #\4
   ldy #\2
   jsr TransferBlockSPC_loop

; Pull bank back.
   plb
   plp
   ply
   plx
   pla
.endm

TransferBlockSPC_loop:
   xba

; Load data from RAM.
   lda 0, y
   iny
   sta APUIO1 

   xba
   sta APUIO0
   WaitAPUIO0
   inc A

   dex
   bne TransferBlockSPC_loop

; Use an index larger than expected to have the SPC drop out. If 0, increase once more.
   inc A
   bne +
   inc A
+
   cmp #$cc   ; Make sure we don't write #$cc ... :D Would be unfortunate ...
   bne +
   inc A
+

   ldx #$ffcf ; Make the SPC drop back to $ffc9 for more reading ...
   stx APUIO2
   stz APUIO1
   sta APUIO0

   WaitAPUIO0

   rts


; Loads an SPC file into SMP/DSP.
InitSPC:
   pha
   phx

; We should perhaps make sure the data is in WRAM first, but hey. 
; It seems to work on bsnes accuracy to load straight from ROM :) Must be good! :D
   TransferBlockSPC :TestSPCData, TestSPCData, $2000, 32

   jsr SendDSPState
   jsr SendSPCRAM
   jsr SendSPCInitCode
   SPCJump $ffa0 ; Make SPC jump to our ASM routine.

   plx
   pla
   rts
   

SendDSPState:
   ; Sending DSP state.
   ldx #$0000

_dsp_load_loop:
   txa
   sta.l $7f0100
   lda.l SPC_DSPDATA, x
   sta.l $7f0101

   TransferBlockSPC $7f, $0100, $00f2, $0002
   inx
   cpx #$0080
   bne _dsp_load_loop

   rts


SendSPCInitCode:
; Sending SPC init code. Ye, it's created ... :v Wicked stuff.
; - Restore the first two bytes of RAM that is used by IPL.
; - Restore stack pointer.
; - Push restored PSW onto stack. (what is PSW?!)
; - Restore A register.
; - Restore X register.
; - Restore Y register.
; - Pop PSW register into its register (?!?)
; - Jump to saved PC. (libco? :D)

   lda.l $7f0001
   pha
   lda.l $7f0000
   pha

; Restore first byte
   lda #$8f ; mov dp, #imm
   sta.l $7f0000
   pla
   sta.l $7f0001
   lda #$00
   sta.l $7f0002

; Restore 2nd byte
   lda #$8f ; mov dp, #imm
   sta.l $7f0003
   pla
   sta.l $7f0004
   lda #$01
   sta.l $7f0005

; Restore SP. Cannot copy directy from immediate, have to: mov x, #imm, mov sp, x.
   lda #$cd ; mov x, #imm
   sta.l $7f0006
   lda.l SPC_SP
   sta.l $7f0007
   lda #$bd ; mov sp, x
   sta.l $7f0008

; Write code to push the program status ward. (PSW). It has to be popped off the stack very last.
   lda #$cd ; mov x, #imm
   sta.l $7f0009
   lda.l SPC_PSW
   sta.l $7f000a
   lda #$4d ; push x
   sta.l $7f000b

; Restore other registers ...
   lda #$e8 ; mov a, #imm
   sta.l $7f000c
   lda.l SPC_A
   sta.l $7f000d

   lda #$cd ; mov x, #imm
   sta.l $7f000e
   lda.l SPC_X
   sta.l $7f000f

   lda #$8d ; mov y, #imm
   sta.l $7f0010
   lda.l SPC_Y
   sta.l $7f0011

; Now we can pop PSW without having it destroyed.
   lda #$8e ; pop psw
   sta.l $7f0012

; Finally, jump to saved PC.
   lda #$5f ; jmp addr
   sta.l $7f0013
   rep #$30 ; Can only access long mode with A apparently...
   lda.l SPC_PC
   sep #$30
   sta.l $7f0014
   xba
   sta.l $7f0015

   TransferBlockSPC $7f, $0000, $ffa0, $0016 ; Transfer our hand crafted asm-routine to SPC ... :D

   rts
