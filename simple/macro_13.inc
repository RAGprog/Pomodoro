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

;====================================================================
; new (ATt13)
;====================================================================

.macro mcu_freq_div 	; деление до 256
	tout CLKPR, 1<<7    ; Clock Prescaler Change Enable
    tout CLKPR, LOG2(@0) ;- 1	; расчет и загрузка значения делителя
	;0b1000  ; Clock Division Factor = 256, freq = 37,5kHz
.endmacro