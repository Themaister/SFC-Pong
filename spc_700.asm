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
   pha

; Load data from RAM.
   lda 0, y
   iny
   sta APUIO1 

   pla
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
   ldx #$ffc9 ; Make the SPC drop back to $ffc9 for more reading ...
   stx APUIO2
   stz APUIO1
   sta APUIO0

   lda #$aa
   WaitAPUIO0

   rts


; Dummy function for now... Transfering two bytes.
InitSPC:
   pha
   phy

   TransferBlockSPC :TestSPCData, TestSPCData, $2000, 16

   ply
   pla
   rts
   
