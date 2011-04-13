
;----------
;--
;-- PONG : Written by Themaister
;-----------------------------------

.include "header.inc"
.include "initsnes.asm"

.bank 0
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

   stz GamePaused

   jsr InitBall
   jsr InitPillar
   jsr InitScore
   jsr InitTimer
      
   LoadOAM OAMData, 0, 256
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
   stz Player1ScoreHI
   stz Player2ScoreHI

   lda #$05
   sta Player1ScoreOAM + 1
   sta Player2ScoreOAM + 1
   sta Player1ScoreHIOAM + 1
   sta Player2ScoreHIOAM + 1
   sta Player1ScoreSetOAM + 1
   sta Player2ScoreSetOAM + 1

   lda #$10
   sta Player1ScoreSetOAM
   lda #$38
   sta Player1ScoreHIOAM
   lda #$40
   sta Player1ScoreOAM
   lda #$B8
   sta Player2ScoreHIOAM
   lda #$C0
   sta Player2ScoreOAM
   lda #$E0
   sta Player2ScoreSetOAM

   lda #$10
   sta Player1ScoreOAM + 2
   sta Player2ScoreOAM + 2
   sta Player1ScoreHIOAM + 2
   sta Player2ScoreHIOAM + 2
   sta Player1ScoreSetOAM + 2
   sta Player2ScoreSetOAM + 2

   lda #%00110000
   sta Player1ScoreOAM + 3
   sta Player2ScoreOAM + 3
   sta Player1ScoreHIOAM + 3
   sta Player2ScoreHIOAM + 3
   sta Player1ScoreSetOAM + 3
   sta Player2ScoreSetOAM + 3

   stz OAMData + $0200 + 4
   lda #%01010000
   sta OAMData + $0200 + 5

   pla
   rts


InitTimer:
   pha

   lda #$02
   sta TimerMinute
   lda #$12
   sta TimerMinuteOAM + 2

   stz TimerSecond
   stz TimerSecondHI
   lda #$10
   sta TimerSecondOAM + 2
   sta TimerSecondHIOAM + 2

   lda #$05
   sta TimerSecondOAM + 1
   sta TimerSecondHIOAM + 1
   sta TimerMinuteOAM + 1

   lda #$74
   sta TimerMinuteOAM
   lda #$80
   sta TimerSecondHIOAM
   lda #$88
   sta TimerSecondOAM

   lda #%00110000
   sta TimerSecondOAM + 3
   sta TimerSecondHIOAM + 3
   sta TimerMinuteOAM + 3

   lda #%01000000
   sta OAMData + $0200 + 8

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

CheckPaused:
   pha

   lda OldPressedStart
   bne _check_paused_end

   lda Joypad1Start
   beq _check_paused_end

   lda GamePaused
   eor #$01
   sta GamePaused
   
   beq _check_paused_is_active
_check_paused_is_paused:
   lda #$04
   sta INIDISP
   bra _check_paused_end
_check_paused_is_active:
   lda #$0F
   sta INIDISP

_check_paused_end:
   lda Joypad1Start
   sta OldPressedStart

   pla
   rts

; Calculate AI movement for player 2. Not very good algorithm ... ;)
CalculateAIMovement:
   pha

   lda Joypad1Up
   sta Joypad2Left
   lda Joypad1Right
   sta Joypad2Down
   lda Joypad1Down
   sta Joypad2Right
   lda Joypad1Left
   sta Joypad2Up

   pla
   rts

; Start with CPU player. A human player could move in by pressing start.
UpdateAIMovement:
   pha
   
   lda HumanPlayer2
   bne +

   lda Joypad2Start
   beq ++
   lda #$01
   sta HumanPlayer2
   jsr InitGame
   bra +
++
   jsr CalculateAIMovement
+
   pla
   rts

; Do startup stuff that has to happen every frame.
PreFrame:
   pha

   jsr SaveJoypadStatus
   jsr CheckPaused
   jsr UpdateAIMovement

   stz Screw_Player1_Down
   stz Screw_Player1_Up
   stz Screw_Player2_Down
   stz Screw_Player2_Up
   stz Screw_Player1_Right
   stz Screw_Player2_Left

   pla
   rts


; Do stuff that happens at the end of every frame.
; Check if the set is over, and declare a winner.
PostFrame:
   pha

   lda TimerMinute
   bne _post_frame_end
   lda TimerSecondHI
   bne _post_frame_end
   lda TimerSecond
   bne _post_frame_end

; Reset timer.
   stz TimerCounter
   lda #$02
   sta TimerMinute
   stz TimerSecondHI
   stz TimerSecond

   rep #$20 ; 16-bit A/mem
   lda Player1Score

   cmp Player2Score
   beq _post_frame_draw
   bcs _post_frame_p1
   bra _post_frame_p2


_post_frame_p1:
   sep #$20 ; 8-bit A/mem
   inc Player1ScoreSet
   bra _post_frame_set_update

_post_frame_p2:
   sep #$20 ; 8-bit A/mem
   inc Player2ScoreSet
   bra _post_frame_set_update

_post_frame_draw:
   sep #$20 ; 8-bit A/mem
   inc Player1ScoreSet
   inc Player2ScoreSet

_post_frame_set_update:
   lda Player1ScoreSet
   clc
   adc #$10
   sta Player1ScoreSetOAM + 2

   lda Player2ScoreSet
   clc
   adc #$10
   sta Player2ScoreSetOAM + 2

   stz Player1Score
   stz Player1ScoreHI
   stz Player2Score
   stz Player2ScoreHI
   lda #$10
   sta Player1ScoreOAM + 2
   sta Player1ScoreHIOAM + 2
   sta Player2ScoreOAM + 2
   sta Player2ScoreHIOAM + 2

_post_frame_end:
   pla
   rts

FrameUpdate:
   LoadOAM OAMData, 0, 256 ; Update coordinates in OAM ASAP. We might have to do expensive calculation after this.

   jsr PreFrame

   lda GamePaused
   bne +

   jsr UpdateBall
   jsr UpdateTimer
   jsr UpdatePillarVert
   jsr UpdatePillarHoriz
   jsr PostFrame
+
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

; Check for acceleration (spin)
   inc BallAccelCount
   lda BallAccelCount
   cmp #$10 ; We update the accel value every 16th frame.
   bne +
   stz BallAccelCount

   lda BallAccelX
   clc
   adc BallSpeedX
   sta BallSpeedX

   lda BallAccelY
   clc
   adc BallSpeedY
   sta BallSpeedY
+

; Do collition detect and stuff ...
   jsr CollitionDetect
   jsr CheckScore

; Update acceleration values for X/Y, based on collition detection.
   lda BallAccelX
   clc
   adc Screw_Player1_Right
   sec
   sbc Screw_Player2_Left
   sta BallAccelX

   lda BallAccelY
   clc
   adc Screw_Player1_Up
   clc
   adc Screw_Player2_Up
   sec
   sbc Screw_Player1_Down
   sec
   sbc Screw_Player2_Down
   sta BallAccelY

; Cap the balls speed to something sane.
   lda BallSpeedX
   cmp #$05
   bmi +
   lda #$05
   sta BallSpeedX
+
   lda BallSpeedY
   cmp #$05
   bmi +
   lda #$05
   sta BallSpeedY
+
   lda BallSpeedX
   cmp #$FC
   bpl +
   lda #$FC
   sta BallSpeedX
+
   lda BallSpeedY
   cmp #$FC
   bpl +
   lda #$FC
   sta BallSpeedY
+

   pla
   rts


UpdateTimer:
   pha
   
   inc TimerCounter
   lda TimerCounter
   cmp #60 ; 60 fps
   bne _update_timer_end
   stz TimerCounter

   ; Check if we have to update second-hi, and possibly minute count too!
   dec TimerSecond
   lda TimerSecond
   bpl _update_timer_end

   lda #9
   sta TimerSecond

   dec TimerSecondHI
   lda TimerSecondHI
   bpl _update_timer_end

   lda #5
   sta TimerSecondHI

   dec TimerMinute
   lda TimerMinute
   bpl _update_timer_end

   lda #1
   sta TimerMinute

_update_timer_end:
   lda TimerMinute
   clc
   adc #$10
   sta TimerMinuteOAM + 2

   lda TimerSecondHI
   clc
   adc #$10
   sta TimerSecondHIOAM + 2

   lda TimerSecond
   clc
   adc #$10
   sta TimerSecondOAM + 2

   pla
   rts


; Check if the ball is in scoring region and update score.
CheckScore:
   pha

   lda BallPosX
   cmp #$08
   bcs +
   inc Player2Score
   bra _check_score_update

+  lda BallPosX
   cmp #$F0
   bcc _check_score_end
   inc Player1Score

_check_score_update:
   lda Player1Score
   cmp #10
   bne +
   lda #$00
   sta Player1Score
   inc Player1ScoreHI
   xba
   lda Player1ScoreHI
   clc
   adc #$10
   sta Player1ScoreHIOAM + 2
   xba
+
   clc
   adc #$10 ; Sprite index for score.
   sta Player1ScoreOAM + 2

   lda Player2Score
   cmp #10
   bne +
   lda #$00
   sta Player2Score
   inc Player2ScoreHI
   xba
   lda Player2ScoreHI
   clc
   adc #$10
   sta Player2ScoreHIOAM + 2
   xba
+
   clc
   adc #$10 ; Sprite index for score.
   sta Player2ScoreOAM + 2

   lda #$60
   sta BallPosX
   sta BallPosY
   lda #$02
   sta BallSpeedX
   sta BallSpeedY
   stz BallAccelX
   stz BallAccelY

   SPCPlaySoundEffect_Score

_check_score_end:
   pla
   rts

; Check edges first
CollitionDetect:
   pha

   ; Check to see if we're on the "scoring" edge. 
   ; If so, don't perform collition detection at all.
   lda BallPosY
   cmp #(17 * 8)
   bcs _collition_detect_left
   lda BallPosY
   cmp #(11 * 8)
   bcc _collition_detect_left
   bra _collition_detect_end

_collition_detect_left:
   lda BallSpeedX
   bpl _collition_detect_right

   lda BallPosX
   cmp #$18
   bcs _collition_detect_up
   lda BallSpeedX
   SPCPlaySoundEffect
   negate_acc
   sta BallSpeedX
   stz BallAccelX
   stz BallAccelY
   jmp _collition_detect_up
   
_collition_detect_right:
   lda BallPosX
   cmp #$E8
   bcc _collition_detect_up
   lda BallSpeedX
   SPCPlaySoundEffect
   negate_acc
   sta BallSpeedX
   stz BallAccelX
   stz BallAccelY


_collition_detect_up:
   lda BallSpeedY
   bpl _collition_detect_down

   lda BallPosY
   cmp #$24
   bcs _collition_detect_end
   lda BallSpeedY
   SPCPlaySoundEffect
   negate_acc
   sta BallSpeedY
   bra _collition_detect_end

_collition_detect_down:
   lda BallPosY
   cmp #$C8
   bcc _collition_detect_end
   lda BallSpeedY
   SPCPlaySoundEffect
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
   clc
   adc #$08
   cmp PillarEdgeSpriteOAM + 1 ; Upper coord of P1
   bcc _collition_detect_pillar_r

   lda BallPosY
   sec
   sbc #$08
   cmp PillarEdgeSpriteOAM + 9
   bcs _collition_detect_pillar_r

   lda BallSpeedX
   bpl +
   lda BallPosX
   cmp PillarEdgeSpriteOAM + 0 ; X coord of p1.
   bcc _collition_detect_pillar_r
   sec
   sbc #$09
   cmp PillarEdgeSpriteOAM + 0 ; X coord of p1.
   bcs _collition_detect_pillar_r

   lda BallSpeedX
   SPCPlaySoundEffect
   negate_acc
   sta BallSpeedX
   stz BallAccelX

   lda Joypad1Right ; Check if we should add right spin.
   beq ++
   inc Screw_Player1_Right
++
   lda Joypad1Up ; Check if we should add up spin.
   beq ++
   inc Screw_Player1_Up
++
   lda Joypad1Down
   beq ++
   inc Screw_Player1_Down
++

   jmp _collition_detect_pillar_end

+  lda BallPosX
   cmp PillarEdgeSpriteOAM + 0 ; X coord of p1.
   bcs _collition_detect_pillar_r
   clc
   adc #$09
   cmp PillarEdgeSpriteOAM + 0 ; X coord of p1.
   bcc _collition_detect_pillar_r

   lda BallSpeedX
   SPCPlaySoundEffect
   negate_acc
   sta BallSpeedX
   stz BallAccelX
   bra _collition_detect_pillar_end


_collition_detect_pillar_r:

   lda BallPosY
   clc
   adc #$08
   cmp PillarEdgeSpriteOAM + 5 ; Y coord of P2
   bcc _collition_detect_pillar_end

   lda BallPosY
   sec
   sbc #$08
   cmp PillarEdgeSpriteOAM + 13
   bcs _collition_detect_pillar_end

   lda BallSpeedX
   bpl +
   lda BallPosX
   cmp PillarEdgeSpriteOAM + 4 ; X coord of P2
   bcc _collition_detect_pillar_end
   sec
   sbc #$09
   cmp PillarEdgeSpriteOAM + 4 ; X coord of P2
   bcs _collition_detect_pillar_end

   lda BallSpeedX
   SPCPlaySoundEffect
   negate_acc
   sta BallSpeedX
   stz BallAccelX
   
   bra _collition_detect_pillar_end

+  lda BallPosX
   cmp PillarEdgeSpriteOAM + 4
   bcs _collition_detect_pillar_end
   clc
   adc #$09
   cmp PillarEdgeSpriteOAM + 4
   bcc _collition_detect_pillar_end

   lda BallSpeedX
   SPCPlaySoundEffect
   negate_acc
   sta BallSpeedX
   stz BallAccelX

   lda Joypad2Left
   beq ++
   inc Screw_Player2_Left
++
   lda Joypad2Up
   beq ++
   inc Screw_Player2_Up
++
   lda Joypad2Down
   beq ++
   inc Screw_Player2_Down
++


_collition_detect_pillar_end:
   pla
   rts



; Updates all elems in a pillar. Used by macros.
UpdateBlock:
   phy
   ldy #$0004
_update_block_loop:
   pha
   clc
   adc $00, x
   sta $00, x
   pla

   inx
   inx
   inx
   inx
   dey
   bne _update_block_loop

   ply
   rts

; Updates edges of a pillar block. Used by macros.
UpdateEdgeBlock:
   pha
   clc
   adc $00, x
   sta $00, x
   pla

   pha
   clc
   adc $08, x
   sta $08, x
   pla
   rts

UpdatePillarVert:
   pha
   phx

   lda Joypad1Up
   beq _skip_p1_up

   lda PillarEdgeSpriteOAM + 1 ; Load y-coord of p1 upper edge
   cmp #$22
   bmi _skip_p1_up

   ldx #PillarEdgeSpriteOAM
   lda #$FE
   UpdateEdgeBlockVert

   ldx #PillarSpriteOAM
   lda #$FE
   UpdateBlockVert

_skip_p1_up:
   lda Joypad1Down
   beq _skip_p1_down

   lda PillarEdgeSpriteOAM + 9 ; Load y-coord of p1 lower edge
   cmp #$C8
   bpl _skip_p1_down

   ldx #PillarEdgeSpriteOAM
   lda #$02
   UpdateEdgeBlockVert

   ldx #PillarSpriteOAM
   lda #$02
   UpdateBlockVert

_skip_p1_down:
   lda Joypad2Up
   beq _skip_p2_up

   lda PillarEdgeSpriteOAM + 5 ; Load y-coord of p2 upper edge
   cmp #$22
   bmi _skip_p2_up

   ldx #(PillarEdgeSpriteOAM + 4)
   lda #$FE
   UpdateEdgeBlockVert

   ldx #PillarSpriteOAM + 16
   lda #$FE
   UpdateBlockVert

_skip_p2_up:
   lda Joypad2Down
   beq _skip_p2_down

   lda PillarEdgeSpriteOAM + 13 ; Load y-coord of p2 lower edge
   cmp #$C8
   bpl _skip_p2_down

   ldx #(PillarEdgeSpriteOAM + 4)
   lda #$02
   UpdateEdgeBlockVert

   ldx #PillarSpriteOAM + 16
   lda #$02
   UpdateBlockVert

_skip_p2_down:

   plx
   pla
   rts


; Yes, code duplication is bad, mmkay?
UpdatePillarHoriz:
   pha
   phx

   lda Joypad1Left
   beq _skip_p1_left

   lda PillarEdgeSpriteOAM ; Load x-coord of p1 upper edge
   cmp #$20
   bmi _skip_p1_left

   ldx #PillarEdgeSpriteOAM
   lda #$FE
   UpdateEdgeBlockHoriz

   ldx #PillarSpriteOAM
   lda #$FE
   UpdateBlockHoriz

_skip_p1_left:
   lda Joypad1Right
   beq _skip_p1_right

   lda PillarEdgeSpriteOAM + 8 ; Load x-coord of p1 lower edge
   cmp #$70
   bpl _skip_p1_right

   ldx #PillarEdgeSpriteOAM
   lda #$02
   UpdateEdgeBlockHoriz

   ldx #PillarSpriteOAM
   lda #$02
   UpdateBlockHoriz

_skip_p1_right:
   lda Joypad2Left
   beq _skip_p2_left

   lda PillarEdgeSpriteOAM + 4 ; Load x-coord of p2 upper edge
   cmp #$98
   bmi _skip_p2_left

   ldx #(PillarEdgeSpriteOAM + 4)
   lda #$FE
   UpdateEdgeBlockHoriz

   ldx #PillarSpriteOAM + 16
   lda #$FE
   UpdateBlockHoriz

_skip_p2_left:
   lda Joypad2Right
   beq _skip_p2_right

   lda PillarEdgeSpriteOAM + 12 ; Load x-coord of p2 lower edge
   cmp #$D0
   bpl _skip_p2_right

   ldx #(PillarEdgeSpriteOAM + 4)
   lda #$02
   UpdateEdgeBlockHoriz

   ldx #PillarSpriteOAM + 16
   lda #$02
   UpdateBlockHoriz

_skip_p2_right:

   plx
   pla
   rts


.ends
