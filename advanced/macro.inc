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

.macro log_shift_left 
		.if @1 > 0
			lsl @0
		.endif
		.if @1 > 1
			lsl @0
		.endif
		.if @1 > 2
			lsl @0
		.endif
		.if @1 > 3
			lsl @0
		.endif
		.if @1 > 4
			lsl @0
		.endif
		.if @1 > 5
			lsl @0
		.endif
		.if @1 > 6
			lsl @0
		.endif
	.endmacro