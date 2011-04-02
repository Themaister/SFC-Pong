
LoadData:
   rts

InitOAM:
   rts

InitVideo:
   pha
   phx

   ; Set a green BG for now. (Just adjusts color for palette 0) D:
   ldx #$0000
   stx CGADD
   lda #%00011111
   sta CGDATA
   stz CGDATA

   ; Turns on screen, full brightness.
   lda #$0F
   sta INIDISP

   plx
   pla
   rts
