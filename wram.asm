
; Sets RAM positions in WRAM.

.equ Joypad1Lo $0000
.equ Joypad1Hi $0001
.equ Joypad2Lo $0002
.equ Joypad2Hi $0003

.equ Joypad1Up $0004
.equ Joypad1Down $0005
.equ Joypad1Left $0006
.equ Joypad1Right $0007
.equ Joypad2Up $0008
.equ Joypad2Down $0009
.equ Joypad2Left $000A
.equ Joypad2Right $000B

.equ OAMData $1000

.equ BallSpriteOAM $1000
.equ PillarEdgeSpriteOAM $1010
.equ PillarSpriteOAM $1020
.equ Player1ScoreOAM $1040
.equ Player2ScoreOAM $1044

; Game state
.equ BallPosX $0102
.equ BallPosY $0103
.equ BallSpeedX $0104
.equ BallSpeedY $0105
.equ BallAccelX $0106
.equ BallAccelY $0107
.equ BallAccelCount $0108

.equ Screw_Player1_Down $0140
.equ Screw_Player1_Up $0141
.equ Screw_Player2_Down $0142
.equ Screw_Player2_Up $0143
.equ Screw_Player1_Right $0144
.equ Screw_Player2_Left $0145

.equ Player1Score $0180
.equ Player2Score $0181

.equ SPCCounter $0200
