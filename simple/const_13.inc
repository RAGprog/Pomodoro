; portB
.equ red_pin = 1 << 0
.equ red_pnum = 0
.equ green_pin = 1 << 2
.equ green_pnum = 2
.equ blue_pin = 1 << 3
.equ blue_pnum = 3
.equ buzz_pnum = 4
;.equ yellow_pnum = 3
;.equ yellow_pin = 1 << yellow_pnum
;.equ w1_pnum = 4
;.equ w2_pnum = 5
;.equ w3_pnum = 6
;.equ w4_pnum = 7

.equ day = $ffffff  ; to edit [ ]
.set tim_prescaler = 1024

;.set freq_cal = 0


;portD
.equ setup_pin = 1 << 2
.equ setup_pnum = 2

;sleep mode
;.equ sleep_e = 1	; enable
.equ sleep_e = 1 << SE
;.equ sleep_m = 0	; 0 - idle, 1 - power-down
.equ sleep_m = 0 ;<< SM

;– PUD SE SM1 SM0 – ISC01 ISC00
.equ MCUCR_pint0f =	sleep_e |	sleep_m |	1 << ISC01 |	0 << ISC00
.equ MCUCR_pint0r =	sleep_e |	sleep_m |	1 << ISC01 |	1 << ISC00
		; ...Interrupt 0 Sense Control 10 - falling edge, 11 - rising, 00 - Low lvl

;================================

.macro freq ;Hz
 ;   .set tim_prescaler = 1024
    .set timer_freq = @0 * 100 / tim_prescaler / 256
    .set S1 = 1 * timer_freq
    .set S3 = 3 * timer_freq
    .set M5 = 5 * 60 * timer_freq
    .set M15 = 15 * 60 * timer_freq
    .set M25 = 25 * 60 * timer_freq

    .set S1L = LOW(S1)
    .set S1H = BYTE2(S1)
    .set S1HH = BYTE3(S1)

    .set S3L = LOW(S3)
    .set S3H = BYTE2(S3)
    .set S3HH = BYTE3(S3)

    .set M5L = LOW(M5)
    .set M5H = BYTE2(M5)
    .set M5HH = BYTE3(M5)

    .set M15L = LOW(M15)
    .set M15H = BYTE2(M15)
    .set M15HH = BYTE3(M15)

    .set M25L = LOW(M25)
    .set M25H = BYTE2(M25)
    .set M25HH = BYTE3(M25)

.endmacro

.macro testmode ; if testmode - alt val | если testmode 1, то запысываются альтернативные значения

    .set tim_m1L = M25L * (1 - @0) + S3L * (@0)
	.set tim_m1H = M25H * (1 - @0) + S3H * (@0)
	.set tim_m1HH = M25HH * (1 - @0) + S3HH * (@0)

	.set tim_m2L = M5L * (1 - @0) + S1L * (@0)
	.set tim_m2H = M5H * (1 - @0) + S1H * (@0)
	.set tim_m2HH = M5HH * (1 - @0) + S1HH * (@0)

	.set tim_m3L = M15L * (1 - @0) + S1L * (@0) * 2
	.set tim_m3H = M15H * (1 - @0) + S1H * (@0) * 2
	.set tim_m3HH = M15HH * (1 - @0) + S1HH * (@0) * 2
.endmacro

;; Для надежности здесь рассчитываются паузы по умолчанию:
;testmode 0
; нет, это накладно, придется задавать и частоту

; Для надежности здесь рассчитываются паузы по умолчанию:
freq 96000
testmode 0
