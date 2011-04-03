
; Sets RAM positions in WRAM.

.equ Joypad1Lo $0000
.equ Joypad1Hi $0001
.equ Joypad2Lo $0002
.equ Joypad2Hi $0003

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

.equ Player1Score $0106
.equ Player2Score $0107
