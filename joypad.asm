
SaveJoypadData:
   pha

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
