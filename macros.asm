
; Just stalls the CPU for a bit :)
.macro Stall
   phx
   ldx #\1
-  dex
   bne -
   plx
.endm

; Usage: LoadCGRAM LABEL CGRAM_ADDRESS (word) SIZE (bytes)
.macro LoadCGRAM
   pha
   phx

   ; Set bank to read from
   lda #:\1
   sta A1B0

   ; Set offset
   ldx #\1
   stx A1T0L

   ; Set CGRAM address to write to.
   lda #\2
   sta CGADD

   ; Bytes to write
   ldx #\3
   stx DAS0L

   stz DMAP0 ; Write one byte at a time.
   lda #$22
   sta BBAD0 ; Write to $2122 (CGRAM)

   lda #$01
   sta MDMAEN ; Begin transfer.

   plx
   pla
.endm

; Usage LoadVRAM LABEL VRAM_ADDR (word) SIZE (bytes)
.macro LoadVRAM
   pha
   phx

   lda #$80
   sta VMAIN ; Set word increment

   ; Set bank
   lda #:\1
   sta A1B0

   ; Set offset
   ldx #\1
   stx A1T0L

   ldx #\2
   stx VMADDL ; Set addr to write to (word).

   ; Bytes to write
   ldx #\3
   stx DAS0L

   lda #$01
   sta DMAP0
   lda #$18
   sta BBAD0 ; Write to $2118 (VRAM)

   lda #$01
   sta MDMAEN ; Begin transfer

   plx
   pla
.endm

; Usage LoadOAM WRAM_ADDR OAM_ADDR SIZE (bytes)
.macro LoadOAM
   pha
   phx

   ; We transfer directly from WRAM (bank 7E).
   lda #$7E
   sta A1B0

   ldx #\1
   stx A1T0L

   ldx #\2
   stx OAMADDL

   ldx #\3
   stx DAS0L

   stz DMAP0
   lda #$04
   sta BBAD0

   lda #$01
   sta MDMAEN

   plx
   pla
.endm

.macro negate_acc
   eor #$FF
   inc A
.endm


; Macros for updating state of pillars.
; A: amount to add to coordinates.
; X: pointer to pillar.
.macro UpdateBlockVert
   inx
   jsr UpdateBlock
.endm

.macro UpdateBlockHoriz
   jsr UpdateBlock
.endm

.macro UpdateEdgeBlockVert
   inx
   jsr UpdateEdgeBlock
.endm

.macro UpdateEdgeBlockHoriz
   jsr UpdateEdgeBlock
.endm

.macro SPCPlaySoundEffect
   pha
   lda #$07
   jsr SPCPlaySound
   pla
.endm

.macro SPCPlaySoundEffect_Score
   pha
   lda #$08
   jsr SPCPlaySound
   pla
.endm

