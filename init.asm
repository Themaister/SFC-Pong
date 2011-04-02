
LoadData:
   LoadCGRAM BGPalette, 0, 8
   LoadCGRAM SpritePalette, 128, 32

   LoadVRAM BGTiles, $1000, $0040 ; 4 tiles @ 8x8 @ 2bpp
   LoadVRAM BGTileMap, $0400, 32 * 28 * 2 ; 32x28 tiles @ 2 byte each.
   LoadVRAM BallSprite, $2000, $0020 ; 8x8 @ 4bpp, index 0
   LoadVRAM PillarEdgeSprite, $2010, $0020
   LoadVRAM PillarMiddleSprite, $2020, $0020

   rts

; "Clear" out OAM
InitOAM:
   pha
   phx

; Sets OAM to an initial state. Remove all sprites off-screen.
   ldx #0
   lda #$01

-  sta OAMData, x
   inx
   inx
   inx
   inx
   cpx #$0200
   bne -

   LoadOAM OAMData, 0, $200

; Set signed bit in all of high part of OAM.
   lda #$55
-  sta OAMData, x
   inx
   cpx #$0220
   bne -

   LoadOAM OAMData + $0200, $0100, $0020

   plx
   pla
   rts


InitVideo:
   pha
   phx

   stz BGMODE ; Set BG mode 0, 8x8 tiles, 4 colors.

   lda #$04
   sta BG1SC ; Set BG1 tile map offset to $0400 (word).

   lda #$01
   sta BG12NBA ; Set BG1 Character data VRAM offset to $1000 (word).

   lda #$11
   sta TM ; Enable OBJ/BG1

   ; Set some initial scrolling for BG1. This will probably be static.
   lda #$FF
   sta BG1HOFS
   stz BG1HOFS
   sta BG1VOFS
   stz BG1VOFS

   lda #$01
   sta OBSEL ; Sets (8x8/16x16) sprites.
   ; Sets sprite offset to $2000 (word).

   ; Turns on screen, full brightness.
   lda #$0F
   sta INIDISP

   ; Enable joypad auto-polling and NMI IRQ
   stz JOYSER0
   stz JOYSER1
   lda #%10000001
   sta NMITIMEN

   plx
   pla
   rts
