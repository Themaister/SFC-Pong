
SaveJoypadData:
   pha

   lda RDNMI

   ; Busy wait till we can read from joypad.
-  lda HVBJOY
   and #$01
   beq -

   Stall 100 ; Have to wait for joypad stuff for finish up.

   lda JOY1L
   sta Joypad1Lo
   lda JOY1H
   sta Joypad1Hi
   lda JOY2L
   sta Joypad2Lo
   lda JOY2H
   sta Joypad2Hi

   pla
   rts


; Saves relevant joypad data for later reference.
SaveJoypadStatus:
   pha
   lda Joypad1Hi
   and #$08 ; Up
   sta Joypad1Up

   lda Joypad1Hi
   and #$04 ; Down
   sta Joypad1Down

   lda Joypad1Hi
   and #$02 ; Left
   sta Joypad1Left

   lda Joypad1Hi
   and #$01 ; Right
   sta Joypad1Right

   lda Joypad2Hi
   and #$08 ; Up
   sta Joypad2Up

   lda Joypad2Hi
   and #$04 ; Down
   sta Joypad2Down

   lda Joypad2Hi
   and #$02 ; Left
   sta Joypad2Left

   lda Joypad2Hi
   and #$01 ; Right
   sta Joypad2Right

   lda Joypad1Hi
   and #$10 ; Start
   sta Joypad1Start

   pla
   rts

