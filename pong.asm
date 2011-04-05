
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
.section "SPC"
.include "spc_700.asm"
.ends

.bank 0
.section "Main"

; Entry point
Start:
   InitSNES ; Init SNES to a known state.

   stz NMITIMEN
   sei

   jsr InitSPC

   jsr LoadData ; Load all sprites/tiles/tilemaps to VRAM.

   jsr InitOAM
   jsr InitGame
   jsr InitVideo

   cli

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

; Set up sprites in HW, and set up initial game state.
InitGame:


   jsr InitBall
   jsr InitPillar
   jsr InitScore
      
   LoadOAM OAMData, 0, 128
   LoadOAM OAMData + $0200, $0100, 32

   rts

InitBall:
   pha
   lda #$02
   sta BallSpeedX
   sta BallSpeedY

   lda #$80
   sta BallPosX
   sta BallPosY

   sta BallSpriteOAM + 0 ; x-coord
   sta BallSpriteOAM + 1 ; y-coord
   stz BallSpriteOAM + 2 ; sprite index
   lda #%00110000
   sta BallSpriteOAM + 3 ; Prio 3

   lda #%01010100
   sta OAMData + $0200 ; Don't hide sprite 0

   pla
   rts

InitScore:
   pha

   stz Player1Score
   stz Player2Score

   lda #$05
   sta Player1ScoreOAM + 1
   sta Player2ScoreOAM + 1

   lda #$40
   sta Player1ScoreOAM
   lda #$B0
   sta Player2ScoreOAM

   lda #$10
   sta Player1ScoreOAM + 2
   sta Player2ScoreOAM + 2

   lda #%00110000
   sta Player1ScoreOAM + 3
   sta Player2ScoreOAM + 3

   lda #%01010000
   sta OAMData + $0200 + 4

   pla
   rts

InitPillar:
   pha
   phx

; Set coordinates for edge sprites.
   lda #$50
   sta PillarEdgeSpriteOAM + 1 ; top y-coord of p1
   sta PillarEdgeSpriteOAM + 5 ; top y-coord of p2

   lda #($50 + 5 * 8)
   sta PillarEdgeSpriteOAM + 9 ; bottom y-coord of p1
   sta PillarEdgeSpriteOAM + 13 ; bottom y-coord of p2

   lda #$30
   sta PillarEdgeSpriteOAM ; top x-coord of p1
   sta PillarEdgeSpriteOAM + 8 ; bottom x-coord of p1
   lda #$C0
   sta PillarEdgeSpriteOAM + 4 ; top x-coord of p2
   sta PillarEdgeSpriteOAM + 12 ; bottom x-coord of p2

; Set coordinates for middle sprites.
; y-coordinates
   lda #($50 + 8)
   ldx #$0000
-  sta PillarSpriteOAM + 1, x ; y-coord p1
   sta PillarSpriteOAM + 17, x ; y-coord p2
   inx
   inx
   inx
   inx
   clc
   adc #$08
   cpx #$0010
   bne -

; x-coordinates
   ldx #$0000
-  lda #$30
   sta PillarSpriteOAM, x ; x-coord p1
   lda #$C0
   sta PillarSpriteOAM + 16, x ; x-coord p2
   inx
   inx
   inx
   inx
   cpx #$0010
   bne -

   stz OAMData + $0200 + 1
   stz OAMData + $0200 + 2 ; Show all Pillar sprites
   stz OAMData + $0200 + 3

; Set middle sprites
   ldx #$0000
-  lda #$02 ; Sprite 1
   sta PillarSpriteOAM + 2, x
   lda #%00110000 ; Prio 3
   sta PillarSpriteOAM + 3, x
   inx
   inx
   inx
   inx
   cpx #$0020
   bne -

; Set edge sprites with flip, etc.
   lda #$01
   sta PillarEdgeSpriteOAM + 2
   sta PillarEdgeSpriteOAM + 6
   sta PillarEdgeSpriteOAM + 10
   sta PillarEdgeSpriteOAM + 14
   lda #%00110000
   sta PillarEdgeSpriteOAM + 3
   sta PillarEdgeSpriteOAM + 7
   lda #%10110000 ; vertical flip
   sta PillarEdgeSpriteOAM + 11
   sta PillarEdgeSpriteOAM + 15
   


   plx
   pla
   rts


FrameUpdate:
   LoadOAM OAMData, 0, 128 ; Update coordinates in OAM ASAP. We might have to do expensive calculation after this.
   jsr UpdateBall
   jsr UpdatePillar

   rts


UpdateBall:
   pha

   lda BallPosX
   clc
   adc BallSpeedX
   sta BallPosX
   sta BallSpriteOAM + 0 ; x-coord

   lda BallPosY
   clc
   adc BallSpeedY
   sta BallPosY
   sta BallSpriteOAM + 1 ; y-coord

   jsr CollitionDetect
   jsr CheckScore

   pla
   rts

CheckScore:
   pha

; Wtf is this shit... if (BallPosX < 0x10 || BallPosX >= 0xF0) { do_shit(); }
   lda BallPosX
   cmp #$10
   bcs +
   inc Player2Score
   bra _check_score_is_true

+  lda BallPosX
   cmp #$F0
   bcc _check_score_end
   inc Player1Score

_check_score_is_true:
; Set some initial speed/coord
   lda #$60
   clc
   adc Player1Score
   sta BallPosX
   clc
   adc Player2Score
   sta BallPosY
   lda #$04
   clc
   adc Player1Score
   lsr
   sta BallSpeedX
   lda #$05
   adc Player2Score
   lsr
   sta BallSpeedY

; Check for Advantage/Game, etc.
   lda Player1Score
   cmp #$03
   bcc +
   lda Player2Score
   cmp #$02
   bcs ++
   lda #$04
   sta Player1Score
   bra _skip_score_calculation
++ lda #$02
   sta Player2Score

+  lda Player2Score
   cmp #$03
   bcc _skip_score_calculation
   lda Player1Score
   cmp #$02
   bcs ++
   lda #$04
   sta Player2Score
   bra _skip_score_calculation
++ lda #$02
   sta Player1Score

_skip_score_calculation:
   lda Player1Score
   and #$07
   clc
   adc #$10 ; Sprite index for score.
   sta Player1ScoreOAM + 2

   lda Player2Score
   and #$07
   clc
   adc #$10 ; Sprite index for score.
   sta Player2ScoreOAM + 2

_check_score_end:
   pla
   rts

; Check edges first
CollitionDetect:
   pha

   ; Check to see if we're on the "scoring" edge. 
   ; If so, don't perform collition detection at all.
   lda BallPosY
   cmp #(16 * 8)
   bcs _collition_detect_left
   lda BallPosY
   cmp #(12 * 8)
   bcc _collition_detect_left
   bra _collition_detect_end

_collition_detect_left:
   lda BallSpeedX
   bpl _collition_detect_right

   lda BallPosX
   cmp #$18
   bcs _collition_detect_up
   lda BallSpeedX
   jsr SPCPlaySound
   negate_acc
   sta BallSpeedX
   jmp _collition_detect_up
   
_collition_detect_right:
   lda BallPosX
   cmp #$E8
   bcc _collition_detect_up
   lda BallSpeedX
   jsr SPCPlaySound
   negate_acc
   sta BallSpeedX


_collition_detect_up:
   lda BallSpeedY
   bpl _collition_detect_down

   lda BallPosY
   cmp #$24
   bcs _collition_detect_end
   lda BallSpeedY
   jsr SPCPlaySound
   negate_acc
   sta BallSpeedY
   bra _collition_detect_end

_collition_detect_down:
   lda BallPosY
   cmp #$C8
   bcc _collition_detect_end
   lda BallSpeedY
   jsr SPCPlaySound
   negate_acc
   sta BallSpeedY

_collition_detect_end:
   jsr CollitionDetectPillar

   pla
   rts
   

; This is HELL :D
CollitionDetectPillar:
   pha

;_collition_detect_pillar_l:
   lda BallPosY
   cmp PillarEdgeSpriteOAM + 1 ; Upper coord of P1
   bcc _collition_detect_pillar_r

   lda BallPosY
   cmp PillarEdgeSpriteOAM + 9
   bcs _collition_detect_pillar_r

   lda BallSpeedX
   bpl +
   lda BallPosX
   cmp #($30 + 9)
   bcs _collition_detect_pillar_r
   cmp #($30 - 0)
   bcc _collition_detect_pillar_r

   lda BallSpeedX
   jsr SPCPlaySound
   negate_acc
   sta BallSpeedX
   bra _collition_detect_pillar_end

+  lda BallPosX
   cmp #($30 - 9)
   bcc _collition_detect_pillar_r
   cmp #($30 + 0)
   bcs _collition_detect_pillar_r

   lda BallSpeedX
   jsr SPCPlaySound
   negate_acc
   sta BallSpeedX
   bra _collition_detect_pillar_end


_collition_detect_pillar_r:

   lda BallPosY
   cmp PillarEdgeSpriteOAM + 5 ; Upper coord of P1
   bcc _collition_detect_pillar_end

   lda BallPosY
   cmp PillarEdgeSpriteOAM + 13
   bcs _collition_detect_pillar_end

   lda BallSpeedX
   bpl +
   lda BallPosX
   cmp #($C0 + 9)
   bcs _collition_detect_pillar_end
   cmp #($C0 - 0)
   bcc _collition_detect_pillar_end

   lda BallSpeedX
   jsr SPCPlaySound
   negate_acc
   sta BallSpeedX
   bra _collition_detect_pillar_end

+  lda BallPosX
   cmp #($C0 - 9)
   bcc _collition_detect_pillar_end
   cmp #($C0 + 0)
   bcs _collition_detect_pillar_end

   lda BallSpeedX
   jsr SPCPlaySound
   negate_acc
   sta BallSpeedX

_collition_detect_pillar_end:
   pla
   rts


; -- Updates block
; -- Adds in A, block in X
UpdateBlock:
   phy
   ldy #$0000
-  pha 
   clc
   adc $01, x
   sta $01, x
   pla

   iny
   iny
   iny
   iny
   inx
   inx
   inx
   inx

   cpy #$0010
   bne -

   ply
   rts

UpdateEdgeBlock:
   pha
   clc
   adc $01, x
   sta $01, x
   pla

   pha
   clc
   adc $09, x
   sta $09, x
   pla
   rts

UpdatePillar:
   pha
   phx

   lda Joypad1Hi
   and #$08 ; Up
   beq _skip_p1_up

   lda PillarEdgeSpriteOAM + 1 ; Load y-coord of p1 upper edge
   cmp #$22
   bmi _skip_p1_up

   ldx #PillarEdgeSpriteOAM
   lda #$FE
   jsr UpdateEdgeBlock

   ldx #PillarSpriteOAM
   lda #$FE
   jsr UpdateBlock

_skip_p1_up:
   lda Joypad1Hi
   and #$04 ; Down
   beq _skip_p1_down

   lda PillarEdgeSpriteOAM + 9 ; Load y-coord of p1 lower edge
   cmp #$C8
   bpl _skip_p1_down

   ldx #PillarEdgeSpriteOAM
   lda #$02
   jsr UpdateEdgeBlock

   ldx #PillarSpriteOAM
   lda #$02
   jsr UpdateBlock

_skip_p1_down:
   lda Joypad2Hi
   and #$08 ; Up
   beq _skip_p2_up

   lda PillarEdgeSpriteOAM + 5 ; Load y-coord of p2 upper edge
   cmp #$22
   bmi _skip_p2_up

   ldx #(PillarEdgeSpriteOAM + 4)
   lda #$FE
   jsr UpdateEdgeBlock

   ldx #PillarSpriteOAM + 16
   lda #$FE
   jsr UpdateBlock

_skip_p2_up:
   lda Joypad2Hi
   and #$04 ; Down
   beq _skip_p2_down

   lda PillarEdgeSpriteOAM + 13 ; Load y-coord of p2 lower edge
   cmp #$C8
   bpl _skip_p2_down

   ldx #(PillarEdgeSpriteOAM + 4)
   lda #$02
   jsr UpdateEdgeBlock

   ldx #PillarSpriteOAM + 16
   lda #$02
   jsr UpdateBlock

_skip_p2_down:

   plx
   pla
   rts


.ends
