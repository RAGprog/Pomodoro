;_________TEST_MODE____________
.macro prodmode

	.set tim_m1L = M25L
	.set tim_m1H = M25H
	.set tim_m1HH = M25HH

	.set tim_m2L = M5L
	.set tim_m2H = M5H
	.set tim_m2HH = 0

	.set tim_m3L = M15L
	.set tim_m3H = M15H
	.set tim_m3HH = 0
.endmacro

.macro testmode
	.set tim_m1L = s3
	.set tim_m1H = 0
	.set tim_m1HH = 0

	.set tim_m2L = s1
	.set tim_m2H = 0
	.set tim_m2HH = 0

	.set tim_m3L = s1 * 2
	.set tim_m3H = 0
	.set tim_m3HH = 0
.endmacro


;======================================

;====================================================================
; MACROs
;====================================================================


.macro rout		; port, reg, k
	ldi @1, @2
	out @0, @1
.endmacro

.macro tout		; port, k
	rout @0, temp, @1
.endmacro

.macro toutpb		; k
	rout portb, temp, @0
.endmacro

.macro toutb		; port, reg, k
	ldi temp, @0
	out portB, temp
	out ddrB, temp
.endmacro