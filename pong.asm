
;----------
;--
;-- PONG : Written by Themaister
;-----------------------------------

.include "header.inc"
.include "initsnes.asm"

.bank 1
.section "Data"
.include "data.inc"
.ends

.include "macros.asm"
.include "registers.asm"
.include "wram.asm"

.bank 0
.section "Joypad"
.include "joypad.asm"
.ends

.bank 0
.section "Init"
.include "init.asm"
.ends

.bank 0
.section "Main"

; Entry point
Start:
   InitSNES ; Init SNES to a known state.

   jsr LoadData ; Load all sprites/tiles/tilemaps to VRAM.

   jsr InitOAM
   jsr InitVideo


MainLoop:
   wai ; Wait for NMI
   jsr FrameUpdate ; Do per-frame updates.
   jmp MainLoop



VBlank: ; VBlank routine
   jsr SaveJoypadData
   rti


.ends


.bank 0
.section "GameLogic"

FrameUpdate:
   rts

.ends
