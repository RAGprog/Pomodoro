; portB
.equ red_pin = 1 << 0
.equ red_pnum = 0
.equ green_pin = 1 << 1
.equ green_pnum = 1
.equ blue_pin = 1 << 2
.equ blue_pnum = 2
.equ yellow_pnum = 3
.equ yellow_pin = 1 << yellow_pnum
.equ w1_pnum = 4
.equ w2_pnum = 5
.equ w3_pnum = 6
.equ w4_pnum = 7


;portD
.equ setup_pin = 1 << 2
.equ setup_pnum = 2

;sleep mode
.equ sleep_e = 1	; enable
;.equ sleep_e = 1 << SE
.equ sleep_m = 0	; 0 - idle, 1 - power-down
;.equ sleep_m = 0 << SM


; 1 cycle = 16.384ms
.equ S1 = 61

.equ S3 = 183

.equ M5L = 134	;	5m = 134	(,55)
.equ M5H = 71	;	5m = 71

.equ M15L = 147	;	15m = 147	(.64)
.equ M15H = 214	;	15m = 214

.equ M25L	= 161	;	(-.27)
.equ M25H	= 101
.equ M25HH	= 1


;================================

