
; Just stalls the CPU for a bit :)
.macro Stall
   phx
   ldx #\1
-  dex
   bne -
   plx
.endm
