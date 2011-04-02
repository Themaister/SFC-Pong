
; Sets RAM positions in WRAM.

.equ Joypad1Lo $0000
.equ Joypad1Hi $0001
.equ Joypad2Lo $0002
.equ Joypad2Hi $0003

.equ OAMData $1000

.equ BallSpriteOAM $1000
.equ PillarEdgeSpriteOAM $1010
.equ PillarSpriteOAM $1020

; Game state
.equ Pillar1Pos $0100
.equ Pillar2Pos $0101
.equ BallPosX $0102
.equ BallPosY $0103
.equ BallSpeedX $0104
.equ BallSpeedY $0105
