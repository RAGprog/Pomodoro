;====================================================================
; Main.asm файл скопирован из simple
; txt coding:	utf-8
;
; Created:   Пт авг 7 2020
; Processor: AT90S2313
; Compiler:  AVRASM (Proteus)
;====================================================================

; [~] Отсчет времени
; [ ] Срабатывание по времени после прерывания таймера
; [ ] ШИМ (1. Красный светодиод)

;====================================================================
; DEFINITIONS	|	Определения
;====================================================================

#include "const.inc" ;.INCLUDE 
#include "macro.inc"


; ____________Настройка_параметров_____________
; ___________________Setup_____________________
freq 16	;MHz
testmode 1 ; 1 = test mode (3s), 0 = prod. mode (25min)


;====================================================================
; VARIABLES	|	Переменные
;====================================================================
.def temp = r16
.def countHH = r20
.def countH = r17
.def countL = r18
.def one = r19

;.def temp_blink = r23

.def setStatus = r2
.def mode = r21	; 1 = 1s, 2 = 3s
.def bmode = r22	; modes for button

;general timer
.def timeL = r23
.def timeH = r24
.def timeHH = r25

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

EXT_INT0: ;________________________________
	; noise reduction:
	
	mov temp, setStatus
	; go to timer
	cpi temp, 0
	breq int0_push
	
	; button released, do smth, another 1 timer ckl skip
	cpi temp, 3
	breq int0_release
	mov setStatus, temp
reti
	int0_push:
		inc temp	; status 1
		mov setStatus, temp
reti
	int0_release:
		;inc setStatus	; что-то сделать с этим: задержка откладывается до выполнения задачи mode

		mov mode, bmode

reti

TIM_OVF1: ;________________________________

reti

TIM_OVF0: ;________________________________
	cli	; int off
	
	; for stack usage:
	;pop r5			; предположительно - PC, pointer
	; in temp, sreg	; status reg saving
	; push temp
	
	; general timer
	dec timeL
	;brne time	; перейти на метку "time", если не было перехода через ноль
	sbci timeH, 0	; отнять с остатком (отнимет 1 только при переходе через ноль)
	;brne time
	sbci timeHH, 0
	; Проверка окончания суток:
	cpi timeL, LOW(day)	; сравнить
	brne time	;	перейти на метку "time", если не равны
	cpi timeH, BYTE2(day)
	brne time
	cpi timeH, BYTE3(day)
	brne time
	; Проверить правильность сброса таймера [ ]:
	ldi timeL, 255
	ldi timeH, 255
	ldi timeHH, 255

	time:

	; modes
	; 1	- 4 x 25
	cpi mode, 1
	breq mode_1
	cpi mode, 3
	breq mode_1
	cpi mode, 5
	breq mode_1
	cpi mode, 7
	breq mode_1
	; 2 - 3 x 5
	cpi mode, 2
	breq mode_2
	cpi mode, 4
	breq mode_2
	cpi mode, 6
	breq mode_2
	; 3 - 1 x 15
	cpi mode, 8
	breq mode_3		; out of rich [ ] to fix
	; else (if mode not 0):
	cpi mode, 0
	breq mode_0
	;sbrc SREG, Z	; bit1 in sreg	; [+] replace, doesn't work
	ldi bmode, 1	; reset bmode, if mode == 0: skip
	mode_0:


	
	
	;push r5		; перенесено выше, т.к. в прот.случае придется повторять в ветках
	
	mov temp, setStatus
	; int0 noise skiping, falling
	cpi temp, 1
	breq tim0_int0_1
	cpi temp, 2
	breq tim0_int0_2
	; int0 noise skiping, rising
	cpi temp, 4
	breq tim0_int0_4
	cpi temp, 5
	breq tim0_int0_5

	mov setStatus, temp
	
	sei
reti
	tim0_int0_1:
		inc temp
		mov setStatus, temp
		sei
reti
	tim0_int0_2:
		inc temp
		mov setStatus, temp
		; rising int:
		tout	MCUCR,	MCUCR_pint0r
		sei
reti
	tim0_int0_4:
		inc temp
		mov setStatus, temp
		sei
reti
	tim0_int0_5:
		clr temp	; first state
		mov setStatus, temp
		; faling int:
		tout	MCUCR,	MCUCR_pint0f
		sei
reti
	mode_1:	; 3s + LED	;to macro
		mov r4, temp	; saving temp
		clr temp
		
		; LEDs on
		;cbi Portb, green_pnum	; LED2 off
		sbi Portb, red_pnum		; LED1 on
	
		;inc countL	 ; not work for this (theory: it is subi -1)
		ldi one, 1
		add countL, one		; true +1
		adc countH, temp	; +carry	(temp = 0)
		adc countHH, temp

		
		cpi countHH, tim_m1HH
		brne notatime_1;endoftim
		cpi countH, tim_m1H
		brne notatime_1;endoftim
		cpi countL, tim_m1L
		brne notatime_1
		; it's the time:
		ldi countL, 0
		ldi countH, 0
		clr countHH
		
		; LEDs off
		cbi Portb, red_pnum	; LED off
		
		ldi mode, 0
		inc bmode	; next - mode 2, 4, 6...
		
		notatime_1:
		
		mov temp, r4	; temp recovery
		sei
reti
	mode_2:
	rjmp mode_2j
	mode_3:
	rjmp mode_3j
	; ldi r30, LOW(mode_3j)
	; ldi r31, HIGH(mode_3j)
	; ijmp	; переход по адресу в rZ(jump to address in rZ)
	mode_2j:	; 1s + other LED
		mov r4, temp	; saving temp
		clr temp
		
		; LEDs
		;cbi Portb, red_pnum		; LED1 off
		sbi Portb, green_pnum	; LED2 on
	
		;inc countL	 ; not work for this (theory: it is subi -1)
		ldi one, 1
		add countL, one		; true +1
		adc countH, temp	; +carry	(temp = 0)
		
		cpi countHH, tim_m2HH
		brne notatime_2
		cpi countH, tim_m2H
		brne notatime_2;endoftim
		cpi countL, tim_m2L
		brne notatime_2
		; it's the time:
		ldi countL, 0
		ldi countH, 0
		clr countHH	; L, H, HH = 0
		
		; LEDs off
		cbi Portb, green_pnum	; LED off
		
		ldi mode, 0	; возврат режима 0
		inc bmode	; next - mode 3, 5, etc.
		
		notatime_2:
		
		mov temp, r4	; temp recovery
		sei
reti
	mode_3j:
		mov r4, temp	; saving temp
		clr temp
		
		; LEDs
		;cbi Portb, red_pnum		; LED1 off
		sbi Portb, green_pnum	; LED2 on
	
		;inc countL	 ; not work for this (theory: it is subi -1)
		ldi one, 1
		add countL, one		; true +1
		adc countH, temp	; +carry	(temp = 0)
		
		;add temp_blink, one
		;cpi temp_blink, s1
		;brlo skip_bl
		;cbi Portb, green_pnum
		;skip_bl:
		;cpi temp_blink, s1 * 2
		;brlo skip_bl2
		;sbi portB, green_pnum
		;skip_bl2:


		cpi countHH, tim_m3HH
		brne notatime_3
		cpi countH, tim_m3H
		brne notatime_3;endoftim
		cpi countL, tim_m3L
		brne notatime_3
		; it's the time:
		ldi countL, 0
		ldi countH, 0
		clr countHH	; L, H, HH = 0
		
		; LEDs off
		cbi Portb, green_pnum	; LED off
		
		ldi mode, 0	; возврат режима 0
		inc bmode	; next - mode 3, 5, etc.
		
		notatime_3a:
		notatime_3:
		
		mov temp, r4	; temp recovery
		sei
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
	ldi timeL, 255
	ldi timeH, 255
	ldi timeHH, 255

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
	clr countL
	clr countH
	clr countHH
	
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
