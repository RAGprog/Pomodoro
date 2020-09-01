;====================================================================
; Main.asm файл скопирован из simple
; txt coding:	utf-8
;
; Created:   Пт авг 7 2020
; Processor: AT90S2313
; Compiler:  AVRASM (Proteus)
;====================================================================

;====================================================================
; DEFINITIONS	|	Определения
;====================================================================

#include "const.inc" ;.INCLUDE 
#include "macro.inc"
#include "timer.inc"


; ____________Настройка_параметров_____________
; ___________________Setup_____________________
freq 16	;MHz
testmode 1 ; 1 = test mode (3s), 0 = prod. mode (25min)


;====================================================================
; VARIABLES	|	Переменные
;====================================================================
.def temp = r16

;.def setStatus = r2
;.def mode = r21	; 1 = 1s, 2 = 3s
;.def bmode = r22	; modes for button

timer_var r23, r24, r25, r16, r22

; zyx = 31:26

;====================================================================
; RESET and INTERRUPT VECTORS	|	Сброс и векторы прерываний
;====================================================================

      ; Reset Vector
      rjmp  Start
	rjmp EXT_INT0 ; IRQ0 Handler
	reti	;	rjmp EXT_INT1 ; IRQ1 Handler
	reti	;	rjmp TIM_CAPT1 ; Timer1 Capture Handler
	reti	;	rjmp TIM_COMP1 ; Timer1 Compare Handler
	rjmp TIM_OVF1 ; Timer1 Overflow Handler
	rjmp TIM_OVF0 ; Timer0 Overflow Handler
	reti	;	rjmp UART_RXC ; UART RX Complete Handler
	reti	;	rjmp UART_DRE ; UDR Empty Handler
	reti	;	rjmp UART_TXC ; UART TX Complete Handler
	reti	;	rjmp ANA_COMP ; Analog Comparator Handler

;====================================================================
; CODE SEGMENT
;====================================================================

timer_calls

EXT_INT0: ;________________________________
	; noise reduction:
	
;	mov temp, setStatus
	; go to timer
;	cpi temp, 0
;	breq int0_push
	
	; button released, do smth, another 1 timer ckl skip
;	cpi temp, 3
;	breq int0_release
;	mov setStatus, temp
;reti
;	int0_push:
;		inc temp	; status 1
;		mov setStatus, temp
;reti
	int0_release:
		;inc setStatus	; что-то сделать с этим: задержка откладывается до выполнения задачи mode

;		mov mode, bmode

reti

TIM_OVF1: ;________________________________

reti

TIM_OVF0: ;________________________________
	;old_timer_m
	timer_m
	new_t_routine lbl1
		; включение/отключение светодиода каждый вызов
		ldi tcomp, 2    ; маска, по которой будет происходить операция XOR
		mov r4, tcomp	; хранится в r4
		in tcomp, portB
		eor tcomp, r4
		out portB, tcomp
	end_t_routine lbl1 90

reti

;_____________________
Start: ;_____________________________RESET:__________________________

; timers
	; t0

	; prescaler
	ldi temp, 1 << cs02 | 1 << cs00	; clock select ck/1024
	out TCCR0, temp
	
	tout	TIMSK,	1 << TOIE1 |	0 << OCIE1A |	0 << TICIE1 |	1 << TOIE0

	; general timer init ; set a time [ ]
	;ldi timeL, 255
	;ldi timeH, 255
	;ldi timeHH, 255
	timer_var_init

; pins int
	; int0

	tout	GIMSK,	0 << int1 |	1 << int0	; General Interrupt Mask
	; MCU Control Register, Interrupt Sense Control
	tout	MCUCR,	sleep_e |	sleep_m |	0 << ISC11 |	0 << ISC10 |	1 << ISC01 |	0 << ISC00
	; ...Interrupt 0 Sense Control 10 - falling edge, 11 - rising, 00 - Low lvl; = MCUCR_pint0r

; sleep mode and pwr down
	tout ACSR, 1 << ACD ; Analog Comparator Disable
	
;======

    tout ddrB, 255	; init outputs
	
	tout portD, setup_pin	; init setup button

	ldi bmode, 1	; init first mode
	; clr from random val
	clr setStatus
	clr mode

	
	ldi temp, RAMend	; init stack
	out SPL, temp
	
	;  на всякий случай, для переменных таймера, очищаем 2 ячейки стека
	clr temp
	clr r17
	push temp
	push temp
	
	sei	; interrupts ON

	;deep sleep on reset
	;tout MCUCR, 1 << SM |	MCUCR_pint0f
	;sleep	; sleep 'til ext_int occure
	;tout MCUCR, MCUCR_pint0f
	
	
Loop: ;________________________________
	;sbis pinD, setup_pnum
	;out portB, temp	;rcall new

	sleep	;
	
      rjmp  Loop

;====================================================================
