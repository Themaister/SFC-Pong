; Usage WaitAPUIO0 WAIT_COND
.macro WaitAPUIO0
-
   cmp APUIO0
   bne -
.endm

; Usage WaitAPUIO1 WAIT_COND
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

   ldx.w #\1
   stx APUIO2

   stz APUIO1 ; Jump

   lda #$cc   ; Perform action.
   sta APUIO0
   ;WaitAPUIO0

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

; Save the memory we use to stack.
   lda $00
   pha
   lda $01
   pha
   lda $02
   pha

; Save long address.
   lda #\1
   sta $02
   ldx.w #\2
   stx $00

   ldx.w #\3
   stx APUIO2
   lda #$01
   sta APUIO1
   lda #$cc
   sta APUIO0
   WaitAPUIO0

   lda #$00
   ldx.w #\4
   ldy #$0000
   jsr TransferBlockSPC_loop

   pla
   sta $02
   pla
   sta $01
   pla
   sta $00

; Pull bank back.
   plp
   ply
   plx
   pla
.endm

TransferBlockSPC_loop:
; Load data from RAM. Long addressing ftw.
   lda [$00], y
   sta APUIO1 

   tya ; Transfer index.

   iny
   sta APUIO0
   WaitAPUIO0

   dex
   bne TransferBlockSPC_loop

; Use an index larger than expected to have the SPC drop out. If 0, increase once more.
   clc
   adc #$02
   bne +
   inc A
+
   cmp #$cc   ; Make sure we don't write #$cc ... :D Would be unfortunate ...
   bne +
   inc A
+

   ldx #$ffcf ; Make the SPC drop back to $ffcf for more reading ...
   stx APUIO2
   stz APUIO1
   sta APUIO0

   WaitAPUIO0

   rts

StallInitSPC:
   lda #$aa
   WaitAPUIO0
   lda #$bb
   WaitAPUIO1
   rts

; Loads an SPC file into SMP/DSP.
InitSPC:
   pha
   phx

   jsr StallInitSPC

   TransferBlockSPC :TestSPCROM TestSPCROM, $f000, $0800 ; Transfer test rom
   SPCJump $f000 ; Branch to it.

   plx
   pla
   rts
   

; Todo: Extend to play many different sounds.
; A : Sample index.
SPCPlaySound:
   pha

   sta APUIO2

   inc SPCCounter
   lda SPCCounter
   sta APUIO1 ; Send popcorn
   xba

   lda APUIO0
   sta APUIO0

   xba
   WaitAPUIO1 ; Wait for handshake.

   pla
   rts
